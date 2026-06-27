-- ============================================================================
-- PARKIR CEPAT - MASTER PRODUCTION SQL BUNDLE
-- ============================================================================
-- Generated: 2026-06-27
-- Project Ref: wdtjrzynjygkmpmhiffw
-- Branch: codex/parkir-cepat-23mei-2157
--
-- CARA PAKAI:
-- 1. Buka https://supabase.com/dashboard/project/wdtjrzynjygkmpmhiffw/sql
-- 2. Klik "New query"
-- 3. Copy SELURUH isi file ini (Ctrl+A, Ctrl+C)
-- 4. Paste ke SQL Editor
-- 5. Klik "Run" (atau Ctrl+Enter)
-- 6. Tunggu sampai selesai
-- 7. Lihat tab "Messages" untuk hasil
--
-- VERIFIKASI:
-- Setelah semua patch jalan, query di bagian akhir akan menampilkan
-- status OK untuk tabel, kolom, RPC, RLS, policy, trigger, publication,
-- storage bucket, dan cron expiry.
--
-- ROLLBACK:
-- Jika ada patch yang gagal, jalankan hanya blok yang gagal setelah
-- diperbaiki. Setiap patch bersifat idempotent (drop before create).
-- ============================================================================

-- ============================================================================
-- PATCH 1/10: supabase_role_sync_rls_patch.sql
-- Sinkron role & RLS antar-role
-- ============================================================================
-- SOURCE: docs/supabase_role_sync_rls_patch.sql
-- PURPOSE: Keep profile RLS strict while allowing the app to resolve minimal
--          chat targets, plus admin RPCs for provider verification.

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

-- ============================================================================
-- END OF PATCH 1/10
-- ============================================================================


-- ============================================================================
-- PATCH 2/10: supabase_booking_payment_security_patch.sql
-- Keamanan booking & payment: harga dihitung server, RLS ketat
-- ============================================================================
-- SOURCE: docs/supabase_booking_payment_security_patch.sql
-- PURPOSE: Server-authoritative pricing, RLS on bookings & payments, allow
--          only rpcs to mutate. Keeps runbook integrity for production.

