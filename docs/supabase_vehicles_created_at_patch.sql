-- Patch for existing Supabase projects created before vehicles timestamps existed.
-- Run this once in Supabase SQL Editor if saving vehicles fails with:
-- column vehicles.created_at does not exist.

begin;

alter table public.vehicles
  add column if not exists created_at timestamptz not null default now();

alter table public.vehicles
  add column if not exists updated_at timestamptz not null default now();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists vehicles_set_updated_at on public.vehicles;
create trigger vehicles_set_updated_at
before update on public.vehicles
for each row
execute function public.set_updated_at();

commit;
