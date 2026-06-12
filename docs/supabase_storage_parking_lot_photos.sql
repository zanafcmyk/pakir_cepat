-- Run this once to allow authenticated providers to upload parking lot photos.

insert into storage.buckets (id, name, public)
values ('parking-lot-photos', 'parking-lot-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "parking_lot_photos_public_read" on storage.objects;
create policy "parking_lot_photos_public_read"
on storage.objects for select
using (bucket_id = 'parking-lot-photos');

drop policy if exists "parking_lot_photos_provider_upload" on storage.objects;
create policy "parking_lot_photos_provider_upload"
on storage.objects for insert
with check (
  bucket_id = 'parking-lot-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
  and exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.role = 'provider'
  )
);

drop policy if exists "parking_lot_photos_provider_update" on storage.objects;
create policy "parking_lot_photos_provider_update"
on storage.objects for update
using (
  bucket_id = 'parking-lot-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
  and exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.role = 'provider'
  )
)
with check (
  bucket_id = 'parking-lot-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
  and exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.role = 'provider'
  )
);

drop policy if exists "parking_lot_photos_provider_delete" on storage.objects;
create policy "parking_lot_photos_provider_delete"
on storage.objects for delete
using (
  bucket_id = 'parking-lot-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
  and exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.role = 'provider'
  )
);
