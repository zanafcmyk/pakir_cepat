-- Production SQL verification for Parkir Cepat.
-- Run this in Supabase SQL Editor. It does not modify production data.
-- Rows with status = 'MISSING' indicate SQL patches that still need to be run.

create temp table if not exists production_sql_verification_check (
  check_name text primary key,
  status text not null,
  detail text
) on commit drop;

truncate table production_sql_verification_check;

create or replace function pg_temp.record_check(
  p_check_name text,
  p_ok boolean,
  p_detail text default null
)
returns void
language plpgsql
as $$
begin
  insert into production_sql_verification_check(check_name, status, detail)
  values (p_check_name, case when p_ok then 'OK' else 'MISSING' end, p_detail)
  on conflict (check_name) do update
  set status = excluded.status,
      detail = excluded.detail;
end;
$$;

-- Core tables from schema/additions.
select pg_temp.record_check(
  'table public.' || table_name,
  to_regclass('public.' || table_name) is not null,
  'Required table'
)
from (values
  ('profiles'),
  ('customers'),
  ('providers'),
  ('provider_applications'),
  ('parking_lots'),
  ('parking_slots'),
  ('parking_guards'),
  ('guard_lot_assignments'),
  ('vehicles'),
  ('bookings'),
  ('payments'),
  ('reviews'),
  ('complaints'),
  ('notifications'),
  ('chat_rooms'),
  ('chat_room_members'),
  ('chat_messages'),
  ('customer_favorite_lots'),
  ('customer_settings'),
  ('parking_activity_logs'),
  ('receipts'),
  ('uploaded_files'),
  ('profile_settings'),
  ('device_push_tokens')
) as required(table_name);

-- Important compatibility columns.
select pg_temp.record_check(
  'column public.' || table_name || '.' || column_name,
  exists (
    select 1
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = required.table_name
      and c.column_name = required.column_name
  ),
  'Required column'
)
from (values
  ('vehicles', 'created_at'),
  ('vehicles', 'updated_at'),
  ('parking_lots', 'photo_url'),
  ('parking_lots', 'latitude'),
  ('parking_lots', 'longitude'),
  ('parking_lots', 'is_active'),
  ('bookings', 'duration_hours'),
  ('bookings', 'final_cost'),
  ('bookings', 'exit_time'),
  ('bookings', 'checked_in_at'),
  ('bookings', 'checked_out_at'),
  ('bookings', 'checked_in_by'),
  ('bookings', 'checked_out_by'),
  ('payments', 'provider_reference'),
  ('payments', 'paid_at'),
  ('profiles', 'access_status'),
  ('profiles', 'avatar_url')
) as required(table_name, column_name);

-- RPC/functions used by Flutter and SQL jobs.
select pg_temp.record_check(
  'function public.' || function_name,
  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = required.function_name
  ),
  'Required RPC/function'
)
from (values
  ('app_create_customer_booking'),
  ('app_operator_confirm_cash_payment'),
  ('app_operator_process_ticket'),
  ('app_extend_customer_booking'),
  ('app_expire_stale_bookings'),
  ('app_repair_parking_slot_statuses'),
  ('app_provider_remove_parking_lot'),
  ('app_simulate_customer_payment'),
  ('app_provider_add_parking_slot'),
  ('app_active_profiles_by_role'),
  ('app_provider_profile_for_lot'),
  ('app_guard_profiles_for_ticket'),
  ('app_customer_profile_for_ticket'),
  ('app_current_provider_guard_profiles'),
  ('app_current_guard_provider_profile'),
  ('app_create_notification'),
  ('app_create_notifications_for_role'),
  ('app_create_provider_notification'),
  ('app_create_guard_notifications_for_lot'),
  ('app_admin_provider_verification_requests'),
  ('app_admin_update_provider_verification'),
  ('list_current_provider_guards'),
  ('current_guard_account'),
  ('link_parking_guard_by_email'),
  ('unlink_parking_guard'),
  ('refresh_parking_lot_rating'),
  ('refresh_parking_lot_rating_from_review')
) as required(function_name);

