# Production External Deploy Checklist

Dokumen ini untuk langkah yang tidak bisa diselesaikan hanya dari kode Flutter,
karena membutuhkan secret, dashboard Supabase, dashboard Midtrans, atau Firebase.

## Booking dan Payment Security

Jalankan patch berikut di SQL Editor Supabase setelah schema dan patch role sync:

```text
docs/supabase_booking_payment_security_patch.sql
```

Patch ini wajib karena:

- mencabut `INSERT/UPDATE/DELETE` langsung client pada `bookings` dan `payments`;
- menghitung tarif booking di server;
- menyediakan RPC pembayaran tunai untuk penjaga atau operator penyedia;
- menyediakan RPC atomik scan masuk/keluar;
- mengizinkan penyedia mengoperasikan lokasi miliknya hanya saat tidak ada penjaga aktif.

Setelah berhasil, uji customer booking, pembayaran Midtrans, pembayaran tunai
penjaga, scan masuk, scan keluar, receipt, dan laporan provider.

## Secure QR Ticket

Jalankan patch berikut satu kali di SQL Editor Supabase setelah patch booking
dan payment security:

```text
docs/supabase_secure_ticket_qr.sql
```

Patch ini mengganti QR tiket dari nomor tiket polos menjadi token opaque di
`bookings.qr_payload`, melakukan backfill booking lama, dan memperbarui RPC
booking agar booking baru otomatis memakai token aman. Setelah berhasil, uji:

- customer melihat QR tiket setelah pembayaran;
- penjaga/operator bisa scan QR token baru untuk masuk dan keluar;
- input manual nomor tiket `TKT-...` masih bisa dipakai untuk pengecekan.

## Perpanjangan Durasi Booking

Jalankan patch berikut satu kali di SQL Editor Supabase:

```text
docs/supabase_booking_extension_patch.sql
```

Patch ini menambahkan RPC `app_extend_customer_booking` agar tambahan durasi,
tarif efektif, biaya total, dan sisa pembayaran dihitung di Supabase. Setelah
patch ini, deploy ulang `create-midtrans-payment` dan `midtrans-webhook` supaya
pembayaran tambahan hanya menagih sisa biaya yang belum lunas.

## Kedaluwarsa Reservasi

Jalankan patch berikut satu kali di SQL Editor Supabase:

```text
docs/supabase_booking_expiry.sql
```

Patch ini membuat job `pg_cron` setiap menit. Booking `pending_payment` yang
berumur lebih dari 15 menit akan menjadi `cancelled`, payment `pending` menjadi
`cancelled`, slot `reserved` kembali `available`, dan customer menerima
notifikasi in-app.

Setelah menunggu satu menit, jalankan query verifikasi yang tersedia pada bagian
bawah file SQL. Pastikan job aktif dan eksekusi terakhir berstatus `succeeded`.

## Repair Status Slot

Jalankan patch berikut satu kali di SQL Editor Supabase:

```text
docs/supabase_slot_status_repair.sql
```

Patch ini menambahkan RPC admin `app_repair_parking_slot_statuses` untuk
menyelaraskan status slot dari booking live:

- booking `active` membuat slot `occupied`;
- booking `pending_payment` atau `paid` membuat slot `reserved`;
- slot `reserved`/`occupied` tanpa booking live dikembalikan ke `available`;
- slot `blocked` tidak disentuh.

Setelah patch berhasil, jalankan repair satu kali:

```sql
select * from public.app_repair_parking_slot_statuses(null);
```

## Patch Tabel Kendaraan Lama

Jalankan patch berikut satu kali di SQL Editor Supabase jika saat menyimpan
kendaraan muncul error `column vehicles.created_at does not exist`:

```text
docs/supabase_vehicles_created_at_patch.sql
```

Patch ini menambahkan kolom `created_at` dan `updated_at` ke tabel `vehicles`
yang sudah terlanjur dibuat dari schema lama.

## Nonaktifkan atau Hapus Lahan

Jalankan patch berikut satu kali di SQL Editor Supabase:

```text
docs/supabase_provider_remove_parking_lot.sql
```

Patch ini menambahkan RPC `app_provider_remove_parking_lot` untuk tombol
nonaktif/hapus lahan di aplikasi penyedia:

