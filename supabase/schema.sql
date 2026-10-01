-- Run once in the Supabase SQL Editor for this project.
create table if not exists public.user_state (
  user_id uuid primary key references auth.users (id) on delete cascade,
  payload jsonb not null default '{"medicines": [], "taken": {}}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint user_state_payload_is_object check (jsonb_typeof(payload) = 'object')
);

alter table public.user_state enable row level security;

revoke all on table public.user_state from anon, authenticated;
grant select, insert, update on table public.user_state to authenticated;

drop policy if exists "Users can read their own medication data" on public.user_state;
create policy "Users can read their own medication data"
  on public.user_state for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own medication data" on public.user_state;
create policy "Users can create their own medication data"
  on public.user_state for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own medication data" on public.user_state;
create policy "Users can update their own medication data"
  on public.user_state for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
