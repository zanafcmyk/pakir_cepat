-- Automatically cancel unpaid parking reservations after 15 minutes.
-- Run this file once in the Supabase SQL Editor after the booking security patch.

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
      and booking.created_at <= now() - interval '15 minutes'
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
      'Reservasi otomatis dibatalkan karena pembayaran tidak selesai dalam 15 menit.',
      jsonb_build_object('reason', 'payment_timeout', 'timeout_minutes', 15)
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
        ' dibatalkan karena belum dibayar dalam 15 menit. Slot telah tersedia kembali.',
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

-- pg_cron runs the protected expiry function every minute.
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

-- Optional verification after waiting one minute:
-- select jobid, jobname, schedule, command, active
-- from cron.job
-- where jobname = 'expire-stale-parking-bookings';
--
-- select status, return_message, start_time, end_time
-- from cron.job_run_details
-- where jobid = (
--   select jobid from cron.job
--   where jobname = 'expire-stale-parking-bookings'
-- )
-- order by start_time desc
-- limit 5;