- jika lahan belum memiliki booking historis, row `parking_lots` dihapus;
- jika sudah ada riwayat booking, lahan diarsipkan dengan `is_active=false`;
- jika masih ada booking `pending_payment`, `paid`, atau `active`, proses
  ditolak sampai booking tersebut selesai/dibatalkan/expired.

## Realtime Operasional Penjaga

Jalankan patch berikut satu kali di SQL Editor Supabase:

```text
docs/supabase_realtime_guard_operations.sql
```

Patch ini memasukkan tabel `bookings`, `payments`, dan `guard_lot_assignments`
ke publication realtime. Setelah dijalankan, halaman kendaraan aktif dan hasil
cek pembayaran penjaga akan memuat ulang data ketika pembayaran, scan masuk,
scan keluar, atau assignment lokasi berubah.

## Supabase Edge Functions

Deploy dari terminal project setelah Supabase CLI login dan project sudah linked.

```bash
supabase functions deploy admin-delete-user
supabase functions deploy create-midtrans-payment
supabase functions deploy midtrans-webhook --no-verify-jwt
supabase functions deploy send-push-notification
```

Secrets yang perlu diisi di Supabase:

```text
SERVICE_ROLE_KEY
MIDTRANS_SERVER_KEY
MIDTRANS_IS_PRODUCTION
APP_PAYMENT_FINISH_URL
FIREBASE_PROJECT_ID
FIREBASE_SERVICE_ACCOUNT_JSON
PUSH_FUNCTION_SECRET
```

Catatan:

- `SERVICE_ROLE_KEY` berisi service role key Supabase dan jangan dimasukkan ke Flutter.
- `MIDTRANS_IS_PRODUCTION=false` untuk sandbox.
- `midtrans-webhook` perlu `--no-verify-jwt` agar Midtrans bisa memanggil webhook.
- `APP_PAYMENT_FINISH_URL=parkircepat://payment-finish` agar aplikasi terbuka kembali setelah pembayaran.

## Midtrans

Pasang webhook URL ini di dashboard Midtrans:

```text
https://<project-ref>.supabase.co/functions/v1/midtrans-webhook
```

Finish/callback URL untuk aplikasi mobile:

```text
parkircepat://payment-finish
```

## Supabase Auth Redirect

Tambahkan redirect URL berikut di dashboard Supabase Auth:

```text
parkircepat://reset-password
```

Link ini dipakai email reset password agar membuka halaman set password baru
di aplikasi mobile.

## Simulasi Pembayaran Customer

Untuk demo/sandbox tanpa menunggu callback Midtrans, jalankan patch berikut di
SQL Editor Supabase:

```text
docs/supabase_simulate_customer_payment.sql
```

Patch ini menambahkan RPC `app_simulate_customer_payment` yang hanya bisa
melunasi booking milik customer yang sedang login dan masih `pending_payment`.
Tombol aplikasi bertuliskan **Simulasi pembayaran berhasil** akan langsung
mengaktifkan tiket, membuat payment, receipt, dan notifikasi in-app.

Uji sandbox:

1. Buat booking customer.
2. Pilih payment online.
3. Pastikan halaman Snap terbuka.
4. Selesaikan pembayaran sandbox.
5. Pastikan `payments.status` dan `bookings.status` berubah dari webhook.

## Firebase Push Notification

Yang sudah ada di Flutter:

- Package Firebase di `pubspec.yaml`.
- Permission notifikasi Android.
- Registrasi FCM token device ke tabel `device_push_tokens`.

Yang masih harus dipasang dari dashboard Firebase:

- File `android/app/google-services.json` atau dart-define Firebase.
- File `ios/Runner/GoogleService-Info.plist` atau dart-define Firebase.
- Secret Supabase `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT_JSON`, dan
  `PUSH_FUNCTION_SECRET`.

Langkah production:

1. Buat Firebase project.
2. Tambahkan app Android dan iOS.
3. Pasang file config Firebase ke folder platform.
4. Isi secret Firebase di Supabase.
5. Deploy ulang `send-push-notification`.
6. Login di HP dan pastikan token masuk ke `device_push_tokens`.
7. Aktifkan Database Webhook/trigger agar insert `notifications` memanggil
   `send-push-notification`.
