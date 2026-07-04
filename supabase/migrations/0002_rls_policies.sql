-- 0002_rls_policies.sql
-- Sprint 4a — Row Level Security (RLS) policies.
--
-- Principle: every table gets RLS enabled. Auth'd users can read public
-- catalog data (courses, lessons). Users can read & write ONLY their own
-- rows in `profiles` and `enrollments`.
--
-- Service role bypasses RLS (default Postgres behaviour), so seeded data
-- and dashboards can still administer the project.

-- ──────────────────────────────────────────────────────────────────────────
-- Enable RLS on every public table
-- ──────────────────────────────────────────────────────────────────────────
alter table public.profiles    enable row level security;
alter table public.courses     enable row level security;
alter table public.lessons     enable row level security;
alter table public.enrollments enable row level security;

-- ──────────────────────────────────────────────────────────────────────────
-- profiles: user reads + updates only their own row
-- ──────────────────────────────────────────────────────────────────────────
create policy "profiles_select_own"
    on public.profiles
    for select
    to authenticated
    using (auth.uid() = id);

create policy "profiles_update_own"
    on public.profiles
    for update
    to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);

-- ──────────────────────────────────────────────────────────────────────────
-- courses: readable by any authenticated user; writes only via service role
-- ──────────────────────────────────────────────────────────────────────────
create policy "courses_select_authenticated"
    on public.courses
    for select
    to authenticated
    using (true);

-- ──────────────────────────────────────────────────────────────────────────
-- lessons: readable by any authenticated user; writes only via service role
-- ──────────────────────────────────────────────────────────────────────────
create policy "lessons_select_authenticated"
    on public.lessons
    for select
    to authenticated
    using (true);

-- ──────────────────────────────────────────────────────────────────────────
-- enrollments: a user reads, inserts, and updates ONLY rows where user_id = auth.uid()
-- ──────────────────────────────────────────────────────────────────────────
create policy "enrollments_select_own"
    on public.enrollments
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "enrollments_insert_own"
    on public.enrollments
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "enrollments_update_own"
    on public.enrollments
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────────────────────
-- Auto-create a profile row when a new auth user signs up.
-- A trigger keeps public.profiles synchronized with auth.users inserts so
-- the demo login → displayName flow doesn't need an extra round-trip after signUp().
-- ──────────────────────────────────────────────────────────────────────────
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (id, email, display_name)
    values (
        new.id,
        coalesce(new.email, ''),
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            split_part(coalesce(new.email, 'user'), '@', 1)
        )
    )
    on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_auth_user();
