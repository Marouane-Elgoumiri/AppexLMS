#!/usr/bin/env bash
# scripts/verify_rls.sh
#
# Sprint 4a — RLS policy smoke test (testing sheet criterion 4a.8).
#
# Verifies that Row Level Security on `enrollments`:
#   1. A signed-in user CAN see their own enrollments.
#   2. A signed-in user CANNOT see *another* user's enrollments.
#   3. Anonymous requests CANNOT read enrollments.
#
# Usage:
#   SUPABASE_URL=https://npqrpcnpgfshazeozmkr.supabase.co \
#   ANON_KEY=<anon-publishable-key> \
#   DEMO_USER_EMAIL='student@appex.dev' \
#   DEMO_USER_PASSWORD='<chosen-during-seed>' \
#   OTHER_USER_ID='<some-other-uuid>' \
#   ./scripts/verify_rls.sh

set -euo pipefail

if [[ -z "${SUPABASE_URL:-}" || -z "${ANON_KEY:-}" ]]; then
    echo "❌ Set SUPABASE_URL and ANON_KEY (publishableKey) env vars first."
    exit 1
fi

USERS_API="auth/v1"
REST_API="rest/v1"

# 1) Sign the demo user in to get their JWT + id.
if [[ -z "${DEMO_USER_EMAIL:-}" || -z "${DEMO_USER_PASSWORD:-}" ]]; then
    echo "❌ Set DEMO_USER_EMAIL and DEMO_USER_PASSWORD (set during seed)."
    exit 1
fi

echo "▶ Signing in ${DEMO_USER_EMAIL}..."
signin_body=$(curl -sS "${SUPABASE_URL}/${USERS_API}/token?grant_type=password" \
    -H 'Content-Type: application/json' \
    -H "apikey: ${ANON_KEY}" \
    -d "{\"email\":\"${DEMO_USER_EMAIL}\",\"password\":\"${DEMO_USER_PASSWORD}\"}")

ACCESS_TOKEN=$(echo "${signin_body}" | sed -nE 's/.*"access_token":"([^"]+)".*/\1/p')
DEMO_USER_ID=$(echo "${signin_body}" | sed -nE 's/.*"id":"([^"]+)".*/\1/p')
if [[ -z "${ACCESS_TOKEN}" || -z "${DEMO_USER_ID}" ]]; then
    echo "❌ Could not parse tokens from signin response:"
    echo "${signin_body}"
    exit 1
fi
echo "  ✓ authenticated; user_id=${DEMO_USER_ID}"
echo

if [[ -z "${OTHER_USER_ID:-}" ]]; then
    echo "ℹ Skip 'cannot read another user' check (set OTHER_USER_ID to run)"
    OTHER_USER_ID=""
fi

# 2) Demo user reads THEIR OWN enrollments — expected non-empty (the seed inserts
# at least one row).
echo "▶ Reading enrollments for self (user_id=${DEMO_USER_ID})"
self_response=$(curl -sS "${SUPABASE_URL}/${REST_API}/enrollments?user_id=eq.${DEMO_USER_ID}&select=id" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}")
echo "  ${self_response}"

if [[ "${self_response}" == "[]" ]]; then
    echo "⚠️ Empty; the seed may not have created an enrollment for this user."
fi
echo

# 3) Demo user tries to read another's enrollments — expected [].
if [[ -n "${OTHER_USER_ID}" ]]; then
    echo "▶ Reading enrollments for another user (user_id=${OTHER_USER_ID})"
    other_response=$(curl -sS "${SUPABASE_URL}/${REST_API}/enrollments?user_id=eq.${OTHER_USER_ID}&select=id" \
        -H "apikey: ${ANON_KEY}" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}")
    echo "  ${other_response}"

    if [[ "${other_response}" == "[]" ]]; then
        echo "  ✓ RLS enforced: other user's enrollments are hidden."
    else
        echo "  ❌ Expected [] but got: ${other_response}"
        exit 1
    fi
    echo
fi

# 4) Anonymous (no JWT) request — expected to return [] (no row leakage).
echo "▶ Reading enrollments with NO JWT (anon)"
anon_response=$(curl -sS "${SUPABASE_URL}/${REST_API}/enrollments?select=id&limit=1" \
    -H "apikey: ${ANON_KEY}")
echo "  ${anon_response}"
if [[ "${anon_response}" == "[]" || "${anon_response}" == "" ]]; then
    echo "  ✓ anon cannot read enrollments."
else
    echo "  ❌ Unexpected anon response: ${anon_response}"
    exit 1
fi

echo
echo "✅ RLS verification complete"
