-- Parkir Cepat Supabase schema additions
-- Run this after docs/supabase_schema.sql has already been applied.

do $$
begin
  create type public.parking_tariff_type as enum ('flat', 'hourly', 'vehicle_type');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.parking_activity_action as enum (
    'scan',
    'check_in',
    'check_out',
    'cash_confirm',
    'slot_update',
    'booking_cancelled'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.uploaded_file_owner_type as enum (
    'profile',
    'provider_application',
    'parking_lot',
    'complaint',
    'receipt'
  );
exception
  when duplicate_object then null;
end $$;

alter table public.parking_lots
  add column if not exists tariff_type public.parking_tariff_type not null default 'hourly',
  add column if not exists motor_rate integer not null default 0 check (motor_rate >= 0),
  add column if not exists car_rate integer not null default 0 check (car_rate >= 0),
  add column if not exists truck_rate integer not null default 0 check (truck_rate >= 0);

update public.parking_lots
set
  motor_rate = case when motor_rate = 0 then price_per_hour else motor_rate end,
  car_rate = case when car_rate = 0 then price_per_hour else car_rate end,
  truck_rate = case when truck_rate = 0 then price_per_hour else truck_rate end;

create table if not exists public.customer_favorite_lots (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  parking_lot_id uuid not null references public.parking_lots(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint customer_favorite_lots_unique unique (customer_id, parking_lot_id)
);

create table if not exists public.customer_settings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null unique references public.customers(id) on delete cascade,
  booking_notification_enabled boolean not null default true,
  payment_notification_enabled boolean not null default true,
  promo_notification_enabled boolean not null default false,
  selected_language text not null default 'id',
  account_security_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_activity_logs (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.bookings(id) on delete cascade,
  parking_lot_id uuid references public.parking_lots(id) on delete set null,
  parking_slot_id uuid references public.parking_slots(id) on delete set null,
  guard_id uuid references public.parking_guards(id) on delete set null,
  actor_profile_id uuid references public.profiles(id) on delete set null,
  action public.parking_activity_action not null,
  note text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.receipts (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id) on delete cascade,
  payment_id uuid references public.payments(id) on delete set null,
  receipt_number text not null unique,
  receipt_url text,
  issued_by uuid references public.profiles(id) on delete set null,
  issued_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.uploaded_files (
  id uuid primary key default gen_random_uuid(),
  owner_profile_id uuid references public.profiles(id) on delete set null,
  owner_type public.uploaded_file_owner_type not null,
  owner_id uuid,
  bucket_name text not null,
  object_path text not null,
  public_url text,
  file_name text,
  content_type text,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  created_at timestamptz not null default now(),
  constraint uploaded_files_bucket_path_unique unique (bucket_name, object_path)
);

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'customer_settings',
    'receipts'
  ]
  loop
    execute format('drop trigger if exists set_%I_updated_at on public.%I', table_name, table_name);
    execute format(
      'create trigger set_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      table_name,
      table_name
    );
  end loop;
end $$;

create index if not exists customer_favorite_lots_customer_idx
  on public.customer_favorite_lots(customer_id);

create index if not exists customer_favorite_lots_lot_idx
  on public.customer_favorite_lots(parking_lot_id);

create index if not exists parking_activity_logs_booking_idx
  on public.parking_activity_logs(booking_id, created_at desc);

create index if not exists parking_activity_logs_lot_idx
  on public.parking_activity_logs(parking_lot_id, created_at desc);

create index if not exists parking_activity_logs_guard_idx
  on public.parking_activity_logs(guard_id, created_at desc);

create index if not exists receipts_booking_idx
  on public.receipts(booking_id);

create index if not exists uploaded_files_owner_idx
  on public.uploaded_files(owner_type, owner_id);

alter table public.customer_favorite_lots enable row level security;
alter table public.customer_settings enable row level security;
alter table public.parking_activity_logs enable row level security;
alter table public.receipts enable row level security;
alter table public.uploaded_files enable row level security;

drop policy if exists "customer_favorite_lots_owner_or_admin" on public.customer_favorite_lots;
create policy "customer_favorite_lots_owner_or_admin"
on public.customer_favorite_lots for all
using (customer_id = public.current_customer_id() or public.is_super_admin())
with check (customer_id = public.current_customer_id() or public.is_super_admin());

drop policy if exists "customer_settings_owner_or_admin" on public.customer_settings;
create policy "customer_settings_owner_or_admin"
on public.customer_settings for all
using (customer_id = public.current_customer_id() or public.is_super_admin())
with check (customer_id = public.current_customer_id() or public.is_super_admin());

drop policy if exists "parking_activity_logs_related_users" on public.parking_activity_logs;
create policy "parking_activity_logs_related_users"
on public.parking_activity_logs for select
using (
  public.is_super_admin()
  or actor_profile_id = auth.uid()
  or guard_id = public.current_guard_id()
  or (
    parking_lot_id is not null
    and (
      public.is_provider_lot(parking_lot_id)
      or public.is_guard_assigned_to_lot(parking_lot_id)
    )
  )
  or exists (
    select 1
    from public.bookings booking
    where booking.id = parking_activity_logs.booking_id
      and booking.customer_id = public.current_customer_id()
  )
);

drop policy if exists "parking_activity_logs_staff_insert" on public.parking_activity_logs;
create policy "parking_activity_logs_staff_insert"
on public.parking_activity_logs for insert
with check (
  public.is_super_admin()
  or actor_profile_id = auth.uid()
  or guard_id = public.current_guard_id()
  or (
    parking_lot_id is not null
    and (
      public.is_provider_lot(parking_lot_id)
      or public.is_guard_assigned_to_lot(parking_lot_id)
    )
  )
);

drop policy if exists "receipts_related_users" on public.receipts;
create policy "receipts_related_users"
on public.receipts for select
using (
  public.is_super_admin()
  or issued_by = auth.uid()
  or exists (
    select 1
    from public.bookings booking
    where booking.id = receipts.booking_id
      and (
        booking.customer_id = public.current_customer_id()
        or public.is_provider_lot(booking.parking_lot_id)
        or public.is_guard_assigned_to_lot(booking.parking_lot_id)
      )
  )
);

drop policy if exists "receipts_staff_insert" on public.receipts;
create policy "receipts_staff_insert"
on public.receipts for insert
with check (
  public.is_super_admin()
  or issued_by = auth.uid()
  or exists (
    select 1
    from public.bookings booking
    where booking.id = receipts.booking_id
      and (
        public.is_provider_lot(booking.parking_lot_id)
        or public.is_guard_assigned_to_lot(booking.parking_lot_id)
      )
  )
);

drop policy if exists "uploaded_files_owner_or_related_staff" on public.uploaded_files;
create policy "uploaded_files_owner_or_related_staff"
on public.uploaded_files for all
using (
  public.is_super_admin()
  or owner_profile_id = auth.uid()
)
with check (
  public.is_super_admin()
  or owner_profile_id = auth.uid()
);
