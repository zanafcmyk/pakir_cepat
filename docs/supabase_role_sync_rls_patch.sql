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

create or replace function public.app_admin_provider_verification_requests()
returns table (
  request_id uuid,
  provider_id uuid,
  profile_id uuid,
  full_name text,
  email text,
  phone_number text,
  parking_name text,
  address text,
  photo_url text,
  location_label text,
  capacity integer,
  identity_document_url text,
  status public.account_status,
  created_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select
    coalesce(application.id, provider.id) as request_id,
    provider.id as provider_id,
    profile.id as profile_id,
    profile.full_name,
    profile.email,
    profile.phone_number,
    coalesce(application.parking_name, provider.business_name, 'Lahan parkir') as parking_name,
    coalesce(application.address, provider.business_address, '-') as address,
    application.photo_url,
    application.location_label,
    coalesce(application.capacity, 0) as capacity,
    coalesce(application.identity_document_url, provider.identity_document_url) as identity_document_url,
    case
      when profile.account_status in ('pending', 'rejected') then profile.account_status
      when provider.status in ('pending', 'rejected') then provider.status
      when application.status in ('pending', 'rejected') then application.status
      else coalesce(application.status, provider.status, profile.account_status)
    end as status,
    coalesce(application.created_at, provider.created_at, profile.created_at) as created_at
  from public.providers provider
  join public.profiles profile on profile.id = provider.profile_id
  left join lateral (
    select item.*
    from public.provider_applications item
    where item.provider_id = provider.id
       or item.profile_id = provider.profile_id
    order by item.created_at desc
    limit 1
  ) application on true
  where public.is_super_admin()
    and profile.role = 'provider'
    and (
      profile.account_status in ('pending', 'rejected')
      or provider.status in ('pending', 'rejected')
      or application.status in ('pending', 'rejected')
    )
  order by coalesce(application.created_at, provider.created_at, profile.created_at) desc;
$$;

create or replace function public.app_admin_update_provider_verification(
  p_profile_id uuid,
  p_status public.account_status,
  p_review_note text default null
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
begin
  if not public.is_super_admin() then
    raise exception 'Only super admin can verify provider accounts.';
  end if;

  select provider.id
  into v_provider_id
  from public.providers provider
  where provider.profile_id = p_profile_id
  limit 1;

  update public.profiles
  set
    account_status = p_status,
    verified_at = case when p_status = 'verified' then now() else null end,
    updated_at = now()
  where id = p_profile_id
    and role = 'provider';

  update public.providers
  set
    status = p_status,
    approved_by = auth.uid(),
    approved_at = case when p_status = 'verified' then now() else null end,
    rejection_reason = case
      when p_status = 'rejected' then coalesce(nullif(trim(p_review_note), ''), 'Ditolak oleh Super Admin.')
      else null
    end,
    updated_at = now()
  where profile_id = p_profile_id;

  update public.provider_applications
  set
    status = p_status,
    reviewed_by = auth.uid(),
    reviewed_at = now(),
    review_note = case
      when p_status = 'verified' then coalesce(nullif(trim(p_review_note), ''), 'Disetujui oleh Super Admin.')
      when p_status = 'rejected' then coalesce(nullif(trim(p_review_note), ''), 'Ditolak oleh Super Admin.')
      else p_review_note
    end,
    updated_at = now()
  where profile_id = p_profile_id
     or (v_provider_id is not null and provider_id = v_provider_id);

  return found or v_provider_id is not null;
end;
$$;

grant execute on function public.app_admin_provider_verification_requests() to authenticated;
grant execute on function public.app_admin_update_provider_verification(uuid, public.account_status, text) to authenticated;

-- The booking RPC and its table-write restrictions now live in
-- docs/supabase_booking_payment_security_patch.sql. Never restore the old
-- eight-argument function because it trusted price values from the client.
drop function if exists public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer, integer, integer
);

create or replace function public.app_provider_add_parking_slot(
  p_parking_lot_id uuid
)
returns table (
  slot_id uuid,
  slot_label text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_next_number integer;
  v_label text;
begin
  if auth.uid() is null then
    raise exception 'Provider session is required.';
  end if;

  select provider.id
  into v_provider_id
  from public.providers provider
  where provider.profile_id = auth.uid()
  limit 1;

  if v_provider_id is null and not public.is_super_admin() then
    raise exception 'Provider profile was not found.';
  end if;

  if not exists (
    select 1
    from public.parking_lots lot
    where lot.id = p_parking_lot_id
      and (lot.provider_id = v_provider_id or public.is_super_admin())
  ) then
    raise exception 'Parking lot is not owned by current provider.';
  end if;

  select coalesce(count(*), 0)::integer + 1
  into v_next_number
  from public.parking_slots slot
  where slot.parking_lot_id = p_parking_lot_id;

  loop
    v_label := 'A-' || lpad(v_next_number::text, 2, '0');
    exit when not exists (
      select 1
      from public.parking_slots slot
      where slot.parking_lot_id = p_parking_lot_id
        and slot.label = v_label
    );
    v_next_number := v_next_number + 1;
  end loop;

  insert into public.parking_slots (
    parking_lot_id,
    label,
    status
  )
  values (
    p_parking_lot_id,
    v_label,
    'available'
  )
  returning id, label into slot_id, slot_label;

  update public.parking_lots
  set total_slots = coalesce(total_slots, 0) + 1,
      updated_at = now()
  where id = p_parking_lot_id;

  return next;
end;
$$;

grant execute on function public.app_provider_add_parking_slot(uuid) to authenticated;
