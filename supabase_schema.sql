-- Run in Supabase SQL Editor
create extension if not exists "pgcrypto";

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text unique not null,
  phone text,
  role text not null check (role in ('customer', 'provider')),
  created_at timestamptz not null default now()
);

create table if not exists public.providers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  parking_name text not null,
  address text not null,
  latitude double precision not null default 0,
  longitude double precision not null default 0,
  capacity integer not null default 0,
  parking_photo text,
  ktp_photo text,
  verification_status text not null default 'pending' check (verification_status in ('pending', 'verified', 'rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  plate_number text not null,
  vehicle_type text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.parking_locations (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.users(id) on delete cascade,
  parking_name text not null,
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  total_slots integer not null default 0,
  available_slots integer not null default 0,
  parking_price numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  parking_location_id uuid not null references public.parking_locations(id) on delete cascade,
  booking_time timestamptz not null,
  parking_duration text not null,
  status text not null default 'pending' check (status in ('pending', 'active', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  qr_code text not null,
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'failed')),
  entry_time timestamptz,
  exit_time timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  amount numeric(12,2) not null,
  payment_method text not null,
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'failed')),
  paid_at timestamptz
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.users enable row level security;
alter table public.providers enable row level security;
alter table public.vehicles enable row level security;
alter table public.parking_locations enable row level security;
alter table public.bookings enable row level security;
alter table public.tickets enable row level security;
alter table public.payments enable row level security;
alter table public.notifications enable row level security;

create policy "users own row" on public.users for select using (auth.uid() = id);
create policy "users upsert own row" on public.users for insert with check (auth.uid() = id);
create policy "users update own row" on public.users for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "provider own profile" on public.providers for select using (auth.uid() = user_id);
create policy "provider insert own profile" on public.providers for insert with check (auth.uid() = user_id);
create policy "provider update own profile" on public.providers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "vehicles owner" on public.vehicles for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "parking public read" on public.parking_locations for select using (true);
create policy "parking provider manage own" on public.parking_locations for all using (auth.uid() = provider_id) with check (auth.uid() = provider_id);
create policy "bookings owner" on public.bookings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "tickets owner" on public.tickets for select using (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));
create policy "payments owner" on public.payments for select using (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));
create policy "notifications owner" on public.notifications for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter publication supabase_realtime add table public.parking_locations;
alter publication supabase_realtime add table public.bookings;
alter publication supabase_realtime add table public.payments;
alter publication supabase_realtime add table public.notifications;
