-- Parkir Cepat server-side chat sync
-- Run in Supabase SQL Editor after docs/supabase_chat_sync.sql.

alter table public.chat_rooms
  add column if not exists room_key text,
  add column if not exists room_type public.chat_room_type not null default 'group',
  add column if not exists last_message text not null default 'Room chat siap digunakan.',
  add column if not exists last_message_at timestamptz not null default now();

alter table public.chat_room_members
  add column if not exists member_role public.account_role,
  add column if not exists display_name text,
  add column if not exists last_read_at timestamptz;

alter table public.chat_messages
  add column if not exists sender_role public.account_role,
  add column if not exists sender_name text,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create unique index if not exists chat_rooms_room_key_unique
  on public.chat_rooms(room_key)
  where room_key is not null;

create or replace function public.app_send_chat_message(
  p_room_key text,
  p_room_type text,
  p_title text,
  p_sender_role text,
  p_sender_name text,
  p_target_role text,
  p_target_name text,
  p_message text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_room_id uuid;
  v_context_id text := split_part(p_room_key, ':', 2);
  v_room_type public.chat_room_type := coalesce(nullif(p_room_type, ''), 'group')::public.chat_room_type;
  v_sender_role public.account_role := p_sender_role::public.account_role;
  v_target_role public.account_role := nullif(p_target_role, '')::public.account_role;
begin
  if auth.uid() is null then
    raise exception 'Login required';
  end if;

  insert into public.chat_rooms (
    room_key,
    room_type,
    title,
    created_by,
    last_message,
    last_message_at
  )
  values (
    p_room_key,
    v_room_type,
    p_title,
    auth.uid(),
    p_message,
    now()
  )
  on conflict (room_key) where room_key is not null do update
  set
    title = case
      when excluded.title is not null and btrim(excluded.title) <> ''
        then excluded.title
      else public.chat_rooms.title
    end,
    last_message = excluded.last_message,
    last_message_at = excluded.last_message_at,
    updated_at = now()
  returning id into v_room_id;

  insert into public.chat_room_members (
    room_id,
    profile_id,
    member_role,
    display_name,
    last_read_at
  )
  select
    v_room_id,
    profile.id,
    v_sender_role,
    coalesce(nullif(p_sender_name, ''), profile.full_name),
    now()
  from public.profiles profile
  where profile.id = auth.uid()
  on conflict (room_id, profile_id) do update
  set
    member_role = excluded.member_role,
    display_name = excluded.display_name,
    last_read_at = excluded.last_read_at;

  if v_target_role is not null then
    insert into public.chat_room_members (
      room_id,
      profile_id,
      member_role,
      display_name
    )
    select distinct
      v_room_id,
      target.id,
      target.role,
      coalesce(nullif(p_target_name, ''), target.full_name)
    from public.profiles target
    where target.id <> auth.uid()
      and target.access_status = 'active'
      and (
        (
          v_room_type = 'customer_guard'
          and v_target_role = 'parking_guard'
          and target.role = 'parking_guard'
          and (
            exists (
              select 1
              from public.bookings booking
              join public.guard_lot_assignments assignment
                on assignment.parking_lot_id = booking.parking_lot_id
              join public.parking_guards guard
                on guard.id = assignment.guard_id
              where booking.ticket_number = upper(trim(v_context_id))
                and guard.profile_id = target.id
            )
            or not exists (
              select 1
              from public.bookings booking
              join public.guard_lot_assignments assignment
                on assignment.parking_lot_id = booking.parking_lot_id
              where booking.ticket_number = upper(trim(v_context_id))
            )
          )
        )
        or (
          v_room_type = 'customer_guard'
          and v_target_role = 'customer'
          and exists (
            select 1
            from public.bookings booking
            join public.customers customer on customer.id = booking.customer_id
            where booking.ticket_number = upper(trim(v_context_id))
              and customer.profile_id = target.id
          )
        )
        or (
          v_room_type = 'customer_provider'
          and v_target_role = 'provider'
          and exists (
            select 1
            from public.parking_lots lot
            join public.providers provider on provider.id = lot.provider_id
            where lot.id::text = v_context_id
              and provider.profile_id = target.id
          )
        )
        or (
          v_room_type = 'provider_guard'
          and v_target_role = 'parking_guard'
          and target.role = 'parking_guard'
          and exists (
            select 1
            from public.providers provider
            join public.parking_guards guard on guard.provider_id = provider.id
            where provider.profile_id = auth.uid()
              and guard.profile_id = target.id
          )
        )
        or (
          v_room_type = 'provider_guard'
          and v_target_role = 'provider'
          and target.role = 'provider'
          and exists (
            select 1
            from public.parking_guards guard
            join public.providers provider on provider.id = guard.provider_id
            where guard.profile_id = auth.uid()
              and provider.profile_id = target.id
          )
        )
        or (
          v_target_role = 'super_admin'
          and target.role = 'super_admin'
        )
        or (
          v_room_type in ('customer_admin', 'provider_admin', 'guard_admin')
          and target.role = v_target_role
        )
      )
    on conflict (room_id, profile_id) do update
    set
      member_role = excluded.member_role,
      display_name = excluded.display_name;
  end if;

  insert into public.chat_messages (
    room_id,
    sender_profile_id,
    sender_role,
    sender_name,
    message
  )
  values (
    v_room_id,
    auth.uid(),
    v_sender_role,
    p_sender_name,
    p_message
  );

  return v_room_id;
end;
$$;

grant execute on function public.app_send_chat_message(
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text
) to authenticated;
