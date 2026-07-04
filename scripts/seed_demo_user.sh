#!/usr/bin/env bash
# scripts/seed_demo_user.sh
#
# Sprint 4a — provision the demo user for end-to-end testing against hosted Supabase.
#
# Why this script exists:
#   We can't reliably seed auth.users from a SQL migration. GoTrue owns that table
#   and (a) hashes passwords with scrypt, not bcrypt (a precomputed bcrypt hash in
#   `encrypted_password` makes GoTrue return 500 on every login attempt) and
#   (b) populates columns like is_sso_user / is_anonymous / deleted_at that
#   versions after 2022 added as NOT NULL. Inserting through supabase.auth.admin
#   avoids both pitfalls: GoTrue defines the row, the trigger in
#   0002_rls_policies.sql back-fills public.profiles, and this script then
#   enrolls the user in Flutter Foundations so the dashboard has progress data.
#
# What this script does (idempotent — safe to re-run):
#   1. POST /auth/v1/admin/users  → create the user. If 422 (already exists),
#      GET /auth/v1/admin/users?email=… to recover the existing UUID.
#   2. PATCH /rest/v1/profiles    → upsert the matching public.profiles row, in
#      case the trigger didn't materialize it.
#   3. GET  /rest/v1/courses      → pick the first course (Flutter Foundations).
#   4. POST /rest/v1/enrollments  → upser the enrollment on (user_id, course_id).
#
# Usage:
#   SUPABASE_URL=https://npqrpcnpgfshazeozmkr.supabase.co \
#   SUPABASE_SERVICE_ROLE_KEY=<service_role_key> \
#   ./scripts/seed_demo_user.sh
#
# The service-role key bypasses RLS — needed to upsert the profile + enrollment
# server-side. Do NOT commit this key; keep it in your shell environment.

set -euo pipefail

DEMO_EMAIL='student@appex.dev'
DEMO_PASSWORD='password123'
DEMO_DISPLAY_NAME='Demo Student'

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
    echo "Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY env vars first."
    echo "  export SUPABASE_URL=https://<ref>.supabase.co"
    echo "  export SUPABASE_SERVICE_ROLE_KEY=<service-role-key>"
    exit 1
fi

AUTH_API="auth/v1"
REST_API="rest/v1"
HDRS_GOTRUE=(-H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
             -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
             -H "Content-Type: application/json")
HDRS_REST=(-H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
           -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
           -H "Content-Type: application/json")

# Python is available on macOS/Linux, used here only as a JSON parser so we
# don't depend on jq being installed.
json_get() {
    # $1 = JSON, $2 = key
    python3 -c "import json,sys; d=json.loads(sys.stdin.read()); k='$2'
parts=k.split('.')
for p in parts:
    if isinstance(d, list):
        d=d[int(p)]
    else:
        d=d.get(p) if isinstance(d, dict) else None
    if d is None: break
print(d if d is not None else '')" <<<"$1"
}

# ──────────────────────────────────────────────────────────────────────────
# 1. Create the user (or recover the existing UUID).
# ──────────────────────────────────────────────────────────────────────────
echo "▶ Creating user ${DEMO_EMAIL} via admin API..."
create_body=$(curl -sS -w '\n%{http_code}' "${SUPABASE_URL}/${AUTH_API}/admin/users" \
    "${HDRS_GOTRUE[@]}" \
    -d "{\"email\":\"${DEMO_EMAIL}\",\"password\":\"${DEMO_PASSWORD}\",\"email_confirm\":true,\"user_metadata\":{\"display_name\":\"${DEMO_DISPLAY_NAME}\"}}")
http_code=$(echo "${create_body}" | tail -n1)
json_part=$(echo "${create_body}" | sed '$d')

USER_ID=""
if [[ "${http_code}" == "200" || "${http_code}" == "201" ]]; then
    USER_ID=$(json_get "${json_part}" "id")
    echo "  ✓ Created new user id=${USER_ID}"
