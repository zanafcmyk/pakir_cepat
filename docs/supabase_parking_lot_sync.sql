-- Parkir Cepat parking lot sync additions
-- Run this if you have already applied docs/supabase_schema_additions.sql.

alter type public.parking_tariff_type add value if not exists 'daily';
alter type public.parking_tariff_type add value if not exists 'progressive';