-- Parkir Cepat booking and payment security patch.
-- Run after supabase_schema.sql, supabase_schema_additions.sql,
-- supabase_parking_lot_sync.sql, and supabase_role_sync_rls_patch.sql.
begin;
-- Remove the old RPC because it trusted price and estimated cost from Flutter.
drop function if exists public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer, integer, integer
);
create or replace function public.app_create_customer_booking(
  p_parking_lot_id uuid,
  p_parking_slot_id uuid,
  p_vehicle_plate text,
  p_ticket_number text,
  p_entry_time timestamptz,
  p_duration_hours integer
)
returns table (
  ticket_number text,
  slot_id uuid,
  duration_hours integer,
  effective_rate integer,
  estimated_cost integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_vehicle_id uuid;
  v_vehicle_kind public.vehicle_kind;
  v_slot_status public.parking_slot_status;
  v_tariff_type text;
  v_base_rate integer;
  v_motor_rate integer;
  v_car_rate integer;
  v_truck_rate integer;
  v_effective_rate integer;
  v_estimated_cost integer;
  v_ticket_number text;
begin
  if auth.uid() is null then
    raise exception 'Customer session is required.';
  end if;
  if p_duration_hours is null or p_duration_hours <= 0 then
    raise exception 'Parking duration must be greater than zero.';
  end if;
  v_ticket_number := upper(trim(coalesce(p_ticket_number, '')));
  if v_ticket_number !~ '^TKT-[A-Z0-9-]{6,}$' then
    raise exception 'Ticket number format is invalid.';
  end if;
  select customer.id
  into v_customer_id
  from public.customers customer
  join public.profiles profile on profile.id = customer.profile_id
  where customer.profile_id = auth.uid()
    and profile.role = 'customer'
    and profile.access_status = 'active'
  limit 1;
  if v_customer_id is null then
    raise exception 'Active customer profile was not found.';
  end if;
  select vehicle.id, vehicle.kind
  into v_vehicle_id, v_vehicle_kind
  from public.vehicles vehicle
  where vehicle.customer_id = v_customer_id
    and upper(trim(vehicle.plate_number)) = upper(trim(p_vehicle_plate))
  limit 1;
  if v_vehicle_id is null then
    raise exception 'Vehicle was not found.';
  end if;
  select
    lot.tariff_type::text,
    lot.price_per_hour,
    lot.motor_rate,
    lot.car_rate,
    lot.truck_rate
  into
    v_tariff_type,
    v_base_rate,
    v_motor_rate,
    v_car_rate,
    v_truck_rate
  from public.parking_lots lot
  where lot.id = p_parking_lot_id
    and lot.is_active = true
  limit 1;
  if not found then
    raise exception 'Active parking lot was not found.';
  end if;
  v_effective_rate := case v_vehicle_kind
    when 'motor' then nullif(v_motor_rate, 0)
    when 'truk' then nullif(v_truck_rate, 0)
    else nullif(v_car_rate, 0)
  end;
  v_effective_rate := coalesce(v_effective_rate, v_base_rate, 0);
  if v_effective_rate <= 0 then
    raise exception 'Parking tariff is not configured.';
  end if;
  v_estimated_cost := case v_tariff_type
    when 'flat' then v_effective_rate
    when 'daily' then
      v_effective_rate * greatest(1, ceil(p_duration_hours::numeric / 24)::integer)
    else v_effective_rate * p_duration_hours
  end;
  select slot.status
  into v_slot_status
  from public.parking_slots slot
  where slot.id = p_parking_slot_id
    and slot.parking_lot_id = p_parking_lot_id
  for update;
  if v_slot_status is null then
    raise exception 'Parking slot was not found.';
  end if;
  if v_slot_status <> 'available' then
    raise exception 'Parking slot is no longer available.';
  end if;
  update public.parking_slots
  set status = 'reserved', updated_at = now()
  where id = p_parking_slot_id;
  insert into public.bookings (
    ticket_number,
    customer_id,
    vehicle_id,
    parking_lot_id,
    parking_slot_id,
    entry_time,
    duration_hours,
    price_per_hour,
    estimated_cost,
    status,
    qr_payload
  )
  values (
    v_ticket_number,
    v_customer_id,
    v_vehicle_id,
    p_parking_lot_id,
    p_parking_slot_id,
    p_entry_time,
    p_duration_hours,
    v_effective_rate,
    v_estimated_cost,
    'pending_payment',
    'PARKIRCEPAT|ENTRY_EXIT|' || v_ticket_number
  );
  return query
  select
    v_ticket_number,
    p_parking_slot_id,
    p_duration_hours,
    v_effective_rate,
    v_estimated_cost;
end;
$$;
drop function if exists public.app_guard_confirm_cash_payment(text);
create or replace function public.app_operator_confirm_cash_payment(
  p_ticket_number text
)
returns table (
  payment_id uuid,
  amount integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_guard_id uuid;
  v_provider_id uuid;
  v_actor_role public.account_role;
  v_booking public.bookings%rowtype;
  v_payment_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Operator session is required.';
  end if;
  select profile.role
  into v_actor_role
  from public.profiles profile
  where profile.id = auth.uid()
    and profile.access_status = 'active'
  limit 1;
  if v_actor_role is null then
    raise exception 'Active operator profile was not found.';
  end if;
  select booking.*
  into v_booking
  from public.bookings booking
  where booking.ticket_number = upper(trim(p_ticket_number))
  for update;
  if v_booking.id is null then
    raise exception 'Booking was not found.';
  end if;
  if v_actor_role = 'parking_guard' then
    select guard.id
    into v_guard_id
    from public.parking_guards guard
    where guard.profile_id = auth.uid()
      and guard.can_confirm_cash = true
    limit 1;
    if v_guard_id is null or not exists (
      select 1
      from public.guard_lot_assignments assignment
      where assignment.guard_id = v_guard_id
        and assignment.parking_lot_id = v_booking.parking_lot_id
    ) then
      raise exception 'Guard is not allowed to confirm cash for this lot.';
    end if;
  elsif v_actor_role = 'provider' then
    select provider.id
    into v_provider_id
    from public.providers provider
    where provider.profile_id = auth.uid()
      and provider.status = 'verified'
    limit 1;
    if v_provider_id is null or not exists (
      select 1
      from public.parking_lots lot
      where lot.id = v_booking.parking_lot_id
        and lot.provider_id = v_provider_id
        and lot.is_active = true
    ) then
      raise exception 'Provider does not own this active parking lot.';
    end if;
    if exists (
      select 1
      from public.guard_lot_assignments assignment
      join public.parking_guards guard on guard.id = assignment.guard_id
      join public.profiles profile on profile.id = guard.profile_id
      where assignment.parking_lot_id = v_booking.parking_lot_id
        and profile.access_status = 'active'
    ) then
      raise exception 'An active guard is assigned to this parking lot.';
    end if;
  else
    raise exception 'Only guards or providers can confirm cash payments.';
  end if;
  if v_booking.status <> 'pending_payment' then
    raise exception 'Booking is not waiting for payment.';
  end if;
  insert into public.payments (
    booking_id,
    customer_id,
    method,
    status,
    amount,
    provider_reference,
    paid_at,
    confirmed_by_guard_id
  )
  values (
    v_booking.id,
    v_booking.customer_id,
    'cash',
    'paid',
    v_booking.estimated_cost,
    'CASH-' || v_booking.ticket_number || '-' || extract(epoch from now())::bigint,
    now(),
    v_guard_id
  )
  returning id into v_payment_id;
  update public.bookings
  set
    status = 'paid',
    final_cost = v_booking.estimated_cost,
    updated_at = now()
  where id = v_booking.id;
  insert into public.receipts (
    booking_id,
    payment_id,
    receipt_number,
    issued_by
  )
  values (
    v_booking.id,
    v_payment_id,
    'RCT-' || v_booking.ticket_number,
    auth.uid()
  )
  on conflict (booking_id) do update
  set
    payment_id = excluded.payment_id,
    issued_by = excluded.issued_by,
    issued_at = now(),
    updated_at = now();
  insert into public.parking_activity_logs (
    booking_id,
    parking_lot_id,
    parking_slot_id,
    guard_id,
    actor_profile_id,
    action,
    note
  )
  values (
    v_booking.id,
    v_booking.parking_lot_id,
    v_booking.parking_slot_id,
    v_guard_id,
    auth.uid(),
    'cash_confirm',
    case v_actor_role
      when 'provider' then 'Pembayaran tunai dikonfirmasi operator penyedia.'
      else 'Pembayaran tunai dikonfirmasi penjaga.'
    end
  );
  return query select v_payment_id, v_booking.estimated_cost;
end;
$$;
drop function if exists public.app_guard_process_ticket(text, text);
create or replace function public.app_operator_process_ticket(
  p_ticket_number text,
  p_action text
)
returns table (
  ticket_number text,
  booking_status public.booking_status,
  slot_status public.parking_slot_status
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_guard_id uuid;
  v_provider_id uuid;
  v_actor_role public.account_role;
  v_booking public.bookings%rowtype;
  v_action text := lower(trim(coalesce(p_action, '')));
  v_booking_status public.booking_status;
  v_slot_status public.parking_slot_status;
begin
  if auth.uid() is null then
    raise exception 'Operator session is required.';
  end if;
  if v_action not in ('check_in', 'check_out') then
    raise exception 'Ticket action is invalid.';
  end if;
  select profile.role
  into v_actor_role
  from public.profiles profile
  where profile.id = auth.uid()
    and profile.access_status = 'active'
  limit 1;
  if v_actor_role is null then
    raise exception 'Active operator profile was not found.';
  end if;
  select booking.*
  into v_booking
  from public.bookings booking
  where booking.ticket_number = upper(trim(p_ticket_number))
  for update;
  if v_booking.id is null then
    raise exception 'Booking was not found.';
  end if;
  if v_actor_role = 'parking_guard' then
    select guard.id
    into v_guard_id
    from public.parking_guards guard
    where guard.profile_id = auth.uid()
      and guard.can_scan_qr = true
    limit 1;
    if v_guard_id is null or not exists (
      select 1
      from public.guard_lot_assignments assignment
      where assignment.guard_id = v_guard_id
        and assignment.parking_lot_id = v_booking.parking_lot_id
    ) then
      raise exception 'Guard is not allowed to scan tickets for this lot.';
    end if;
  elsif v_actor_role = 'provider' then
    select provider.id
    into v_provider_id
    from public.providers provider
    where provider.profile_id = auth.uid()
      and provider.status = 'verified'
    limit 1;
    if v_provider_id is null or not exists (
      select 1
      from public.parking_lots lot
      where lot.id = v_booking.parking_lot_id
        and lot.provider_id = v_provider_id
        and lot.is_active = true
    ) then
      raise exception 'Provider does not own this active parking lot.';
    end if;
    if exists (
      select 1
      from public.guard_lot_assignments assignment
      join public.parking_guards guard on guard.id = assignment.guard_id
      join public.profiles profile on profile.id = guard.profile_id
      where assignment.parking_lot_id = v_booking.parking_lot_id
        and profile.access_status = 'active'
    ) then
      raise exception 'An active guard is assigned to this parking lot.';
    end if;
  else
    raise exception 'Only guards or providers can process parking tickets.';
  end if;
  if v_action = 'check_in' then
    if v_booking.status <> 'paid' then
      raise exception 'Only paid bookings can check in.';
    end if;
    v_booking_status := 'active';
    v_slot_status := 'occupied';
    update public.bookings
    set
      status = v_booking_status,
      checked_in_at = now(),
      checked_in_by = v_guard_id,
      updated_at = now()
    where id = v_booking.id;
  else
    if v_booking.status <> 'active' then
      raise exception 'Only active bookings can check out.';
    end if;
    v_booking_status := 'completed';
    v_slot_status := 'available';
    update public.bookings
    set
      status = v_booking_status,
      exit_time = now(),
      checked_out_at = now(),
      checked_out_by = v_guard_id,
      updated_at = now()
    where id = v_booking.id;
  end if;
  if v_booking.parking_slot_id is not null then
    update public.parking_slots
    set status = v_slot_status, updated_at = now()
    where id = v_booking.parking_slot_id
      and parking_lot_id = v_booking.parking_lot_id;
  end if;
  insert into public.parking_activity_logs (
    booking_id,
    parking_lot_id,
    parking_slot_id,
    guard_id,
    actor_profile_id,
    action,
    note
  )
  values (
    v_booking.id,
    v_booking.parking_lot_id,
    v_booking.parking_slot_id,
    v_guard_id,
    auth.uid(),
    v_action::public.parking_activity_action,
    case
      when v_actor_role = 'provider' and v_action = 'check_in'
        then 'Kendaraan masuk diverifikasi operator penyedia.'
      when v_actor_role = 'provider' and v_action = 'check_out'
        then 'Kendaraan keluar dikonfirmasi operator penyedia.'
      when v_action = 'check_in'
        then 'Kendaraan masuk diverifikasi dari scan QR.'
      else 'Kendaraan keluar dikonfirmasi dari scan QR.'
    end
  );
  return query
  select v_booking.ticket_number, v_booking_status, v_slot_status;
end;
$$;
-- Remove all broad policies and replace them with read-only relationship checks.
do $$
declare
  policy_row record;
begin
  for policy_row in
    select tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in ('bookings', 'payments')
  loop
    execute format(
      'drop policy if exists %I on public.%I',
      policy_row.policyname,
      policy_row.tablename
    );
  end loop;
end;
$$;
create policy "bookings_related_select"
on public.bookings for select
to authenticated
using (
  customer_id = public.current_customer_id()
  or public.is_provider_lot(parking_lot_id)
  or public.is_guard_assigned_to_lot(parking_lot_id)
  or public.is_super_admin()
);
create policy "payments_related_select"
on public.payments for select
to authenticated
using (
  customer_id = public.current_customer_id()
  or exists (
    select 1
    from public.bookings booking
    where booking.id = payments.booking_id
      and (
        public.is_provider_lot(booking.parking_lot_id)
        or public.is_guard_assigned_to_lot(booking.parking_lot_id)
      )
  )
  or public.is_super_admin()
);
revoke insert, update, delete, truncate on public.bookings
from public, anon, authenticated;
revoke insert, update, delete, truncate on public.payments
from public, anon, authenticated;
grant select on public.bookings to authenticated;
grant select on public.payments to authenticated;
revoke all on function public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer
) from public, anon;
revoke all on function public.app_operator_confirm_cash_payment(text)
from public, anon;
revoke all on function public.app_operator_process_ticket(text, text)
from public, anon;
grant execute on function public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer
) to authenticated;
grant execute on function public.app_operator_confirm_cash_payment(text)
to authenticated;
grant execute on function public.app_operator_process_ticket(text, text)
to authenticated;
commit;

-- ============================================================================
-- END OF PATCH 2/10
-- ============================================================================


-- ============================================================================
-- PATCH 3/10: supabase_booking_extension_patch.sql
-- Perpanjang durasi booking (extend hour) oleh customer
-- ============================================================================
-- SOURCE: docs/supabase_booking_extension_patch.sql
-- PURPOSE: Server-side duration extension with re-priced booking and
--          unpaid-amount calculation.

-- Adds server-side duration extension and unpaid-amount calculation support.
-- Run this after docs/supabase_booking_payment_security_patch.sql.
begin;
create or replace function public.app_extend_customer_booking(
  p_ticket_number text,
  p_additional_hours integer
)
returns table (
  ticket_number text,
  duration_hours integer,
  effective_rate integer,
  estimated_cost integer,
  amount_due integer,
  additional_cost integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_booking public.bookings%rowtype;
  v_vehicle_kind public.vehicle_kind;
  v_tariff_type text;
  v_base_rate integer;
  v_motor_rate integer;
  v_car_rate integer;
  v_truck_rate integer;
  v_effective_rate integer;
  v_new_duration integer;
  v_new_estimated_cost integer;
  v_paid_total integer;
  v_amount_due integer;
  v_additional_cost integer;
begin
  if auth.uid() is null then
    raise exception 'Customer session is required.';
  end if;
  if p_additional_hours is null or p_additional_hours <= 0 then
    raise exception 'Additional duration must be greater than zero.';
  end if;
  select booking.*
  into v_booking
  from public.bookings booking
  where booking.ticket_number = upper(trim(p_ticket_number))
    and booking.customer_id = public.current_customer_id()
  for update;
  if v_booking.id is null then
    raise exception 'Booking was not found.';
  end if;
  if v_booking.status not in ('pending_payment', 'paid', 'active') then
    raise exception 'Only active reservations can be extended.';
  end if;
  select vehicle.kind
  into v_vehicle_kind
  from public.vehicles vehicle
  where vehicle.id = v_booking.vehicle_id
  limit 1;
  select
    lot.tariff_type::text,
    lot.price_per_hour,
    lot.motor_rate,
    lot.car_rate,
    lot.truck_rate
  into
    v_tariff_type,
    v_base_rate,
    v_motor_rate,
    v_car_rate,
    v_truck_rate
  from public.parking_lots lot
  where lot.id = v_booking.parking_lot_id
    and lot.is_active = true
  limit 1;
  if not found then
    raise exception 'Active parking lot was not found.';
  end if;
  v_effective_rate := case v_vehicle_kind
    when 'motor' then nullif(v_motor_rate, 0)
    when 'truk' then nullif(v_truck_rate, 0)
    else nullif(v_car_rate, 0)
  end;
  v_effective_rate := coalesce(v_effective_rate, v_base_rate, 0);
  if v_effective_rate <= 0 then
    raise exception 'Parking tariff is not configured.';
  end if;
  v_new_duration := v_booking.duration_hours + p_additional_hours;
  v_new_estimated_cost := case v_tariff_type
    when 'flat' then v_effective_rate
    when 'daily' then
      v_effective_rate * greatest(1, ceil(v_new_duration::numeric / 24)::integer)
    else v_effective_rate * v_new_duration
  end;
  v_additional_cost := greatest(0, v_new_estimated_cost - v_booking.estimated_cost);
  select coalesce(sum(payment.amount), 0)
  into v_paid_total
  from public.payments payment
  where payment.booking_id = v_booking.id
    and payment.status = 'paid';
  v_amount_due := greatest(0, v_new_estimated_cost - v_paid_total);
  update public.bookings
  set
    duration_hours = v_new_duration,
    price_per_hour = v_effective_rate,
    estimated_cost = v_new_estimated_cost,
    updated_at = now()
  where id = v_booking.id;
  insert into public.parking_activity_logs (
    booking_id,
    parking_lot_id,
    parking_slot_id,
    actor_profile_id,
    action,
    note
  )
  values (
    v_booking.id,
    v_booking.parking_lot_id,
    v_booking.parking_slot_id,
    auth.uid(),
    'slot_update',
    'Durasi booking diperpanjang ' || p_additional_hours || ' jam.'
  );
  return query
  select
    v_booking.ticket_number,
    v_new_duration,
    v_effective_rate,
    v_new_estimated_cost,
    v_amount_due,
    v_additional_cost;
end;
$$;
revoke all on function public.app_extend_customer_booking(text, integer)
from public, anon;
grant execute on function public.app_extend_customer_booking(text, integer)
to authenticated;
commit;

-- ============================================================================
-- END OF PATCH 3/10
-- ============================================================================


-- ============================================================================
-- PATCH 4/10: supabase_guard_assignment_validation.sql
-- Validasi assignment penjaga agar tidak bisa scan tiket di lahan salah
-- ============================================================================
-- SOURCE: docs/supabase_guard_assignment_validation.sql
-- PURPOSE: Strengthen parking guard assignment validation. Prevents guards from
--          being linked without a valid provider-owned lot, which causes
--          scan errors like "Guard is not allowed to scan tickets for this lot."

-- Strengthen parking guard assignment validation.
-- Run after docs/supabase_guard_accounts.sql.
begin;
create or replace function public.link_parking_guard_by_email(
  p_guard_name text,
  p_guard_email text,
  p_guard_phone text,
  p_parking_lot_ids uuid[],
  p_can_scan_qr boolean default true,
  p_can_confirm_cash boolean default true,
  p_can_manage_slots boolean default false
)
returns table (
  id uuid,
  provider_id uuid,
  name text,
  email text,
  phone_number text,
  assigned_lot_ids uuid[],
  can_scan_qr boolean,
  can_confirm_cash boolean,
  can_manage_slots boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_profile_id uuid;
  v_guard_id uuid;
  v_assignment_count integer;
begin
  v_provider_id := public.current_provider_id();
  if v_provider_id is null then
    raise exception 'Only verified providers can link parking guards.';
  end if;
  if p_parking_lot_ids is null or cardinality(p_parking_lot_ids) = 0 then
    raise exception 'Assign at least one parking lot to this guard.';
  end if;
  select profile.id
  into v_profile_id
  from public.profiles profile
  where lower(profile.email) = lower(trim(p_guard_email))
    and profile.role = 'parking_guard'
  limit 1;
  if v_profile_id is null then
    raise exception 'Parking guard account not found. Ask the guard to register first.';
  end if;
  if not exists (
    select 1
    from public.parking_lots lot
    where lot.provider_id = v_provider_id
      and lot.is_active = true
      and lot.id = any(p_parking_lot_ids)
  ) then
    raise exception 'Selected parking lots do not belong to this provider or are inactive.';
  end if;
  update public.profiles as target_profile
  set
    full_name = coalesce(
      nullif(trim(p_guard_name), ''),
      target_profile.full_name
    ),
    phone_number = coalesce(
      nullif(trim(p_guard_phone), ''),
      target_profile.phone_number
    ),
    account_status = 'verified',
    access_status = 'active',
    verified_at = coalesce(target_profile.verified_at, now())
  where target_profile.id = v_profile_id;
  insert into public.parking_guards (
    profile_id,
    provider_id,
    can_scan_qr,
    can_confirm_cash,
    can_manage_slots
  )
  values (
    v_profile_id,
    v_provider_id,
    p_can_scan_qr,
    p_can_confirm_cash,
    p_can_manage_slots
  )
  on conflict (profile_id) do update
  set
    provider_id = excluded.provider_id,
    can_scan_qr = excluded.can_scan_qr,
    can_confirm_cash = excluded.can_confirm_cash,
    can_manage_slots = excluded.can_manage_slots
  returning parking_guards.id into v_guard_id;
  delete from public.guard_lot_assignments
  where guard_id = v_guard_id;
  insert into public.guard_lot_assignments (guard_id, parking_lot_id)
  select v_guard_id, lot.id
  from public.parking_lots lot
  where lot.provider_id = v_provider_id
    and lot.is_active = true
    and lot.id = any(p_parking_lot_ids)
  on conflict (guard_id, parking_lot_id) do nothing;
  get diagnostics v_assignment_count = row_count;
  if v_assignment_count = 0 then
    raise exception 'Guard was not assigned to any active parking lot.';
  end if;
  return query
  select
    listed.id,
    listed.provider_id,
    listed.name,
    listed.email,
    listed.phone_number,
    listed.assigned_lot_ids,
    listed.can_scan_qr,
    listed.can_confirm_cash,
    listed.can_manage_slots
  from public.list_current_provider_guards() as listed
  where listed.id = v_guard_id;
end;
$$;
grant execute on function public.link_parking_guard_by_email(
  text, text, text, uuid[], boolean, boolean, boolean
) to authenticated;
commit;

-- ============================================================================
-- END OF PATCH 4/10
-- ============================================================================


-- ============================================================================
-- PATCH 5/10: supabase_secure_ticket_qr.sql
-- QR token aman (opaque) - backfill legacy payload
-- ============================================================================
-- SOURCE: docs/supabase_secure_ticket_qr.sql
-- PURPOSE: QR contains opaque random token, not guessable ticket number.
--          Manual TKT-... lookup still works. Legacy payloads backfilled.

-- Secure QR ticket payloads for Parkir Cepat.
-- Run after docs/supabase_booking_payment_security_patch.sql.
begin;
create or replace function public.app_generate_ticket_qr_payload()
returns text
language sql
volatile
as $$
  select 'PARKIRCEPAT|TICKET|v1|'
    || replace(gen_random_uuid()::text, '-', '')
    || replace(gen_random_uuid()::text, '-', '');
$$;
update public.bookings
set
  qr_payload = public.app_generate_ticket_qr_payload(),
  updated_at = now()
where qr_payload is null
  or qr_payload = ''
  or qr_payload = 'PARKIRCEPAT|ENTRY_EXIT|' || ticket_number;
create unique index if not exists bookings_qr_payload_unique_idx
  on public.bookings (qr_payload)
  where qr_payload is not null;
drop function if exists public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer, integer, integer
);
create or replace function public.app_create_customer_booking(
  p_parking_lot_id uuid,
  p_parking_slot_id uuid,
  p_vehicle_plate text,
  p_ticket_number text,
  p_entry_time timestamptz,
  p_duration_hours integer
)
returns table (
  ticket_number text,
  slot_id uuid,
  duration_hours integer,
  effective_rate integer,
  estimated_cost integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_vehicle_id uuid;
  v_vehicle_kind public.vehicle_kind;
  v_slot_status public.parking_slot_status;
  v_tariff_type text;
  v_base_rate integer;
  v_motor_rate integer;
  v_car_rate integer;
  v_truck_rate integer;
  v_effective_rate integer;
  v_estimated_cost integer;
  v_ticket_number text;
begin
  if auth.uid() is null then
    raise exception 'Customer session is required.';
  end if;
  if p_duration_hours is null or p_duration_hours <= 0 then
    raise exception 'Parking duration must be greater than zero.';
  end if;
  v_ticket_number := upper(trim(coalesce(p_ticket_number, '')));
  if v_ticket_number !~ '^TKT-[A-Z0-9-]{6,}$' then
    raise exception 'Ticket number format is invalid.';
  end if;
  select customer.id
  into v_customer_id
  from public.customers customer
  join public.profiles profile on profile.id = customer.profile_id
  where customer.profile_id = auth.uid()
    and profile.role = 'customer'
    and profile.access_status = 'active'
  limit 1;
  if v_customer_id is null then
    raise exception 'Active customer profile was not found.';
  end if;
  select vehicle.id, vehicle.kind
  into v_vehicle_id, v_vehicle_kind
  from public.vehicles vehicle
  where vehicle.customer_id = v_customer_id
    and upper(trim(vehicle.plate_number)) = upper(trim(p_vehicle_plate))
  limit 1;
  if v_vehicle_id is null then
    raise exception 'Vehicle was not found.';
  end if;
  select
    lot.tariff_type::text,
    lot.price_per_hour,
    lot.motor_rate,
    lot.car_rate,
    lot.truck_rate
  into
    v_tariff_type,
    v_base_rate,
    v_motor_rate,
    v_car_rate,
    v_truck_rate
  from public.parking_lots lot
  where lot.id = p_parking_lot_id
    and lot.is_active = true
  limit 1;
  if not found then
    raise exception 'Active parking lot was not found.';
  end if;
  v_effective_rate := case v_vehicle_kind
    when 'motor' then nullif(v_motor_rate, 0)
    when 'truk' then nullif(v_truck_rate, 0)
    else nullif(v_car_rate, 0)
  end;
  v_effective_rate := coalesce(v_effective_rate, v_base_rate, 0);
  if v_effective_rate <= 0 then
    raise exception 'Parking tariff is not configured.';
  end if;
  v_estimated_cost := case v_tariff_type
    when 'flat' then v_effective_rate
    when 'daily' then
      v_effective_rate * greatest(1, ceil(p_duration_hours::numeric / 24)::integer)
    else v_effective_rate * p_duration_hours
  end;
  select slot.status
  into v_slot_status
  from public.parking_slots slot
  where slot.id = p_parking_slot_id
    and slot.parking_lot_id = p_parking_lot_id
  for update;
  if v_slot_status is null then
    raise exception 'Parking slot was not found.';
  end if;
  if v_slot_status <> 'available' then
    raise exception 'Parking slot is no longer available.';
  end if;
  update public.parking_slots
  set status = 'reserved', updated_at = now()
  where id = p_parking_slot_id;
  insert into public.bookings (
    ticket_number,
    customer_id,
    vehicle_id,
    parking_lot_id,
    parking_slot_id,
    entry_time,
    duration_hours,
    price_per_hour,
    estimated_cost,
    status,
    qr_payload
  )
  values (
    v_ticket_number,
    v_customer_id,
    v_vehicle_id,
    p_parking_lot_id,
    p_parking_slot_id,
    p_entry_time,
    p_duration_hours,
    v_effective_rate,
    v_estimated_cost,
    'pending_payment',
    public.app_generate_ticket_qr_payload()
  );
  return query
  select
    v_ticket_number,
    p_parking_slot_id,
    p_duration_hours,
    v_effective_rate,
    v_estimated_cost;
end;
$$;
revoke all on function public.app_generate_ticket_qr_payload() from public;
grant execute on function public.app_generate_ticket_qr_payload() to authenticated;
revoke all on function public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer
) from public;
grant execute on function public.app_create_customer_booking(
  uuid, uuid, text, text, timestamptz, integer
) to authenticated;
commit;

-- ============================================================================
-- END OF PATCH 5/10
-- ============================================================================


-- ============================================================================
-- PATCH 6/10: supabase_booking_expiry.sql
-- Auto-cancel booking pending_payment setelah 30 menit (via pg_cron)
-- ============================================================================
-- SOURCE: docs/supabase_booking_expiry.sql
-- PURPOSE: Auto-cancel unpaid reservations after 30 minutes, release slot,
--          insert activity log and notification. Scheduled by pg_cron every minute.

-- Automatically cancel unpaid parking reservations after 30 minutes.
begin;
create index if not exists bookings_pending_payment_expiry_idx
  on public.bookings (created_at)
  where status = 'pending_payment';
create or replace function public.app_expire_stale_bookings(
  p_limit integer default 200
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_booking record;
  v_expired_count integer := 0;
  v_updated_count integer := 0;
begin
  for v_booking in
    select
      booking.id,
      booking.ticket_number,
      booking.parking_lot_id,
      booking.parking_slot_id,
      customer.profile_id
    from public.bookings booking
    join public.customers customer on customer.id = booking.customer_id
    where booking.status = 'pending_payment'
      and booking.created_at <= now() - interval '30 minutes'
    order by booking.created_at
    for update of booking skip locked
    limit greatest(1, least(coalesce(p_limit, 200), 1000))
  loop
    update public.bookings
    set status = 'cancelled', updated_at = now()
    where id = v_booking.id
      and status = 'pending_payment';
    get diagnostics v_updated_count = row_count;
    if v_updated_count = 0 then
      continue;
    end if;
    update public.payments
    set status = 'cancelled', updated_at = now()
    where booking_id = v_booking.id
      and status = 'pending';
    if v_booking.parking_slot_id is not null then
      update public.parking_slots slot
      set status = 'available', updated_at = now()
      where slot.id = v_booking.parking_slot_id
        and slot.parking_lot_id = v_booking.parking_lot_id
        and slot.status = 'reserved'
        and not exists (
          select 1
          from public.bookings active_booking
          where active_booking.parking_slot_id = slot.id
            and active_booking.id <> v_booking.id
            and active_booking.status in ('pending_payment', 'paid', 'active')
        );
    end if;
    insert into public.parking_activity_logs (
      booking_id,
      parking_lot_id,
      parking_slot_id,
      action,
      note,
      metadata
    )
    values (
      v_booking.id,
      v_booking.parking_lot_id,
      v_booking.parking_slot_id,
      'booking_cancelled',
      'Reservasi otomatis dibatalkan karena pembayaran tidak selesai dalam 30 menit.',
      jsonb_build_object('reason', 'payment_timeout', 'timeout_minutes', 30)
    );
    insert into public.notifications (
      profile_id,
      title,
      message,
      type,
      data
    )
    values (
      v_booking.profile_id,
      'Reservasi berakhir',
      'Reservasi ' || v_booking.ticket_number ||
        ' dibatalkan karena belum dibayar dalam 30 menit. Slot telah tersedia kembali.',
      'booking_expired',
      jsonb_build_object(
        'booking_id', v_booking.id,
        'ticket_number', v_booking.ticket_number,
        'status', 'cancelled'
      )
    );
    v_expired_count := v_expired_count + 1;
  end loop;
  return v_expired_count;
end;
$$;
revoke all on function public.app_expire_stale_bookings(integer)
from public, anon, authenticated;
grant execute on function public.app_expire_stale_bookings(integer)
to service_role;
commit;
create extension if not exists pg_cron;
do $$
declare
  v_job_id bigint;
begin
  for v_job_id in
    select jobid
    from cron.job
    where jobname = 'expire-stale-parking-bookings'
  loop
    perform cron.unschedule(v_job_id);
  end loop;
end;
$$;
select cron.schedule(
  'expire-stale-parking-bookings',
  '* * * * *',
  'select public.app_expire_stale_bookings(200);'
);

-- ============================================================================
-- END OF PATCH 6/10
-- ============================================================================


-- ============================================================================
-- PATCH 7/10: supabase_realtime_guard_operations.sql
-- Aktifkan realtime untuk bookings, payments, guard_lot_assignments
-- ============================================================================
-- SOURCE: docs/supabase_realtime_guard_operations.sql
-- PURPOSE: Customer/guard/provider get live updates on booking & payment
--          without manual refresh.

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'bookings'
  ) then
    alter publication supabase_realtime add table public.bookings;
  end if;
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'payments'
  ) then
    alter publication supabase_realtime add table public.payments;
  end if;
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'guard_lot_assignments'
  ) then
    alter publication supabase_realtime add table public.guard_lot_assignments;
  end if;
