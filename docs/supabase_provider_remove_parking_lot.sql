-- Safely remove a provider parking lot from the application.
-- The function deletes only when there is no historical booking; otherwise it
-- archives the lot by setting is_active = false so foreign keys stay intact.

begin;

create or replace function public.app_provider_remove_parking_lot(
  p_parking_lot_id uuid,
  p_delete_if_safe boolean default true
)
returns table (
  action text,
  removed_from_app boolean,
  deleted_row boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_has_live_booking boolean;
  v_has_booking_history boolean;
begin
  if auth.uid() is null then
    raise exception 'Provider session is required.';
  end if;

  select provider.id
  into v_provider_id
  from public.providers provider
  join public.profiles profile on profile.id = provider.profile_id
  where provider.profile_id = auth.uid()
    and provider.status = 'verified'
    and profile.role = 'provider'
    and profile.access_status = 'active'
  limit 1;

  if v_provider_id is null then
    raise exception 'Verified provider profile was not found.';
  end if;

  if not exists (
    select 1
    from public.parking_lots lot
    where lot.id = p_parking_lot_id
      and lot.provider_id = v_provider_id
  ) then
    raise exception 'Parking lot is not owned by current provider.';
  end if;

  select exists (
    select 1
    from public.bookings booking
    where booking.parking_lot_id = p_parking_lot_id
      and booking.status in ('pending_payment', 'paid', 'active')
  )
  into v_has_live_booking;

  if v_has_live_booking then
    raise exception 'Parking lot still has active bookings. Finish or cancel them before removing the lot.';
  end if;

  select exists (
    select 1
    from public.bookings booking
    where booking.parking_lot_id = p_parking_lot_id
  )
  into v_has_booking_history;

  delete from public.guard_lot_assignments
  where parking_lot_id = p_parking_lot_id;

  if p_delete_if_safe and not v_has_booking_history then
    delete from public.parking_lots
    where id = p_parking_lot_id
      and provider_id = v_provider_id;

    return query select 'deleted'::text, true, true;
    return;
  end if;

  update public.parking_slots
  set status = 'blocked',
      updated_at = now()
  where parking_lot_id = p_parking_lot_id
    and status in ('available', 'reserved');

  update public.parking_lots
  set is_active = false,
      updated_at = now()
  where id = p_parking_lot_id
    and provider_id = v_provider_id;

  return query select 'archived'::text, true, false;
end;
$$;

revoke all on function public.app_provider_remove_parking_lot(uuid, boolean)
from public, anon;

grant execute on function public.app_provider_remove_parking_lot(uuid, boolean)
to authenticated;

commit;
