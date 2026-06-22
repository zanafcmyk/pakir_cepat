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
