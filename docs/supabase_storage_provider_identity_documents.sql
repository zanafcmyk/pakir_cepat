-- Run this once to allow providers to upload identity verification documents.

insert into storage.buckets (id, name, public)
values ('provider-identity-documents', 'provider-identity-documents', true)
on conflict (id) do update set public = true;

drop policy if exists "provider_identity_documents_public_read" on storage.objects;
create policy "provider_identity_documents_public_read"
on storage.objects for select
using (bucket_id = 'provider-identity-documents');

drop policy if exists "provider_identity_documents_owner_upload" on storage.objects;
create policy "provider_identity_documents_owner_upload"
on storage.objects for insert
with check (
  bucket_id = 'provider-identity-documents'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "provider_identity_documents_owner_update" on storage.objects;
create policy "provider_identity_documents_owner_update"
on storage.objects for update
using (
  bucket_id = 'provider-identity-documents'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'provider-identity-documents'
  and auth.uid()::text = (storage.foldername(name))[1]
);
