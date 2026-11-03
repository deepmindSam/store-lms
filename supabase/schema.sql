-- Store LMS schema
-- Run this once in the Supabase SQL editor (Project > SQL Editor > New query).
-- Safe to re-run: uses "create table if not exists" / "drop policy if exists".

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists stores (
  slug text primary key,
  name text not null
);

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  store_slug text references stores (slug) on delete set null,
  role text not null default 'learner' check (role in ('learner', 'admin')),
  created_at timestamptz not null default now()
);

create table if not exists courses (
  slug text primary key,
  title text not null,
  description text not null default '',
  tier text not null default 'core' check (tier in ('core', 'upskilling')),
  sort_order int not null default 0
);

create table if not exists modules (
  slug text primary key,
  course_slug text not null references courses (slug) on delete cascade,
  title text not null,
  sort_order int not null default 0,
  pass_mark_percent int not null default 80
);

create table if not exists progress (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  module_slug text not null references modules (slug) on delete cascade,
  status text not null default 'not_started' check (status in ('not_started', 'in_progress', 'completed')),
  time_spent_seconds int not null default 0,
  started_at timestamptz,
  completed_at timestamptz,
  unique (user_id, module_slug)
);

create table if not exists quiz_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  module_slug text not null references modules (slug) on delete cascade,
  score_percent numeric not null,
  passed boolean not null,
  time_taken_seconds int not null default 0,
  attempted_at timestamptz not null default now()
);

-- Quiz questions, INCLUDING correct_index, are never selectable by the app's
-- authenticated/anon roles (no SELECT policy below). The app only ever reads
-- quiz_questions_public (no answers) and only ever grades through grade_quiz()
-- (server-side, security definer). This is what makes the pass mark a real
-- gate instead of a client-side formality a learner could bypass.
create table if not exists quiz_questions (
  id bigint generated always as identity primary key,
  module_slug text not null references modules (slug) on delete cascade,
  question text not null,
  options jsonb not null,
  correct_index int not null,
  sort_order int not null default 0
);

create or replace view quiz_questions_public as
  select id, module_slug, question, options, sort_order
  from quiz_questions
  order by module_slug, sort_order;

grant select on quiz_questions_public to authenticated;

-- ---------------------------------------------------------------------------
-- Auto-create a profile row whenever a new auth user is created.
-- Admin sets full_name/store/role afterwards (via Supabase dashboard or the
-- "Manage learners" SQL snippets in the README).
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email), 'learner')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Helper: is the current user an admin? (security definer avoids RLS recursion)
-- ---------------------------------------------------------------------------

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- RPCs used by the app for atomic progress updates (avoids lost updates when
-- a learner has the lesson open in two tabs, etc).
-- ---------------------------------------------------------------------------

