-- Run this after docs/supabase_schema.sql when enabling parking guard accounts.
-- Guards must register first from the app, then providers can link that guard
-- account to their parking lots by email.

create or replace function public.list_current_provider_guards()
returns table (
  id uuid,
  provider_id uuid,
  name text,
  email text,
  phone_number text,
  assigned_lot_ids uuid[],
  can_scan_qr boolean,
  can_confirm_cash boolean,
  can_manage_slots boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select
    guard.id,
    guard.provider_id,
    profile.full_name as name,
    profile.email,
    profile.phone_number,
    coalesce(
      array_agg(assignment.parking_lot_id)
        filter (where assignment.parking_lot_id is not null),
      array[]::uuid[]
    ) as assigned_lot_ids,
    guard.can_scan_qr,
    guard.can_confirm_cash,
    guard.can_manage_slots
  from public.parking_guards guard
  join public.profiles profile on profile.id = guard.profile_id
  left join public.guard_lot_assignments assignment
    on assignment.guard_id = guard.id
  where guard.provider_id = public.current_provider_id()
  group by guard.id, profile.full_name, profile.email, profile.phone_number
  order by profile.full_name;
$$;

create or replace function public.current_guard_account()
returns table (
  id uuid,
  provider_id uuid,
  name text,
  email text,
  phone_number text,
  assigned_lot_ids uuid[],
  can_scan_qr boolean,
  can_confirm_cash boolean,
  can_manage_slots boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select
    guard.id,
    guard.provider_id,
    profile.full_name as name,
    profile.email,
    profile.phone_number,
    coalesce(
      array_agg(assignment.parking_lot_id)
        filter (where assignment.parking_lot_id is not null),
      array[]::uuid[]
    ) as assigned_lot_ids,
    guard.can_scan_qr,
    guard.can_confirm_cash,
    guard.can_manage_slots
  from public.parking_guards guard
  join public.profiles profile on profile.id = guard.profile_id
  left join public.guard_lot_assignments assignment
    on assignment.guard_id = guard.id
  where guard.profile_id = auth.uid()
  group by guard.id, profile.full_name, profile.email, profile.phone_number
  limit 1;
$$;

create or replace function public.link_parking_guard_by_email(
  p_guard_name text,
  p_guard_email text,
  p_guard_phone text,
  p_parking_lot_ids uuid[],
  p_can_scan_qr boolean default true,
  p_can_confirm_cash boolean default true,
  p_can_manage_slots boolean default false
)
returns table (
  id uuid,
  provider_id uuid,
  name text,
  email text,
  phone_number text,
  assigned_lot_ids uuid[],
  can_scan_qr boolean,
  can_confirm_cash boolean,
  can_manage_slots boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_profile_id uuid;
  v_guard_id uuid;
begin
  v_provider_id := public.current_provider_id();

  if v_provider_id is null then
    raise exception 'Only verified providers can link parking guards.';
  end if;

  select profile.id
  into v_profile_id
  from public.profiles profile
  where lower(profile.email) = lower(trim(p_guard_email))
    and profile.role = 'parking_guard'
  limit 1;

  if v_profile_id is null then
    raise exception 'Parking guard account not found. Ask the guard to register first.';
  end if;

  update public.profiles
  set
    full_name = coalesce(nullif(trim(p_guard_name), ''), full_name),
    phone_number = coalesce(nullif(trim(p_guard_phone), ''), phone_number),
    account_status = 'verified',
    access_status = 'active',
    verified_at = coalesce(verified_at, now())
  where id = v_profile_id;

  insert into public.parking_guards (
    profile_id,
    provider_id,
    can_scan_qr,
    can_confirm_cash,
    can_manage_slots
  )
  values (
    v_profile_id,
    v_provider_id,
    p_can_scan_qr,
    p_can_confirm_cash,
    p_can_manage_slots
  )
  on conflict (profile_id) do update
  set
    provider_id = excluded.provider_id,
    can_scan_qr = excluded.can_scan_qr,
    can_confirm_cash = excluded.can_confirm_cash,
    can_manage_slots = excluded.can_manage_slots
  returning parking_guards.id into v_guard_id;

  delete from public.guard_lot_assignments
  where guard_id = v_guard_id;

  insert into public.guard_lot_assignments (guard_id, parking_lot_id)
  select v_guard_id, lot.id
  from public.parking_lots lot
  where lot.provider_id = v_provider_id
    and lot.id = any(p_parking_lot_ids)
  on conflict (guard_id, parking_lot_id) do nothing;

  return query
  select *
  from public.list_current_provider_guards() listed
  where listed.id = v_guard_id;
end;
$$;

create or replace function public.unlink_parking_guard(p_guard_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
begin
  v_provider_id := public.current_provider_id();

  if v_provider_id is null then
    raise exception 'Only providers can unlink parking guards.';
  end if;

  delete from public.guard_lot_assignments assignment
  using public.parking_guards guard
  where assignment.guard_id = guard.id
    and guard.id = p_guard_id
    and guard.provider_id = v_provider_id;

  delete from public.parking_guards
  where id = p_guard_id
    and provider_id = v_provider_id;
end;
$$;

grant execute on function public.list_current_provider_guards() to authenticated;
grant execute on function public.current_guard_account() to authenticated;
grant execute on function public.link_parking_guard_by_email(
  text, text, text, uuid[], boolean, boolean, boolean
) to authenticated;
grant execute on function public.unlink_parking_guard(uuid) to authenticated;
