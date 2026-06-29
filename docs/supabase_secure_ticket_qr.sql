-- Secure QR ticket payloads for Parkir Cepat.
-- Run after docs/supabase_booking_payment_security_patch.sql.
--
-- Goal:
-- - QR code contains an opaque random token, not a guessable ticket number.
-- - Manual ticket lookup by TKT-... still works in the app.
-- - Existing legacy QR payloads are backfilled to secure tokens.

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
