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
