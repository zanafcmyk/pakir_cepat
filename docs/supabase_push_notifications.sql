-- Push notification setup for Parkir Cepat.
-- Run this in Supabase SQL Editor before enabling production FCM.

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  token text not null,
  platform text not null default 'android',
  device_name text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint device_push_tokens_token_unique unique (token)
);

create index if not exists device_push_tokens_profile_idx
on public.device_push_tokens(profile_id);

alter table public.device_push_tokens enable row level security;

drop policy if exists "device_push_tokens_owner_or_admin" on public.device_push_tokens;
create policy "device_push_tokens_owner_or_admin"
on public.device_push_tokens for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());
