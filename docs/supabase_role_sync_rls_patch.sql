-- Parkir Cepat role sync RLS patch.
-- Run this after the main schema and chat/notification SQL files.
--
-- Purpose:
-- 1. Keep profile RLS strict while allowing the app to resolve minimal chat targets.
-- 2. Allow app-generated in-app notifications to be created for the correct target
--    profile/role without exposing broad write access to the notifications table.

create or replace function public.app_active_profiles_by_role(p_role public.account_role)
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.profiles profile
  where profile.role = p_role
    and profile.access_status = 'active'
  order by profile.created_at;
$$;

create or replace function public.app_provider_profile_for_lot(p_parking_lot_id uuid)
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.parking_lots lot
  join public.providers provider on provider.id = lot.provider_id
  join public.profiles profile on profile.id = provider.profile_id
  where lot.id = p_parking_lot_id
    and profile.access_status = 'active';
$$;

create or replace function public.app_guard_profiles_for_ticket(p_ticket_number text)
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.bookings booking
  join public.guard_lot_assignments assignment
    on assignment.parking_lot_id = booking.parking_lot_id
  join public.parking_guards guard on guard.id = assignment.guard_id
  join public.profiles profile on profile.id = guard.profile_id
  where booking.ticket_number = upper(trim(p_ticket_number))
    and profile.access_status = 'active';
$$;

create or replace function public.app_customer_profile_for_ticket(p_ticket_number text)
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.bookings booking
  join public.customers customer on customer.id = booking.customer_id
  join public.profiles profile on profile.id = customer.profile_id
  where booking.ticket_number = upper(trim(p_ticket_number))
    and profile.access_status = 'active';
$$;

create or replace function public.app_current_provider_guard_profiles()
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.providers provider
  join public.parking_guards guard on guard.provider_id = provider.id
  join public.profiles profile on profile.id = guard.profile_id
  where provider.profile_id = auth.uid()
    and profile.access_status = 'active';
$$;

create or replace function public.app_current_guard_provider_profile()
returns table (
  id uuid,
  full_name text,
  role public.account_role,
  access_status public.user_access_status
)
language sql
security definer
set search_path = public
stable
as $$
  select profile.id, profile.full_name, profile.role, profile.access_status
  from public.parking_guards guard
  join public.providers provider on provider.id = guard.provider_id
  join public.profiles profile on profile.id = provider.profile_id
  where guard.profile_id = auth.uid()
    and profile.access_status = 'active';
$$;

create or replace function public.app_create_notification(
  p_profile_id uuid,
  p_title text,
  p_message text,
  p_type text default 'info'
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    return false;
  end if;

  insert into public.notifications (profile_id, title, message, type)
  select profile.id, p_title, p_message, coalesce(nullif(trim(p_type), ''), 'info')
  from public.profiles profile
  where profile.id = p_profile_id
    and profile.access_status = 'active';

  return found;
end;
$$;

create or replace function public.app_create_notifications_for_role(
  p_role public.account_role,
  p_title text,
  p_message text,
  p_type text default 'info'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer := 0;
begin
  if auth.uid() is null then
    return 0;
  end if;

  insert into public.notifications (profile_id, title, message, type)
  select profile.id, p_title, p_message, coalesce(nullif(trim(p_type), ''), 'info')
  from public.profiles profile
  where profile.role = p_role
    and profile.access_status = 'active';

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

create or replace function public.app_create_provider_notification(
  p_provider_id uuid,
  p_title text,
  p_message text,
  p_type text default 'info'
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    return false;
  end if;

  insert into public.notifications (profile_id, title, message, type)
  select profile.id, p_title, p_message, coalesce(nullif(trim(p_type), ''), 'info')
  from public.providers provider
  join public.profiles profile on profile.id = provider.profile_id
  where provider.id = p_provider_id
    and profile.access_status = 'active';

  return found;
end;
$$;

create or replace function public.app_create_guard_notifications_for_lot(
  p_parking_lot_id uuid,
  p_title text,
  p_message text,
  p_type text default 'info'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer := 0;
begin
  if auth.uid() is null then
    return 0;
  end if;

  insert into public.notifications (profile_id, title, message, type)
  select profile.id, p_title, p_message, coalesce(nullif(trim(p_type), ''), 'info')
  from public.guard_lot_assignments assignment
  join public.parking_guards guard on guard.id = assignment.guard_id
  join public.profiles profile on profile.id = guard.profile_id
  where assignment.parking_lot_id = p_parking_lot_id
    and profile.access_status = 'active';

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

grant execute on function public.app_active_profiles_by_role(public.account_role) to authenticated;
grant execute on function public.app_provider_profile_for_lot(uuid) to authenticated;
grant execute on function public.app_guard_profiles_for_ticket(text) to authenticated;
grant execute on function public.app_customer_profile_for_ticket(text) to authenticated;
grant execute on function public.app_current_provider_guard_profiles() to authenticated;
grant execute on function public.app_current_guard_provider_profile() to authenticated;
grant execute on function public.app_create_notification(uuid, text, text, text) to authenticated;
grant execute on function public.app_create_notifications_for_role(public.account_role, text, text, text) to authenticated;
grant execute on function public.app_create_provider_notification(uuid, text, text, text) to authenticated;
grant execute on function public.app_create_guard_notifications_for_lot(uuid, text, text, text) to authenticated;