end $$;

-- ============================================================================
-- END OF PATCH 7/10
-- ============================================================================


-- ============================================================================
-- PATCH 8/10: supabase_notification_triggers.sql
-- Trigger notifikasi otomatis (booking baru, status, komplain)
-- ============================================================================
-- SOURCE: docs/supabase_notification_triggers.sql
-- PURPOSE: Auto-notify provider/customer/super admin on key events.

-- Optional automation for cross-role notifications.
-- Run this after docs/supabase_schema.sql.
create or replace function public.notify_provider_on_booking_created()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_profile_id uuid;
  v_lot_name text;
begin
  select provider.profile_id, lot.name
  into v_provider_profile_id, v_lot_name
  from public.parking_lots lot
  join public.providers provider on provider.id = lot.provider_id
  where lot.id = new.parking_lot_id;
  if v_provider_profile_id is not null then
    insert into public.notifications (profile_id, title, message, type, data)
    values (
      v_provider_profile_id,
      'Booking baru',
      'Ada booking baru di ' || coalesce(v_lot_name, 'lokasi parkir') || '.',
      'booking',
      jsonb_build_object('booking_id', new.id, 'ticket_number', new.ticket_number)
    );
  end if;
  return new;
end;
$$;
drop trigger if exists notify_provider_on_booking_created on public.bookings;
create trigger notify_provider_on_booking_created
after insert on public.bookings
for each row execute function public.notify_provider_on_booking_created();
create or replace function public.notify_customer_on_booking_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_profile_id uuid;
  v_title text;
  v_message text;
