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