elif [[ "${http_code}" == "422" ]]; then
    echo "  ℹ User already exists; resolving existing uuid..."
    list_resp=$(curl -sS "${SUPABASE_URL}/${AUTH_API}/admin/users?email=${DEMO_EMAIL}" \
        "${HDRS_GOTRUE[@]}")
    USER_ID=$(json_get "${list_resp}" "users.0.id")
    if [[ -z "${USER_ID}" ]]; then
        echo "  ❌ 422 returned but could not resolve user id:"
        echo "${list_resp}"
        exit 1
    fi
    echo "  ✓ Existing user id=${USER_ID}"
else
    echo "  ❌ Create failed (HTTP ${http_code}):"
    echo "${json_part}"
    exit 1
fi
echo

# ──────────────────────────────────────────────────────────────────────────
# 2. Upsert the profiles row (backstop in case the trigger didn't fire).
# ──────────────────────────────────────────────────────────────────────────
echo "▶ Upserting public.profiles..."
profiles_resp=$(curl -sS -w '\n%{http_code}' -X POST "${SUPABASE_URL}/${REST_API}/profiles?on_conflict=id" \
    "${HDRS_REST[@]}" \
    -H "Prefer: resolution=merge-duplicates,return=minimal" \
    -d "{\"id\":\"${USER_ID}\",\"email\":\"${DEMO_EMAIL}\",\"display_name\":\"${DEMO_DISPLAY_NAME}\"}")
http_code=$(echo "${profiles_resp}" | tail -n1)
body=$(echo "${profiles_resp}" | sed '$d')
if [[ "${http_code}" =~ ^2 ]]; then
    echo "  ✓ profiles upsert ok"
else
    echo "  ⚠️ profiles upsert returned HTTP ${http_code}, continuing:"
    echo "${body}"
fi
echo

# ──────────────────────────────────────────────────────────────────────────
# 3. Resolve the Flutter Foundations course id for the demo enrollment.
# ──────────────────────────────────────────────────────────────────────────
echo "▶ Resolving Flutter Foundations course id..."
courses_resp=$(curl -sS "${SUPABASE_URL}/${REST_API}/courses?title=eq.Flutter%20Foundations&select=id&limit=1" \
    "${HDRS_REST[@]}")
COURSE_ID=$(json_get "${courses_resp}" "0.id")
if [[ -z "${COURSE_ID}" ]]; then
    # Fallback: pick any single course if 0003_seed.sql hasn't been pushed yet.
    first_resp=$(curl -sS "${SUPABASE_URL}/${REST_API}/courses?select=id&order=id&limit=1" \
        "${HDRS_REST[@]}")
    COURSE_ID=$(json_get "${first_resp}" "0.id")
fi
if [[ -z "${COURSE_ID}" ]]; then
    echo "  ❌ No courses found — push 0003_seed.sql first."
    exit 1
fi
echo "  ✓ course_id=${COURSE_ID}"
echo

# ──────────────────────────────────────────────────────────────────────────
# 4. Upsert the enrollment row.
# ──────────────────────────────────────────────────────────────────────────
echo "▶ Upserting enrollment (user ${USER_ID} → course ${COURSE_ID})..."
enroll_resp=$(curl -sS -w '\n%{http_code}' -X POST "${SUPABASE_URL}/${REST_API}/enrollments?on_conflict=user_id,course_id" \
    "${HDRS_REST[@]}" \
    -H "Prefer: resolution=merge-duplicates,return=minimal" \
    -d "{\"user_id\":\"${USER_ID}\",\"course_id\":\"${COURSE_ID}\",\"completed_lesson_ids\":[]}")
http_code=$(echo "${enroll_resp}" | tail -n1)
body=$(echo "${enroll_resp}" | sed '$d')
if [[ "${http_code}" =~ ^2 ]]; then
    echo "  ✓ enrollment upsert ok"
else
    echo "  ❌ enrollment upsert returned HTTP ${http_code}:"
    echo "${body}"
    exit 1
fi
echo

echo "Demo user ready:"
echo "  email:        ${DEMO_EMAIL}"
echo "  password:     ${DEMO_PASSWORD}"
echo "  user_id:      ${USER_ID}"
echo "  course_id:    ${COURSE_ID}"
echo "Run flutter run (no --dart-define) to authenticate against hosted Supabase."
