-- Enable Supabase Realtime events for parking slot changes.
-- Run this once in Supabase SQL Editor.

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'parking_slots'
  ) then
    alter publication supabase_realtime add table public.parking_slots;
  end if;
end $$;