-- RLS should be enabled for sensitive public tables.
select pg_temp.record_check(
  'rls public.' || table_name,
  exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = required.table_name
      and c.relrowsecurity
  ),
  'RLS must be enabled'
)
from (values
  ('profiles'),
  ('customers'),
  ('providers'),
  ('parking_lots'),
  ('parking_slots'),
  ('parking_guards'),
  ('guard_lot_assignments'),
  ('vehicles'),
  ('bookings'),
  ('payments'),
  ('receipts'),
  ('notifications'),
  ('chat_rooms'),
  ('chat_room_members'),
  ('chat_messages'),
  ('profile_settings'),
  ('device_push_tokens')
) as required(table_name);

-- Policies added or replaced by the production patches.
select pg_temp.record_check(
  'policy ' || table_name || '.' || policy_name,
  exists (
    select 1
    from pg_policies p
    where p.schemaname = 'public'
      and p.tablename = required.table_name
      and p.policyname = required.policy_name
  ),
  'Required policy'
)
from (values
  ('bookings', 'bookings_related_select'),
  ('payments', 'payments_related_select'),
  ('receipts', 'receipts_related_users'),
  ('parking_activity_logs', 'parking_activity_logs_related_users'),
  ('profile_settings', 'profile_settings_owner_or_admin'),
  ('device_push_tokens', 'device_push_tokens_owner_or_admin')
) as required(table_name, policy_name);

-- Triggers from SQL patches.
select pg_temp.record_check(
  'trigger ' || table_name || '.' || trigger_name,
  exists (
    select 1
    from pg_trigger t
    join pg_class c on c.oid = t.tgrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = required.table_name
      and t.tgname = required.trigger_name
      and not t.tgisinternal
  ),
  'Required trigger'
)
from (values
  ('vehicles', 'vehicles_set_updated_at'),
  ('reviews', 'refresh_parking_lot_rating_from_review'),
  ('bookings', 'notify_provider_on_booking_created'),
  ('bookings', 'notify_customer_on_booking_status'),
  ('complaints', 'notify_super_admin_on_complaint'),
  ('provider_applications', 'notify_super_admin_on_provider_application'),
  ('profile_settings', 'set_profile_settings_updated_at')
) as required(table_name, trigger_name);

-- Supabase Realtime publication membership.
select pg_temp.record_check(
  'realtime public.' || table_name,
  exists (
    select 1
    from pg_publication_tables p
    where p.pubname = 'supabase_realtime'
      and p.schemaname = 'public'
      and p.tablename = required.table_name
  ),
  'Required table in supabase_realtime publication'
)
from (values
  ('parking_slots'),
  ('parking_lots'),
  ('notifications'),
  ('parking_guards'),
  ('bookings'),
  ('payments'),
  ('guard_lot_assignments')
) as required(table_name);

-- Storage buckets.
select pg_temp.record_check(
  'storage bucket ' || bucket_id,
  exists (
    select 1
    from storage.buckets b
    where b.id = required.bucket_id
  ),
  'Required Supabase Storage bucket'
)
from (values
  ('avatars'),
  ('parking-lot-photos'),
  ('provider-identity-documents')
) as required(bucket_id);

-- pg_cron extension and expiry job.
select pg_temp.record_check(
  'extension pg_cron',
  exists (select 1 from pg_extension where extname = 'pg_cron'),
  'Required for reservation expiry job'
);

do $$
declare
  v_has_cron_job_table boolean;
  v_job_exists boolean := false;
begin
  select exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'cron'
      and c.relname = 'job'
  )
  into v_has_cron_job_table;

  if v_has_cron_job_table then
    execute $q$
      select exists (
        select 1
        from cron.job
        where jobname = 'expire-stale-parking-bookings'
          and active
      )
    $q$
    into v_job_exists;
  end if;

  perform pg_temp.record_check(
    'cron job expire-stale-parking-bookings',
    v_job_exists,
    'Required active job for pending_payment expiry'
  );
end;
$$;

-- Summary first, then full detail.
select
  count(*) filter (where status = 'OK') as ok_count,
  count(*) filter (where status = 'MISSING') as missing_count,
  count(*) as total_count
from production_sql_verification_check;

select *
from production_sql_verification_check
order by
  case status when 'MISSING' then 0 else 1 end,
  check_name;