begin
  if old.status = new.status then
    return new;
  end if;
  select customer.profile_id
  into v_customer_profile_id
  from public.customers customer
  where customer.id = new.customer_id;
  if v_customer_profile_id is null then
    return new;
  end if;
  if new.status = 'active' then
    v_title := 'Kendaraan masuk';
    v_message := 'Tiket ' || new.ticket_number || ' sudah diverifikasi masuk.';
  elsif new.status = 'completed' then
    v_title := 'Parkir selesai';
    v_message := 'Tiket ' || new.ticket_number || ' sudah selesai.';
  elsif new.status = 'paid' then
    v_title := 'Pembayaran diterima';
    v_message := 'Tiket ' || new.ticket_number || ' sudah aktif.';
  else
    return new;
  end if;
  insert into public.notifications (profile_id, title, message, type, data)
  values (
    v_customer_profile_id,
    v_title,
    v_message,
    'booking',
    jsonb_build_object('booking_id', new.id, 'ticket_number', new.ticket_number)
  );
  return new;
end;
$$;
drop trigger if exists notify_customer_on_booking_status on public.bookings;
create trigger notify_customer_on_booking_status
after update of status on public.bookings
for each row execute function public.notify_customer_on_booking_status();
create or replace function public.notify_super_admin_on_complaint()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (profile_id, title, message, type, data)
  select
    profile.id,
    'Komplain baru',
    new.title,
    'complaint',
    jsonb_build_object('complaint_id', new.id, 'sender_role', new.sender_role)
  from public.profiles profile
  where profile.role = 'super_admin'
    and profile.access_status = 'active';
  return new;
