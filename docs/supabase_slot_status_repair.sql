-- Repair and keep parking slot statuses aligned with live bookings.
-- Run this after docs/supabase_booking_payment_security_patch.sql.

begin;

create or replace function public.app_repair_parking_slot_statuses(
  p_parking_lot_id uuid default null
)
returns table (
  slot_id uuid,
  old_status public.parking_slot_status,
  new_status public.parking_slot_status
)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  with expected as (
    select
      slot.id,
      slot.status as old_status,
      case
        when exists (
          select 1
          from public.bookings booking
          where booking.parking_slot_id = slot.id
            and booking.status = 'active'
        ) then 'occupied'::public.parking_slot_status
        when exists (
          select 1
          from public.bookings booking
          where booking.parking_slot_id = slot.id
            and booking.status in ('pending_payment', 'paid')
        ) then 'reserved'::public.parking_slot_status
        when slot.status in ('reserved', 'occupied') then 'available'::public.parking_slot_status
        else slot.status
      end as new_status
    from public.parking_slots slot
    where p_parking_lot_id is null
      or slot.parking_lot_id = p_parking_lot_id
  ),
  updated as (
    update public.parking_slots slot
    set status = expected.new_status,
        updated_at = now()
    from expected
    where slot.id = expected.id
      and expected.old_status is distinct from expected.new_status
      and slot.status <> 'blocked'
    returning slot.id, expected.old_status, expected.new_status
  )
  select updated.id, updated.old_status, updated.new_status
  from updated
  order by updated.id;
end;
$$;

revoke all on function public.app_repair_parking_slot_statuses(uuid)
from public, anon;

grant execute on function public.app_repair_parking_slot_statuses(uuid)
to service_role;

commit;

-- Optional one-time repair after creating the function:
-- select * from public.app_repair_parking_slot_statuses(null);
