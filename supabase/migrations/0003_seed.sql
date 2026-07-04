-- 0003_seed.sql
-- Sprint 4a — seed the same 8 courses + lessons the mock data sources held.
-- Idempotent: every insert uses ON CONFLICT DO NOTHING so `supabase db reset`
-- followed by `db push` is safe to repeat.
--
-- NOTE on auth users / profiles / enrollments:
-- Those are intentionally NOT seeded here. GoTrue owns auth.users, and
-- inserting directly into it (the previous approach in this file) caused
-- two failures:
--   1. The bcrypt hash in `encrypted_password` is wrong — GoTrue uses scrypt.
--      Login via the REST API returned HTTP 500 with body
--      {"unexpected_failure","message":"Database error querying schema"}.
--   2. Modern auth.users has additional NOT NULL columns (e.g. is_sso_user,
--      is_anonymous, deleted_at). Direct INSERTs that target only the original
--      column set leave the row broken; even after `db push` succeeds,
--      GoTrue's later queries on that user 500.
-- Therefore the demo user (student@appex.dev / password123), its profiles
-- row, and its pre-enrollment in Flutter Foundations are all created by:
--     scripts/seed_demo_user.sh
-- which calls supabase.auth.admin.createUser() (GoTrue hashes correctly and
-- populates every required column). The on_auth_user_created trigger defined
-- in 0002_rls_policies.sql then inserts the matching public.profiles row.
-- Full rationale lives next to that script.

-- ──────────────────────────────────────────────────────────────────────────
-- 3. lessons — 5 per course, matching MockLessonDataSource's pattern
-- ──────────────────────────────────────────────────────────────────────────
insert into public.lessons (id, course_id, title, "order", duration_seconds)
select
    -- Postgres-generated UUID, not a hand-rolled hex concatenation.
    -- The previous `'b'||lpad(...,'0')||'-'||lpad(...,'0')||'-0000-0000-000000000000'`
    -- produced segment 8-7-4-4-12 (the second-to-last segment needs 4 chars, not 7),
    -- so the cast to uuid failed at parse time. gen_random_uuid() is simpler and
    -- guaranteed valid; the Dart model coerces string ids anyway.
    gen_random_uuid(),
    course_id,
    'Lesson ' || lesson_idx || ' — c' || course_idx,
    lesson_idx,
    300 + lesson_idx * 60
from (
    select c.id as course_id,
           row_number() over (order by c.id) as course_idx
    from public.courses c
) courses
cross join generate_series(1, 5) as lesson_idx
where not exists (
    select 1
    from public.lessons existing
    where existing.course_id = courses.course_id
      and existing."order" = lesson_idx
)
order by course_idx, lesson_idx;
