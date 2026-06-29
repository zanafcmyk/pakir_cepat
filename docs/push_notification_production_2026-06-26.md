# Push Notification Production - 26 Juni 2026

Dokumen ini mencatat status push notification asli Parkir Cepat.

## Yang Sudah Dipasang Di Kode

- Dependency Flutter:
  - `firebase_core`
  - `firebase_messaging`
- Android permission:
  - `android.permission.POST_NOTIFICATIONS`
- iOS permission text:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
- App otomatis mencoba mendaftarkan token FCM setelah login/session restore.
- Token FCM disimpan ke tabel `device_push_tokens`.
- Token refresh otomatis memperbarui row di Supabase.
- Logout/delete account mencoba menghapus token device dari Supabase.
- Edge Function `send-push-notification` sekarang mewajibkan
  `PUSH_FUNCTION_SECRET`.
- Edge Function `send-push-notification` sudah dideploy ke Supabase production
  sebagai version 6.

## Cara Konfigurasi Firebase Di Flutter

Pilih salah satu cara.

### Opsi A - Native Firebase Files

Pasang file dari Firebase Console:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

Jika memakai cara ini, pastikan konfigurasi Firebase native tersedia saat build.

### Opsi B - Dart Define

Jalankan app dengan nilai berikut:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

Opsional:

```bash
--dart-define=FIREBASE_ANDROID_CLIENT_ID=...
--dart-define=FIREBASE_IOS_CLIENT_ID=...
--dart-define=FIREBASE_IOS_BUNDLE_ID=...
--dart-define=FIREBASE_WEB_VAPID_KEY=...
```

## Secret Supabase Yang Wajib Diisi

Isi di Supabase Dashboard atau CLI:

```bash
supabase secrets set FIREBASE_PROJECT_ID="..."
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
supabase secrets set PUSH_FUNCTION_SECRET="random-secret-panjang"
supabase secrets set SERVICE_ROLE_KEY="..."
```

Setelah secret berubah, deploy ulang:

```bash
supabase functions deploy send-push-notification --project-ref wdtjrzynjygkmpmhiffw
```

## Cara Cek Token Device Masuk

1. Jalankan app di HP/emulator yang punya Firebase config.
2. Login sebagai customer/penyedia/penjaga.
3. Izinkan notifikasi.
4. Jalankan SQL:

```sql
select profile_id, platform, device_name, last_seen_at
from public.device_push_tokens
order by last_seen_at desc
limit 20;
```

## Cara Test Kirim Push Manual

Ganti `PROFILE_ID_TARGET` dengan `profiles.id` user yang tokennya sudah masuk.

```bash
curl -X POST \
  "https://wdtjrzynjygkmpmhiffw.supabase.co/functions/v1/send-push-notification" \
  -H "Content-Type: application/json" \
  -H "x-push-secret: PUSH_FUNCTION_SECRET" \
  -d '{
    "profileIds": ["PROFILE_ID_TARGET"],
    "title": "Tes Parkir Cepat",
    "message": "Push notification berhasil.",
    "data": {"type": "test"}
  }'
```

Response sukses minimal:

```json
{"sent":1,"failed":0}
```

## Yang Masih Perlu Untuk Otomatis Event

Saat dokumen ini dibuat, app sudah mendaftarkan token dan Edge Function sudah
siap mengirim FCM. Agar push terkirim otomatis saat event terjadi, perlu salah
satu pemicu server-side:

- Supabase Database Webhook dari tabel `notifications` ke
  `send-push-notification`; atau
- trigger SQL/Edge Function khusus yang memanggil `send-push-notification` saat
  booking/payment/komplain dibuat.

Rekomendasi paling aman: pakai Database Webhook Supabase untuk event insert di
`public.notifications`, lalu kirim payload ke Edge Function dengan header
`x-push-secret`.