end;
$$;
drop trigger if exists notify_super_admin_on_complaint on public.complaints;
create trigger notify_super_admin_on_complaint
after insert on public.complaints
for each row execute function public.notify_super_admin_on_complaint();

-- ============================================================================
-- END OF PATCH 8/10
-- ============================================================================


-- ============================================================================
-- PATCH 9/10: supabase_chat_server_sync.sql
-- Server-side chat sync (room members, messages, realtime)
-- ============================================================================
-- SOURCE: docs/supabase_chat_server_sync.sql
-- PURPOSE: Server-authoritative chat rooms, members, and messages.
--          Adds room_key/room_type/last_message columns and helper RPC
--          that resolves correct counterparty profiles per room type.

-- Parkir Cepat server-side chat sync
-- Run in Supabase SQL Editor after docs/supabase_chat_sync.sql.
alter table public.chat_rooms
  add column if not exists room_key text,
  add column if not exists room_type public.chat_room_type not null default 'group',
  add column if not exists last_message text not null default 'Room chat siap digunakan.',
  add column if not exists last_message_at timestamptz not null default now();
alter table public.chat_room_members
  add column if not exists member_role public.account_role,
  add column if not exists display_name text,
  add column if not exists unread_count integer not null default 0 check (unread_count >= 0),
  add column if not exists last_read_at timestamptz;
