# Audit RLS Supabase

Dokumen ini mencatat hasil audit Row Level Security untuk fitur sinkron antar role Parkir Cepat.

## Temuan

- Policy utama di `docs/supabase_schema.sql` sudah membatasi data inti berdasarkan role terkait: customer, penyedia, penjaga, dan super admin.
- Tabel tambahan seperti `customer_settings`, `customer_favorite_lots`, `parking_activity_logs`, `receipts`, `profile_settings`, dan `device_push_tokens` sudah punya SQL RLS terpisah.
- Fitur notifikasi antar role membutuhkan insert notifikasi ke profil lain. Policy `notifications_owner_or_admin` sengaja ketat, sehingga insert langsung dari client biasa bisa ditolak.
- Fitur chat target spesifik membutuhkan lookup profil target. Policy `profiles_select_own_or_admin` sengaja ketat, sehingga lookup profil target dari client biasa bisa kosong.

## Patch Yang Disiapkan

- SQL patch: `docs/supabase_role_sync_rls_patch.sql`.
- Patch ini menambahkan RPC `security definer` untuk:
  - resolve target chat dengan kolom minimal: `id`, `full_name`, `role`, `access_status`;
  - membuat notifikasi ke profil/role/lokasi/penjaga assignment tanpa membuka policy table langsung.

## Status Kode

- `SupabaseNotificationService` mencoba RPC notification terlebih dulu, lalu fallback ke table insert lama jika SQL patch belum dijalankan.
- `SupabaseChatService` mencoba RPC target resolver terlebih dulu, lalu fallback ke query lama jika SQL patch belum dijalankan.

## Perlu Dijalankan Di Supabase

- [ ] Jalankan `docs/supabase_role_sync_rls_patch.sql` di SQL Editor Supabase production.
- [ ] Uji customer booking dan pastikan notifikasi masuk ke penyedia lokasi serta penjaga assignment.
- [ ] Uji chat customer-penyedia/customer-penjaga dengan lebih dari satu penyedia dan penjaga.
- [ ] Jika ada error RLS, cek apakah SQL patch sudah sukses dan semua function mendapat grant execute ke `authenticated`.
