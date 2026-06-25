-- Development/demo helper: lets a customer mark their own pending booking paid.
-- Use this only for local demo or sandbox testing while Midtrans settlement is
-- not available.

begin;

create or replace function public.app_simulate_customer_payment(
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
  v_customer_id uuid;
  v_booking public.bookings%rowtype;
  v_payment_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Customer session is required.';
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

  select booking.*
  into v_booking
  from public.bookings booking
  where booking.ticket_number = upper(trim(p_ticket_number))
    and booking.customer_id = v_customer_id
  for update;

  if v_booking.id is null then
    raise exception 'Booking was not found.';
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
    paid_at
  )
  values (
    v_booking.id,
    v_booking.customer_id,
    'qris',
    'paid',
    v_booking.estimated_cost,
    'SIM-' || v_booking.ticket_number || '-' || extract(epoch from now())::bigint,
    now()
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

  insert into public.notifications (
    profile_id,
    title,
    message,
    type,
    data
  )
  values (
    auth.uid(),
    'Pembayaran simulasi berhasil',
    'Tiket ' || v_booking.ticket_number || ' sudah aktif dan siap digunakan.',
    'payment',
    jsonb_build_object(
      'booking_id', v_booking.id,
      'ticket_number', v_booking.ticket_number,
      'status', 'paid',
      'simulated', true
    )
  );

  return query select v_payment_id, v_booking.estimated_cost;
end;
$$;

revoke all on function public.app_simulate_customer_payment(text)
from public, anon;

grant execute on function public.app_simulate_customer_payment(text)
to authenticated;

commit;
