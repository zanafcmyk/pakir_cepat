-- Parkir Cepat Supabase schema
-- Paste this file into Supabase SQL Editor, then click Run.

create extension if not exists "pgcrypto";

do $$
begin
  create type public.account_role as enum ('super_admin', 'provider', 'parking_guard', 'customer');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.account_status as enum ('pending', 'verified', 'rejected');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.user_access_status as enum ('active', 'suspended');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.vehicle_kind as enum ('motor', 'mobil', 'truk');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.parking_slot_status as enum ('available', 'reserved', 'occupied', 'blocked');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.booking_status as enum ('pending_payment', 'paid', 'active', 'completed', 'cancelled');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_method as enum ('qris', 'ewallet', 'cash', 'card');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_status as enum ('pending', 'paid', 'failed', 'refunded', 'cancelled');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.complaint_status as enum ('waiting', 'answered', 'closed');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.complaint_priority as enum ('low', 'normal', 'high', 'urgent');
exception
  when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  phone_number text,
  role public.account_role not null default 'customer',
  account_status public.account_status not null default 'pending',
  access_status public.user_access_status not null default 'active',
  avatar_url text,
  note text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_email_unique unique (email)
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  default_vehicle_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.providers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  business_name text not null,
  business_address text,
  identity_document_url text,
  status public.account_status not null default 'pending',
  approved_by uuid references public.profiles(id) on delete set null,
  approved_at timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.provider_applications (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid references public.providers(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  parking_name text not null,
  address text not null,
  photo_url text,
  location_label text,
  capacity integer not null check (capacity >= 0),
  identity_document_url text,
  status public.account_status not null default 'pending',
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_lots (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers(id) on delete cascade,
  name text not null,
  address text not null,
  description text,
  price_per_hour integer not null check (price_per_hour >= 0),
  total_slots integer not null default 0 check (total_slots >= 0),
  open_hours text not null default '24 Jam',
  latitude double precision,
  longitude double precision,
  map_embed_url text,
  photo_url text,
  rating numeric(2, 1) not null default 0 check (rating >= 0 and rating <= 5),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_slots (
  id uuid primary key default gen_random_uuid(),
  parking_lot_id uuid not null references public.parking_lots(id) on delete cascade,
  label text not null,
  status public.parking_slot_status not null default 'available',
  vehicle_kind public.vehicle_kind,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint parking_slots_lot_label_unique unique (parking_lot_id, label)
);

create table if not exists public.parking_guards (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  provider_id uuid not null references public.providers(id) on delete cascade,
  can_scan_qr boolean not null default true,
  can_confirm_cash boolean not null default true,
  can_manage_slots boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.guard_lot_assignments (
  id uuid primary key default gen_random_uuid(),
  guard_id uuid not null references public.parking_guards(id) on delete cascade,
  parking_lot_id uuid not null references public.parking_lots(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint guard_lot_assignments_unique unique (guard_id, parking_lot_id)
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  plate_number text not null,
  kind public.vehicle_kind not null,
  brand text,
  model text,
  color text,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vehicles_customer_plate_unique unique (customer_id, plate_number)
);

do $$
begin
  alter table public.customers
    add constraint customers_default_vehicle_fk
    foreign key (default_vehicle_id) references public.vehicles(id) on delete set null;
exception
  when duplicate_object then null;
end $$;

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  ticket_number text not null unique,
  customer_id uuid not null references public.customers(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete restrict,
  parking_lot_id uuid not null references public.parking_lots(id) on delete restrict,
  parking_slot_id uuid references public.parking_slots(id) on delete set null,
  entry_time timestamptz not null,
  exit_time timestamptz,
  duration_hours integer not null default 1 check (duration_hours > 0),
  price_per_hour integer not null check (price_per_hour >= 0),
  estimated_cost integer not null check (estimated_cost >= 0),
  final_cost integer check (final_cost is null or final_cost >= 0),
  status public.booking_status not null default 'pending_payment',
  qr_payload text,
  checked_in_by uuid references public.parking_guards(id) on delete set null,
  checked_out_by uuid references public.parking_guards(id) on delete set null,
  checked_in_at timestamptz,
  checked_out_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  method public.payment_method not null,
  status public.payment_status not null default 'pending',
  amount integer not null check (amount >= 0),
  provider_reference text,
  paid_at timestamptz,
  confirmed_by_guard_id uuid references public.parking_guards(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  parking_lot_id uuid not null references public.parking_lots(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.complaints (
  id uuid primary key default gen_random_uuid(),
  sender_profile_id uuid not null references public.profiles(id) on delete cascade,
  sender_role public.account_role not null,
  title text not null,
  category text not null,
  description text not null,
  priority public.complaint_priority not null default 'normal',
  status public.complaint_status not null default 'waiting',
  reply text,
  replied_by uuid references public.profiles(id) on delete set null,
  replied_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null default 'info',
  is_read boolean not null default false,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.chat_rooms (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chat_room_members (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.chat_rooms(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  unread_count integer not null default 0 check (unread_count >= 0),
  joined_at timestamptz not null default now(),
  constraint chat_room_members_unique unique (room_id, profile_id)
);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.chat_rooms(id) on delete cascade,
  sender_profile_id uuid not null references public.profiles(id) on delete cascade,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.current_user_role()
returns public.account_role
language sql
security definer
set search_path = public
stable
as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(public.current_user_role() = 'super_admin', false)
$$;

create or replace function public.current_provider_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select id from public.providers where profile_id = auth.uid()
$$;

create or replace function public.current_customer_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select id from public.customers where profile_id = auth.uid()
$$;

create or replace function public.current_guard_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select id from public.parking_guards where profile_id = auth.uid()
$$;

create or replace function public.is_provider_lot(lot_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.parking_lots lot
    where lot.id = lot_id
      and lot.provider_id = public.current_provider_id()
  )
$$;

create or replace function public.is_guard_assigned_to_lot(lot_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.guard_lot_assignments assignment
    where assignment.parking_lot_id = lot_id
      and assignment.guard_id = public.current_guard_id()
  )
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'profiles',
    'customers',
    'providers',
    'provider_applications',
    'parking_lots',
    'parking_slots',
    'parking_guards',
    'guard_lot_assignments',
    'vehicles',
    'bookings',
    'payments',
    'reviews',
    'complaints',
    'chat_rooms'
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

create index if not exists profiles_role_idx on public.profiles(role);
create index if not exists parking_lots_provider_id_idx on public.parking_lots(provider_id);
create index if not exists parking_slots_lot_status_idx on public.parking_slots(parking_lot_id, status);
create index if not exists guard_lot_assignments_guard_id_idx on public.guard_lot_assignments(guard_id);
create index if not exists vehicles_customer_id_idx on public.vehicles(customer_id);
create index if not exists bookings_customer_status_idx on public.bookings(customer_id, status);
create index if not exists bookings_lot_status_idx on public.bookings(parking_lot_id, status);
create index if not exists payments_booking_id_idx on public.payments(booking_id);
create index if not exists notifications_profile_read_idx on public.notifications(profile_id, is_read);
create index if not exists chat_room_members_profile_id_idx on public.chat_room_members(profile_id);
create index if not exists chat_messages_room_created_idx on public.chat_messages(room_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.customers enable row level security;
alter table public.providers enable row level security;
alter table public.provider_applications enable row level security;
alter table public.parking_lots enable row level security;
alter table public.parking_slots enable row level security;
alter table public.parking_guards enable row level security;
alter table public.guard_lot_assignments enable row level security;
alter table public.vehicles enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;
alter table public.reviews enable row level security;
alter table public.complaints enable row level security;
alter table public.notifications enable row level security;
alter table public.chat_rooms enable row level security;
alter table public.chat_room_members enable row level security;
alter table public.chat_messages enable row level security;

drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
on public.profiles for select
using (id = auth.uid() or public.is_super_admin());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert
with check (id = auth.uid());

drop policy if exists "profiles_update_own_or_admin" on public.profiles;
create policy "profiles_update_own_or_admin"
on public.profiles for update
using (id = auth.uid() or public.is_super_admin())
with check (id = auth.uid() or public.is_super_admin());

drop policy if exists "customers_own_or_admin" on public.customers;
create policy "customers_own_or_admin"
on public.customers for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "providers_own_or_admin" on public.providers;
create policy "providers_own_or_admin"
on public.providers for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "provider_applications_owner_or_admin" on public.provider_applications;
create policy "provider_applications_owner_or_admin"
on public.provider_applications for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "parking_lots_public_read" on public.parking_lots;
create policy "parking_lots_public_read"
on public.parking_lots for select
using (is_active = true or provider_id = public.current_provider_id() or public.is_super_admin());

drop policy if exists "parking_lots_provider_manage" on public.parking_lots;
create policy "parking_lots_provider_manage"
on public.parking_lots for all
using (provider_id = public.current_provider_id() or public.is_super_admin())
with check (provider_id = public.current_provider_id() or public.is_super_admin());

drop policy if exists "parking_slots_public_read" on public.parking_slots;
create policy "parking_slots_public_read"
on public.parking_slots for select
using (true);

drop policy if exists "parking_slots_provider_or_guard_manage" on public.parking_slots;
create policy "parking_slots_provider_or_guard_manage"
on public.parking_slots for all
using (
  public.is_provider_lot(parking_lot_id)
  or public.is_guard_assigned_to_lot(parking_lot_id)
  or public.is_super_admin()
)
with check (
  public.is_provider_lot(parking_lot_id)
  or public.is_guard_assigned_to_lot(parking_lot_id)
  or public.is_super_admin()
);

drop policy if exists "guards_provider_admin_or_self" on public.parking_guards;
create policy "guards_provider_admin_or_self"
on public.parking_guards for all
using (
  profile_id = auth.uid()
  or provider_id = public.current_provider_id()
  or public.is_super_admin()
)
with check (
  profile_id = auth.uid()
  or provider_id = public.current_provider_id()
  or public.is_super_admin()
);

drop policy if exists "assignments_provider_guard_or_admin" on public.guard_lot_assignments;
create policy "assignments_provider_guard_or_admin"
on public.guard_lot_assignments for all
using (
  guard_id = public.current_guard_id()
  or public.is_provider_lot(parking_lot_id)
  or public.is_super_admin()
)
with check (
  public.is_provider_lot(parking_lot_id)
  or public.is_super_admin()
);

drop policy if exists "vehicles_customer_or_admin" on public.vehicles;
create policy "vehicles_customer_or_admin"
on public.vehicles for all
using (customer_id = public.current_customer_id() or public.is_super_admin())
with check (customer_id = public.current_customer_id() or public.is_super_admin());

drop policy if exists "bookings_related_users" on public.bookings;
drop policy if exists "bookings_related_select" on public.bookings;
create policy "bookings_related_select"
on public.bookings for select
using (
  customer_id = public.current_customer_id()
  or public.is_provider_lot(parking_lot_id)
  or public.is_guard_assigned_to_lot(parking_lot_id)
  or public.is_super_admin()
);

drop policy if exists "payments_related_users" on public.payments;
drop policy if exists "payments_related_select" on public.payments;
create policy "payments_related_select"
on public.payments for select
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

drop policy if exists "reviews_public_read" on public.reviews;
create policy "reviews_public_read"
on public.reviews for select
using (true);

drop policy if exists "reviews_customer_manage" on public.reviews;
create policy "reviews_customer_manage"
on public.reviews for insert
with check (customer_id = public.current_customer_id());

drop policy if exists "complaints_sender_or_admin" on public.complaints;
create policy "complaints_sender_or_admin"
on public.complaints for all
using (sender_profile_id = auth.uid() or public.is_super_admin())
with check (sender_profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "notifications_owner_or_admin" on public.notifications;
create policy "notifications_owner_or_admin"
on public.notifications for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "chat_rooms_member_or_admin" on public.chat_rooms;
create policy "chat_rooms_member_or_admin"
on public.chat_rooms for all
using (
  public.is_super_admin()
  or exists (
    select 1
    from public.chat_room_members member
    where member.room_id = chat_rooms.id
      and member.profile_id = auth.uid()
  )
)
with check (created_by = auth.uid() or public.is_super_admin());

drop policy if exists "chat_members_self_or_admin" on public.chat_room_members;
create policy "chat_members_self_or_admin"
on public.chat_room_members for all
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "chat_messages_room_member_or_admin" on public.chat_messages;
create policy "chat_messages_room_member_or_admin"
on public.chat_messages for all
using (
  public.is_super_admin()
  or exists (
    select 1
    from public.chat_room_members member
    where member.room_id = chat_messages.room_id
      and member.profile_id = auth.uid()
  )
)
with check (
  sender_profile_id = auth.uid()
  and exists (
    select 1
    from public.chat_room_members member
    where member.room_id = chat_messages.room_id
      and member.profile_id = auth.uid()
  )
);

-- Optional: after you create an admin user in Authentication > Users,
-- replace the values below and run only this insert to make that account a super admin.
--
-- insert into public.profiles (id, full_name, email, role, account_status, access_status, verified_at)
-- values (
--   'AUTH_USER_UUID_HERE',
--   'Super Admin',
--   'admin@pakircepat.com',
--   'super_admin',
--   'verified',
--   'active',
--   now()
-- )
-- on conflict (id) do update set
--   role = 'super_admin',
--   account_status = 'verified',
--   access_status = 'active',
--   verified_at = now();