alter table public.chat_messages
  add column if not exists sender_role public.account_role,
  add column if not exists sender_name text,
  add column if not exists metadata jsonb not null default '{}'::jsonb;
create unique index if not exists chat_rooms_room_key_unique
  on public.chat_rooms(room_key)
  where room_key is not null;
create or replace function public.app_send_chat_message(
  p_room_key text,
  p_room_type text,
  p_title text,
  p_sender_role text,
  p_sender_name text,
  p_target_role text,
  p_target_name text,
  p_message text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_room_id uuid;
  v_context_id text := split_part(p_room_key, ':', 2);
  v_room_type public.chat_room_type := coalesce(nullif(p_room_type, ''), 'group')::public.chat_room_type;
  v_sender_role public.account_role := p_sender_role::public.account_role;
  v_target_role public.account_role := nullif(p_target_role, '')::public.account_role;
begin
  if auth.uid() is null then
    raise exception 'Login required';
  end if;
  insert into public.chat_rooms (
    room_key,
    room_type,
    title,
    created_by,
    last_message,
    last_message_at
  )
  values (
    p_room_key,
    v_room_type,
    p_title,
    auth.uid(),
    p_message,
    now()
  )
  on conflict (room_key) where room_key is not null do update
  set
    title = case
      when excluded.title is not null and btrim(excluded.title) <> ''
        then excluded.title
      else public.chat_rooms.title
    end,
    last_message = excluded.last_message,
    last_message_at = excluded.last_message_at,
    updated_at = now()
  returning id into v_room_id;
  insert into public.chat_room_members (
    room_id,
    profile_id,
    member_role,
    display_name,
    last_read_at
  )
  select
    v_room_id,
    profile.id,
    v_sender_role,
    coalesce(nullif(p_sender_name, ''), profile.full_name),
    now()
  from public.profiles profile
  where profile.id = auth.uid()
  on conflict (room_id, profile_id) do update
  set
    member_role = excluded.member_role,
    display_name = excluded.display_name,
    last_read_at = excluded.last_read_at;
  if v_target_role is not null then
    insert into public.chat_room_members (
      room_id,
      profile_id,
      member_role,
      display_name
    )
    select distinct
      v_room_id,
      target.id,
      target.role,
      coalesce(nullif(p_target_name, ''), target.full_name)
    from public.profiles target
    where target.id <> auth.uid()
      and target.access_status = 'active'
      and (
        (
          v_room_type = 'customer_guard'
          and v_target_role = 'parking_guard'
          and target.role = 'parking_guard'
          and (
            exists (
              select 1
              from public.bookings booking
              join public.guard_lot_assignments assignment
                on assignment.parking_lot_id = booking.parking_lot_id
              join public.parking_guards guard
                on guard.id = assignment.guard_id
              where booking.ticket_number = upper(trim(v_context_id))
                and guard.profile_id = target.id
            )
            or exists (
              select 1
              from public.bookings booking
              join public.parking_lots lot
                on lot.id = booking.parking_lot_id
              join public.parking_guards guard
                on guard.provider_id = lot.provider_id
              where booking.ticket_number = upper(trim(v_context_id))
                and guard.profile_id = target.id
            )
            or not exists (
              select 1
              from public.bookings booking
              join public.guard_lot_assignments assignment
                on assignment.parking_lot_id = booking.parking_lot_id
              where booking.ticket_number = upper(trim(v_context_id))
            )
          )
        )
        or (
          v_room_type = 'customer_guard'
          and v_target_role = 'customer'
          and exists (
            select 1
            from public.bookings booking
            join public.customers customer on customer.id = booking.customer_id
            where booking.ticket_number = upper(trim(v_context_id))
              and customer.profile_id = target.id
          )
        )
        or (
          v_room_type = 'customer_provider'
          and v_target_role = 'provider'
          and exists (
            select 1
            from public.parking_lots lot
            join public.providers provider on provider.id = lot.provider_id
            where lot.id::text = v_context_id
              and provider.profile_id = target.id
          )
        )
        or (
          v_room_type = 'customer_provider'
          and v_target_role = 'customer'
          and exists (
            select 1
            from public.chat_room_members member
            where member.room_id = v_room_id
              and member.profile_id = target.id
              and member.member_role = 'customer'
          )
        )
        or (
          v_room_type = 'provider_guard'
          and v_target_role = 'parking_guard'
          and target.role = 'parking_guard'
          and exists (
            select 1
            from public.providers provider
            join public.parking_guards guard on guard.provider_id = provider.id
            where provider.profile_id = auth.uid()
              and guard.profile_id = target.id
          )
        )
        or (
          v_room_type = 'provider_guard'
          and v_target_role = 'provider'
          and target.role = 'provider'
          and exists (
            select 1
            from public.parking_guards guard
            join public.providers provider on provider.id = guard.provider_id
            where guard.profile_id = auth.uid()
              and provider.profile_id = target.id
          )
        )
        or (
          v_target_role = 'super_admin'
          and target.role = 'super_admin'
        )
        or (
          v_room_type in ('customer_admin', 'provider_admin', 'guard_admin')
          and target.role = v_target_role
        )
      )
    on conflict (room_id, profile_id) do update
    set
      member_role = excluded.member_role,
      display_name = excluded.display_name;
  end if;
  insert into public.chat_messages (
    room_id,
    sender_profile_id,
    sender_role,
    sender_name,
    message
  )
  values (
    v_room_id,
    auth.uid(),
    v_sender_role,
    p_sender_name,
    p_message
  );
  return v_room_id;
end;
$$;
grant execute on function public.app_send_chat_message(
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text
) to authenticated;

-- ============================================================================
-- END OF PATCH 9/10
-- ============================================================================


-- ============================================================================
-- PATCH 10/10: supabase_production_sql_verification.sql
-- Verifikasi akhir - CEK semua patch sudah terpasang dengan benar
-- ============================================================================
-- SOURCE: docs/supabase_production_sql_verification.sql
-- PURPOSE: Read-only health check. Rows with status='MISSING' indicate
--          SQL patches that still need to be run. Safe to run multiple times.
-- NOTE:   The check table uses temp table, so this query can be re-run
--         without leftover state.

-- Production SQL verification for Parkir Cepat.
-- Run this in Supabase SQL Editor. It does not modify production data.
-- Rows with status = 'MISSING' indicate SQL patches that still need to be run.
create temp table if not exists production_sql_verification_check (
  check_name text primary key,
  status text not null,
  detail text
) on commit drop;
truncate table production_sql_verification_check;
create or replace function pg_temp.record_check(
  p_check_name text,
  p_ok boolean,
  p_detail text default null
)
returns void
language plpgsql
as $$
begin
  insert into production_sql_verification_check(check_name, status, detail)
  values (p_check_name, case when p_ok then 'OK' else 'MISSING' end, p_detail)
  on conflict (check_name) do update
  set status = excluded.status,
      detail = excluded.detail;
end;
$$;
-- Core tables from schema/additions.
select pg_temp.record_check(
  'table public.' || table_name,
  to_regclass('public.' || table_name) is not null,
  'Required table'
)
from (values
  ('profiles'),
  ('customers'),
  ('providers'),
  ('provider_applications'),
  ('parking_lots'),
  ('parking_slots'),
  ('parking_guards'),
  ('guard_lot_assignments'),
  ('vehicles'),
  ('bookings'),
  ('payments'),
  ('reviews'),
  ('complaints'),
  ('notifications'),
  ('chat_rooms'),
  ('chat_room_members'),
  ('chat_messages'),
  ('customer_favorite_lots'),
  ('customer_settings'),
  ('parking_activity_logs'),
  ('receipts'),
  ('uploaded_files'),
  ('profile_settings'),
  ('device_push_tokens')
) as required(table_name);
-- Important compatibility columns.
select pg_temp.record_check(
  'column public.' || table_name || '.' || column_name,
  exists (
    select 1
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = required.table_name
      and c.column_name = required.column_name
  ),
  'Required column'
)
from (values
  ('vehicles', 'created_at'),
  ('vehicles', 'updated_at'),
  ('parking_lots', 'photo_url'),
  ('parking_lots', 'latitude'),
  ('parking_lots', 'longitude'),
  ('parking_lots', 'is_active'),
  ('bookings', 'duration_hours'),
  ('bookings', 'final_cost'),
  ('bookings', 'exit_time'),
  ('bookings', 'checked_in_at'),
  ('bookings', 'checked_out_at'),
  ('bookings', 'checked_in_by'),
  ('bookings', 'checked_out_by'),
  ('payments', 'provider_reference'),
  ('payments', 'paid_at'),
  ('profiles', 'access_status'),
  ('profiles', 'avatar_url')
) as required(table_name, column_name);
-- RPC/functions used by Flutter and SQL jobs.
select pg_temp.record_check(
  'function public.' || function_name,
  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = required.function_name
  ),
  'Required RPC/function'
)
from (values
  ('app_create_customer_booking'),
  ('app_operator_confirm_cash_payment'),
  ('app_operator_process_ticket'),
  ('app_extend_customer_booking'),
  ('app_expire_stale_bookings'),
  ('app_repair_parking_slot_statuses'),
  ('app_provider_remove_parking_lot'),
  ('app_simulate_customer_payment'),
  ('app_provider_add_parking_slot'),
  ('app_active_profiles_by_role'),
  ('app_provider_profile_for_lot'),
  ('app_guard_profiles_for_ticket'),
  ('app_customer_profile_for_ticket'),
  ('app_current_provider_guard_profiles'),
  ('app_current_guard_provider_profile'),
  ('app_create_notification'),
  ('app_create_notifications_for_role'),
  ('app_create_provider_notification'),
  ('app_create_guard_notifications_for_lot'),
  ('app_admin_provider_verification_requests'),
  ('app_admin_update_provider_verification'),
  ('list_current_provider_guards'),
  ('current_guard_account'),
  ('link_parking_guard_by_email'),
  ('unlink_parking_guard'),
  ('refresh_parking_lot_rating'),
  ('refresh_parking_lot_rating_from_review')
) as required(function_name);
-- RLS should be enabled for sensitive public tables.
select pg_temp.record_check(
  'rls public.' || table_name,
  exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = required.table_name
      and c.relrowsecurity
  ),
  'RLS must be enabled'
)
from (values
  ('profiles'),
  ('customers'),
  ('providers'),
  ('parking_lots'),
  ('parking_slots'),
  ('parking_guards'),
  ('guard_lot_assignments'),
  ('vehicles'),
  ('bookings'),
  ('payments'),
  ('receipts'),
  ('notifications'),
  ('chat_rooms'),
  ('chat_room_members'),
  ('chat_messages'),
  ('profile_settings'),
  ('device_push_tokens')
) as required(table_name);
-- Policies added or replaced by the production patches.
select pg_temp.record_check(
  'policy ' || table_name || '.' || policy_name,
  exists (
    select 1
    from pg_policies p
    where p.schemaname = 'public'
      and p.tablename = required.table_name
      and p.policyname = required.policy_name
  ),
  'Required policy'
)
from (values
  ('bookings', 'bookings_related_select'),
  ('payments', 'payments_related_select'),
  ('receipts', 'receipts_related_users'),
  ('parking_activity_logs', 'parking_activity_logs_related_users'),
  ('profile_settings', 'profile_settings_owner_or_admin'),
  ('device_push_tokens', 'device_push_tokens_owner_or_admin')
) as required(table_name, policy_name);
-- Triggers from SQL patches.
select pg_temp.record_check(
  'trigger ' || table_name || '.' || trigger_name,
  exists (
    select 1
    from pg_trigger t
    join pg_class c on c.oid = t.tgrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = required.table_name
      and t.tgname = required.trigger_name
      and not t.tgisinternal
  ),
  'Required trigger'
)
from (values
  ('vehicles', 'vehicles_set_updated_at'),
  ('reviews', 'refresh_parking_lot_rating_from_review'),
  ('bookings', 'notify_provider_on_booking_created'),
  ('bookings', 'notify_customer_on_booking_status'),
  ('complaints', 'notify_super_admin_on_complaint'),
  ('profile_settings', 'set_profile_settings_updated_at')
) as required(table_name, trigger_name);
-- Supabase Realtime publication membership.
select pg_temp.record_check(
  'realtime public.' || table_name,
  exists (
    select 1
    from pg_publication_tables p
    where p.pubname = 'supabase_realtime'
      and p.schemaname = 'public'
      and p.tablename = required.table_name
  ),
  'Required table in supabase_realtime publication'
)
from (values
  ('parking_slots'),
  ('parking_lots'),
  ('notifications'),
  ('parking_guards'),
  ('bookings'),
  ('payments'),
  ('guard_lot_assignments')
) as required(table_name);
-- Storage buckets.
select pg_temp.record_check(
  'storage bucket ' || bucket_id,
  exists (
    select 1
    from storage.buckets b
    where b.id = required.bucket_id
  ),
  'Required Supabase Storage bucket'
)
from (values
  ('avatars'),
  ('parking-lot-photos'),
  ('provider-identity-documents')
) as required(bucket_id);
-- pg_cron extension and expiry job.
select pg_temp.record_check(
  'extension pg_cron',
  exists (select 1 from pg_extension where extname = 'pg_cron'),
  'Required for reservation expiry job'
);
do $$
declare
  v_has_cron_job_table boolean;
  v_job_exists boolean := false;