create or replace function public.track_module_time(p_module_slug text, p_seconds int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into progress (user_id, module_slug, status, time_spent_seconds, started_at)
  values (auth.uid(), p_module_slug, 'in_progress', greatest(p_seconds, 0), now())
  on conflict (user_id, module_slug) do update
    set time_spent_seconds = progress.time_spent_seconds + greatest(p_seconds, 0),
        status = case when progress.status = 'completed' then progress.status else 'in_progress' end;
end;
$$;

create or replace function public.mark_module_complete(p_module_slug text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into progress (user_id, module_slug, status, started_at, completed_at)
  values (auth.uid(), p_module_slug, 'completed', now(), now())
  on conflict (user_id, module_slug) do update
    set status = 'completed', completed_at = now();
end;
$$;

-- grade_quiz(): the ONLY path by which a quiz_attempts row or a 'completed'
-- progress status can be created. It reads correct_index from quiz_questions
-- (bypassing RLS as a security-definer function owned by the table owner),
-- compares it against the learner's submitted answers, and writes the result
-- itself. The client never sees correct_index and can never set passed=true
-- by writing to the tables directly (see the RLS section: there is no INSERT
-- policy on progress or quiz_attempts for the authenticated role).
create or replace function public.grade_quiz(
  p_module_slug text,
  p_answers int[],
  p_time_taken_seconds int default 0
)
returns table (score_percent numeric, passed boolean, correct_count int, total_count int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pass_mark int;
  v_correct_answers int[];
  v_total int;
  v_correct int := 0;
  i int;
begin
  select pass_mark_percent into v_pass_mark from modules where slug = p_module_slug;
  if v_pass_mark is null then
    raise exception 'Unknown module %', p_module_slug;
  end if;

  select array_agg(correct_index order by sort_order) into v_correct_answers
    from quiz_questions where module_slug = p_module_slug;
  v_total := coalesce(array_length(v_correct_answers, 1), 0);
  if v_total = 0 then
    raise exception 'No quiz questions for module %', p_module_slug;
  end if;

  for i in 1..v_total loop
    if p_answers[i] = v_correct_answers[i] then
      v_correct := v_correct + 1;
    end if;
  end loop;

  score_percent := round((v_correct::numeric / v_total) * 100);
  passed := score_percent >= v_pass_mark;
  correct_count := v_correct;
  total_count := v_total;

  insert into quiz_attempts (user_id, module_slug, score_percent, passed, time_taken_seconds)
  values (auth.uid(), p_module_slug, score_percent, passed, greatest(coalesce(p_time_taken_seconds, 0), 0));

  if passed then
    perform public.mark_module_complete(p_module_slug);
  else
    insert into progress (user_id, module_slug, status, started_at)
    values (auth.uid(), p_module_slug, 'in_progress', now())
    on conflict (user_id, module_slug) do update
      set status = case when progress.status = 'completed' then progress.status else 'in_progress' end;
  end if;

  return next;
end;
$$;

grant execute on function public.track_module_time(text, int) to authenticated;
grant execute on function public.grade_quiz(text, int[], int) to authenticated;
grant execute on function public.is_admin() to authenticated;
-- mark_module_complete is intentionally NOT granted to authenticated: it is
-- only ever called internally by grade_quiz (as the security-definer owner),
-- never directly by the client, so a learner cannot self-mark a module done.

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table stores enable row level security;
alter table profiles enable row level security;
alter table courses enable row level security;
alter table modules enable row level security;
alter table progress enable row level security;
alter table quiz_attempts enable row level security;
alter table quiz_questions enable row level security;
-- No policies on quiz_questions for authenticated/anon: direct reads of this
-- table (which would include correct_index) are denied outright. The app
-- reads quiz_questions_public instead (see above).

-- stores: any signed-in user can read; only admins can write
drop policy if exists "stores_select" on stores;
create policy "stores_select" on stores for select using (auth.role() = 'authenticated');
drop policy if exists "stores_write" on stores;
create policy "stores_write" on stores for all using (public.is_admin()) with check (public.is_admin());

-- profiles: a learner can see/update their own profile; admins can see/update all
drop policy if exists "profiles_select_own" on profiles;
create policy "profiles_select_own" on profiles for select using (id = auth.uid() or public.is_admin());
drop policy if exists "profiles_update_own" on profiles;
create policy "profiles_update_own" on profiles for update using (id = auth.uid() or public.is_admin());
drop policy if exists "profiles_admin_insert" on profiles;
create policy "profiles_admin_insert" on profiles for insert with check (public.is_admin() or id = auth.uid());

-- courses / modules: readable by any signed-in learner; writable by admins only
drop policy if exists "courses_select" on courses;
create policy "courses_select" on courses for select using (auth.role() = 'authenticated');
drop policy if exists "courses_write" on courses;
create policy "courses_write" on courses for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "modules_select" on modules;
create policy "modules_select" on modules for select using (auth.role() = 'authenticated');
drop policy if exists "modules_write" on modules;
create policy "modules_write" on modules for all using (public.is_admin()) with check (public.is_admin());

-- progress: a learner can see only their own rows; admins see all.
-- Deliberately NO insert/update policy for the client: all writes go through
-- track_module_time() / grade_quiz() (security definer, bypasses RLS), so a
-- learner cannot POST their own 'completed' status or inflate time spent by
-- writing to this table directly via the API.
drop policy if exists "progress_select" on progress;
create policy "progress_select" on progress for select using (user_id = auth.uid() or public.is_admin());
drop policy if exists "progress_insert" on progress;
drop policy if exists "progress_update" on progress;

-- quiz_attempts: a learner can see only their own rows; admins see all.
-- Deliberately NO insert policy: attempts are only ever written by
-- grade_quiz(), so a learner cannot forge a passing attempt.
drop policy if exists "quiz_attempts_select" on quiz_attempts;
create policy "quiz_attempts_select" on quiz_attempts for select using (user_id = auth.uid() or public.is_admin());
drop policy if exists "quiz_attempts_insert" on quiz_attempts;

-- ---------------------------------------------------------------------------
-- After running this file: promote your own account to admin, e.g.
--   update profiles set role = 'admin' where id = 'YOUR-AUTH-USER-UUID';
-- See README.md for the full walkthrough.
-- ---------------------------------------------------------------------------
