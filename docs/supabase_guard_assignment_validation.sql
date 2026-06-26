-- Strengthen parking guard assignment validation.
-- Run after docs/supabase_guard_accounts.sql.
--
-- This prevents a guard from being linked without any valid provider-owned lot,
-- which later causes scan errors like:
-- "Guard is not allowed to scan tickets for this lot."

begin;

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
  v_assignment_count integer;
begin
  v_provider_id := public.current_provider_id();

  if v_provider_id is null then
    raise exception 'Only verified providers can link parking guards.';
  end if;

  if p_parking_lot_ids is null or cardinality(p_parking_lot_ids) = 0 then
    raise exception 'Assign at least one parking lot to this guard.';
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

  if not exists (
    select 1
    from public.parking_lots lot
    where lot.provider_id = v_provider_id
      and lot.is_active = true
      and lot.id = any(p_parking_lot_ids)
  ) then
    raise exception 'Selected parking lots do not belong to this provider or are inactive.';
  end if;

  update public.profiles as target_profile
  set
    full_name = coalesce(
      nullif(trim(p_guard_name), ''),
      target_profile.full_name
    ),
    phone_number = coalesce(
      nullif(trim(p_guard_phone), ''),
      target_profile.phone_number
    ),
    account_status = 'verified',
    access_status = 'active',
    verified_at = coalesce(target_profile.verified_at, now())
  where target_profile.id = v_profile_id;

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
    and lot.is_active = true
    and lot.id = any(p_parking_lot_ids)
  on conflict (guard_id, parking_lot_id) do nothing;

  get diagnostics v_assignment_count = row_count;
  if v_assignment_count = 0 then
    raise exception 'Guard was not assigned to any active parking lot.';
  end if;

  return query
  select
    listed.id,
    listed.provider_id,
    listed.name,
    listed.email,
    listed.phone_number,
    listed.assigned_lot_ids,
    listed.can_scan_qr,
    listed.can_confirm_cash,
    listed.can_manage_slots
  from public.list_current_provider_guards() as listed
  where listed.id = v_guard_id;
end;
$$;

grant execute on function public.link_parking_guard_by_email(
  text, text, text, uuid[], boolean, boolean, boolean
) to authenticated;

commit;
