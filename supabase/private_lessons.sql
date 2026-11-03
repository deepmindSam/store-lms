-- Run after schema.sql. Lesson text is stored in Postgres, never in GitHub Pages.
-- Re-running this migration leaves existing lesson rows intact.

create table if not exists public.lesson_content (
  module_slug text primary key references public.modules (slug) on delete cascade,
  markdown text not null,
  is_published boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.lesson_content enable row level security;

-- A signed-in learner can read published lessons. Admins can also preview drafts.
-- SQL Editor/database owners manage content; the browser has no write grant.
drop policy if exists "lesson_content_read" on public.lesson_content;
create policy "lesson_content_read" on public.lesson_content
  for select to authenticated
  using (is_published or public.is_admin());

revoke all on public.lesson_content from public, anon, authenticated;
grant select on public.lesson_content to authenticated;
