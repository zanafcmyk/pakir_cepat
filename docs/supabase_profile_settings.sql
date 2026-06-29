-- Profile settings for provider and parking guard accounts.
-- Run this in Supabase SQL Editor after the main schema is applied.

create table if not exists public.profile_settings (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  primary_notification_enabled boolean not null default true,
  secondary_notification_enabled boolean not null default true,
  report_notification_enabled boolean not null default true,
  selected_language text not null default 'Indonesia',
  account_security_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists set_profile_settings_updated_at on public.profile_settings;
create trigger set_profile_settings_updated_at
before update on public.profile_settings
for each row execute function public.set_updated_at();

alter table public.profile_settings enable row level security;

drop policy if exists "profile_settings_owner_or_admin" on public.profile_settings;
create policy "profile_settings_owner_or_admin"
on public.profile_settings for all
using (
  profile_id = auth.uid()
  or public.current_user_role() = 'super_admin'
)
with check (
  profile_id = auth.uid()
  or public.current_user_role() = 'super_admin'
);
