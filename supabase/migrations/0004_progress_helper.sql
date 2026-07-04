-- 0004_progress_helper.sql
-- Sprint 4a — server-side RPC for appending a lesson id to an enrollment's
-- completed_lesson_ids array, idempotently.
--
-- Why an RPC instead of a client-side read-modify-write?
--  1. Atomicity — the SELECT + UPDATE pair can't race with another client
--     also inserting the same lesson id.
--  2. RLS-friendliness — the function runs as SECURITY DEFINER (the table
--     owner, which bypasses RLS), so the user can't bypass the WHERE
--     clause via PostgREST filters and write into OTHER users' rows.
--  3. Simplicity — the client code calls `supabase.rpc('mark_lesson_completed', ...)`
--     instead of doing two round-trips + a fragile array-rewrite.

create or replace function public.mark_lesson_completed(
    p_enrollment_id uuid,
    p_lesson_id     text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    update public.enrollments
       set completed_lesson_ids =
             array_append(
               coalesce(completed_lesson_ids, ARRAY[]::text[]),
               p_lesson_id
             )
     where id = p_enrollment_id
       and not (p_lesson_id = any(completed_lesson_ids));

    if not found then
        raise exception 'Enrollment % not found.', p_enrollment_id
            using errcode = 'P0002';
    end if;
end;
$$;

-- Revoke default EXECUTE from `anon`/`authenticated`/`service_role` and
-- grant it ONLY to authenticated users — anon users must not be able to
-- touch anyone's enrollment progress.
revoke execute on function public.mark_lesson_completed(uuid, text) from anon, authenticated, service_role;
grant execute on function public.mark_lesson_completed(uuid, text) to authenticated;
