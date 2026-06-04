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
  vehicle_id uuid,
  parking_location_id uuid not null references public.parking_locations(id) on delete cascade,
  booking_time timestamptz not null,
  parking_duration text not null,
  status text not null default 'pending' check (status in ('pending', 'active', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

alter table public.users enable row level security;
alter table public.providers enable row level security;
alter table public.parking_locations enable row level security;
alter table public.bookings enable row level security;

create policy "users own row" on public.users for select using (auth.uid() = id);
create policy "users upsert own row" on public.users for insert with check (auth.uid() = id);
create policy "users update own row" on public.users for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "provider own profile" on public.providers for select using (auth.uid() = user_id);
create policy "provider insert own profile" on public.providers for insert with check (auth.uid() = user_id);
create policy "provider update own profile" on public.providers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "parking public read" on public.parking_locations for select using (true);
create policy "parking provider manage own" on public.parking_locations for all using (auth.uid() = provider_id) with check (auth.uid() = provider_id);

create policy "bookings owner" on public.bookings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('profile-images', 'profile-images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('parking-images', 'parking-images', true)
on conflict (id) do nothing;

create policy "profile image upload" on storage.objects for insert to authenticated with check (bucket_id = 'profile-images');
create policy "profile image read" on storage.objects for select to public using (bucket_id = 'profile-images');
create policy "parking image upload" on storage.objects for insert to authenticated with check (bucket_id = 'parking-images');
create policy "parking image read" on storage.objects for select to public using (bucket_id = 'parking-images');