begin
  select exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'cron'
      and c.relname = 'job'
  )
  into v_has_cron_job_table;
  if v_has_cron_job_table then
    execute $q$
      select exists (
        select 1
        from cron.job
        where jobname = 'expire-stale-parking-bookings'
          and active
      )
    $q$
    into v_job_exists;
  end if;
  perform pg_temp.record_check(
    'cron job expire-stale-parking-bookings',
    v_job_exists,
    'Required active job for pending_payment expiry'
  );
end;
$$;
-- Summary first, then full detail.
select
  count(*) filter (where status = 'OK') as ok_count,
  count(*) filter (where status = 'MISSING') as missing_count,
  count(*) as total_count
from production_sql_verification_check;
select *
from production_sql_verification_check
order by
  case status when 'MISSING' then 0 else 1 end,
  check_name;

-- ============================================================================
-- END OF PATCH 10/10
-- ============================================================================

-- ============================================================================
-- INSTRUKSI SETELAH RUNNING BUNDLE
-- ============================================================================
-- 1. Lihat tab "Results" di Supabase SQL Editor
-- 2. Perhatikan baris "ok_count" dan "missing_count" di summary
-- 3. Jika ada baris dengan status='MISSING', patch terkait belum terpasang
-- 4. Jika semua OK, lanjut ke:
--    a. Test di Supabase SQL Editor:
--       select public.app_expire_stale_bookings(200);
--    b. Test di HP: booking baru, bayar via Midtrans sandbox
--    c. Cek log Edge Function di Supabase Dashboard > Edge Functions > Logs
-- 5. Untuk reset/restore jika ada masalah, semua patch menggunakan
--    "drop function if exists" dan "create or replace" sehingga idempotent.
--    Anda bisa re-run PATCH spesifik tanpa harus menjalankan ulang semuanya.
-- ============================================================================
