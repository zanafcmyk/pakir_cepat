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
- `APP_PAYMENT_FINISH_URL` boleh kosong jika belum punya deep link final.

## Midtrans

Pasang webhook URL ini di dashboard Midtrans:

```text
https://<project-ref>.supabase.co/functions/v1/midtrans-webhook
```

Uji sandbox:

1. Buat booking customer.
2. Pilih payment online.
3. Pastikan halaman Snap terbuka.
4. Selesaikan pembayaran sandbox.
5. Pastikan `payments.status` dan `bookings.status` berubah dari webhook.

## Firebase Push Notification

Yang belum ada di Flutter saat dokumen ini dibuat:

- Package Firebase di `pubspec.yaml`.
- File `android/app/google-services.json`.
- File `ios/Runner/GoogleService-Info.plist`.
- Registrasi FCM token device ke tabel `device_push_tokens`.

Langkah production:

1. Buat Firebase project.
2. Tambahkan app Android dan iOS.
3. Pasang file config Firebase ke folder platform.
4. Tambahkan dependency Firebase Messaging di Flutter.
5. Minta permission notifikasi di aplikasi.
6. Simpan FCM token ke `device_push_tokens`.
7. Panggil `send-push-notification` dari trigger/event booking, payment, komplain, atau tugas penjaga.
