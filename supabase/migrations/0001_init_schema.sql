-- 0001_init_schema.sql
-- Sprint 4a — initial schema for AppexLMS.
-- Tables: profiles, courses, lessons, enrollments.
--
-- Column names match the JSON contract the existing Dart models expect:
--   UserModel.fromJson      -> id, email, display_name
--   CourseModel.fromJson    -> id, title, instructor, category, lesson_count, image_url
--   LessonModel.fromJson    -> id, course_id, title, "order", duration_seconds
--   EnrollmentModel.fromJson-> id, user_id, course_id, enrolled_at, completed_lesson_ids
--
-- See lib/data/models/*.dart for the authoritative on-wire contract.

-- Extensions
create extension if not exists "pgcrypto";     -- for gen_random_uuid()
create extension if not exists "uuid-ossp";    -- for uuid_generate_v4() if needed

-- ──────────────────────────────────────────────────────────────────────────
-- public.profiles  (one row per Supabase auth user; mirrors auth.users)
-- ──────────────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
    id           uuid primary key references auth.users(id) on delete cascade,
    email        text        not null,
    display_name text        not null,
    created_at   timestamptz not null default now()
);

comment on table public.profiles is
    'Public-facing user profile rows. PK is FK to auth.users so Supabase Auth owns the user identity; this table holds only the public-visible fields.';

-- ──────────────────────────────────────────────────────────────────────────
-- public.courses
-- ──────────────────────────────────────────────────────────────────────────
create table if not exists public.courses (
    id           uuid        primary key default gen_random_uuid(),
    title        text        not null,
    instructor   text        not null,
    category     text        not null default 'General',
    lesson_count integer     not null default 0,
    image_url    text
);

comment on table public.courses is
    'LMS course catalog. Seeded with 8 courses during Sprint 4a.';

-- ──────────────────────────────────────────────────────────────────────────
-- public.lessons  (note: "order" is a SQL reserved word → always quoted)
-- ──────────────────────────────────────────────────────────────────────────
create table if not exists public.lessons (
    id               uuid    primary key default gen_random_uuid(),
    course_id        uuid    not null references public.courses(id) on delete cascade,
    title            text    not null,
    "order"          integer not null,
    duration_seconds integer not null default 0
);

create index if not exists lessons_course_id_idx on public.lessons(course_id);

comment on column public.lessons."order" is
    'Position of the lesson inside its parent course. "order" is a SQL reserved word, hence quoted in every DDL/query.';

-- ──────────────────────────────────────────────────────────────────────────
-- public.enrollments  (progress is stored as a text[] of completed lesson ids)
-- ──────────────────────────────────────────────────────────────────────────
create table if not exists public.enrollments (
    id                   uuid      primary key default gen_random_uuid(),
    user_id              uuid      not null references public.profiles(id)   on delete cascade,
    course_id            uuid      not null references public.courses(id)    on delete cascade,
    enrolled_at          timestamptz not null default now(),
    completed_lesson_ids text[]    not null default '{}'
);

create unique index if not exists enrollments_user_course_uniq
    on public.enrollments(user_id, course_id);

create index if not exists enrollments_user_id_idx on public.enrollments(user_id);

comment on column public.enrollments.completed_lesson_ids is
    'Postgres text[] of completed lesson UUIDs (as strings, since the Dart model stringifies them). Updated by markLessonCompleted via array_append.';
