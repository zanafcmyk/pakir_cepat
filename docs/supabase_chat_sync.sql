-- Parkir Cepat chat sync additions
-- Run this after docs/supabase_schema.sql has already been applied.

do $$
begin
  create type public.chat_room_type as enum (
    'customer_provider',
    'customer_guard',
    'customer_admin',
    'provider_guard',
    'provider_admin',
    'guard_admin',
    'group'
  );
exception
  when duplicate_object then null;
end $$;

alter table public.chat_rooms
  add column if not exists room_key text,
  add column if not exists room_type public.chat_room_type not null default 'group',
  add column if not exists context_type text,
  add column if not exists context_id text,
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

create index if not exists chat_rooms_last_message_at_idx
  on public.chat_rooms(last_message_at desc);

create index if not exists chat_room_members_room_id_idx
  on public.chat_room_members(room_id);

create or replace function public.is_chat_room_member(target_room_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.chat_room_members member
    where member.room_id = target_room_id
      and member.profile_id = auth.uid()
  )
$$;

create or replace function public.touch_chat_room_from_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.chat_rooms
  set
    last_message = new.message,
    last_message_at = new.created_at,
    updated_at = now()
  where id = new.room_id;

  update public.chat_room_members
  set unread_count = unread_count + 1
  where room_id = new.room_id
    and profile_id <> new.sender_profile_id;

  update public.chat_room_members
  set last_read_at = new.created_at
  where room_id = new.room_id
    and profile_id = new.sender_profile_id;

  return new;
end;
$$;

drop trigger if exists touch_chat_room_after_message on public.chat_messages;
create trigger touch_chat_room_after_message
after insert on public.chat_messages
for each row execute function public.touch_chat_room_from_message();

drop policy if exists "chat_rooms_member_or_admin" on public.chat_rooms;
create policy "chat_rooms_member_or_admin"
on public.chat_rooms for select
using (public.is_super_admin() or public.is_chat_room_member(id));

drop policy if exists "chat_rooms_member_insert" on public.chat_rooms;
create policy "chat_rooms_member_insert"
on public.chat_rooms for insert
with check (created_by = auth.uid() or public.is_super_admin());

drop policy if exists "chat_rooms_member_update" on public.chat_rooms;
create policy "chat_rooms_member_update"
on public.chat_rooms for update
using (public.is_super_admin() or public.is_chat_room_member(id))
with check (public.is_super_admin() or public.is_chat_room_member(id));

drop policy if exists "chat_members_self_or_admin" on public.chat_room_members;
create policy "chat_members_self_or_admin"
on public.chat_room_members for select
using (public.is_super_admin() or public.is_chat_room_member(room_id));

drop policy if exists "chat_members_insert_self_or_admin" on public.chat_room_members;
create policy "chat_members_insert_self_or_admin"
on public.chat_room_members for insert
with check (
  profile_id = auth.uid()
  or public.is_super_admin()
  or exists (
    select 1
    from public.chat_rooms room
    where room.id = chat_room_members.room_id
      and room.created_by = auth.uid()
  )
);

drop policy if exists "chat_members_update_self_or_admin" on public.chat_room_members;
create policy "chat_members_update_self_or_admin"
on public.chat_room_members for update
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());

drop policy if exists "chat_messages_room_member_or_admin" on public.chat_messages;
create policy "chat_messages_room_member_or_admin"
on public.chat_messages for select
using (public.is_super_admin() or public.is_chat_room_member(room_id));

drop policy if exists "chat_messages_member_insert" on public.chat_messages;
create policy "chat_messages_member_insert"
on public.chat_messages for insert
with check (
  sender_profile_id = auth.uid()
  and public.is_chat_room_member(room_id)
);
