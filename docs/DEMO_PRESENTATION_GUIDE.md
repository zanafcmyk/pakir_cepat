# Panduan Demo Laptop - Parkir Cepat

Dokumen ini dipakai untuk presentasi atau demonstrasi Parkir Cepat dari laptop sebelum membuat AAB update. Fokus demo adalah memperlihatkan alur utama aplikasi, bukan proses deploy Play Store.

## 1. Tujuan Demo

- Menunjukkan aplikasi smart parking untuk customer, penyedia parkir, penjaga parkir, dan super admin.
- Menjelaskan bahwa data utama sudah memakai Supabase.
- Menunjukkan alur login, session tetap aktif, booking, pembayaran, QR, laporan, dan dashboard role.
- Menyiapkan narasi teknis bila dosen/client bertanya file mana yang mengatur fitur tertentu.

## 2. Prasyarat Laptop

Pastikan laptop sudah memiliki:

- Flutter SDK.
- Git.
- Chrome atau Android Emulator.
- Koneksi internet.
- Supabase project yang sudah berisi schema, RLS, Edge Function, dan data akun demo.

Cek environment:

```powershell
flutter doctor -v
flutter devices
```

## 3. Environment Wajib

Aplikasi membutuhkan Supabase dari `--dart-define`.

```powershell
$env:SUPABASE_URL="https://<project-ref>.supabase.co"
$env:SUPABASE_PUBLISHABLE_KEY="<supabase-publishable-key>"
```

Untuk sekali jalan tanpa menyimpan env:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

Jika memakai emulator/HP Android:

```powershell
flutter run -d <device-id> `
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

## 4. Cara Demo Paling Aman

Untuk presentasi di laptop, gunakan Chrome bila fitur kamera/scan QR fisik tidak perlu diuji. Gunakan Android Emulator atau HP asli bila ingin menunjukkan:

- Deep link Google login.
- Deep link reset password.
- Callback pembayaran.
- Push notification.
- Kamera scan QR.

Urutan aman:

1. Jalankan aplikasi di Chrome atau emulator.
2. Login sebagai customer.
3. Tutup tab/app lalu buka lagi untuk menunjukkan session tetap masuk dashboard.
4. Tunjukkan cari lokasi, detail lokasi, kendaraan, booking, payment, tiket QR, riwayat, receipt.
5. Login sebagai penyedia untuk menunjukkan lokasi, slot, penjaga, laporan.
6. Login sebagai penjaga untuk menunjukkan lokasi tugas, scan QR, kendaraan aktif, laporan gaji.
7. Login sebagai super admin untuk menunjukkan verifikasi penyedia, user management, komplain, laporan global.

## 5. Akun Demo

Isi akun demo sesuai data Supabase yang dipakai saat presentasi.

| Role | Email | Password | Catatan |
| --- | --- | --- | --- |
| Customer | `isi-email-customer` | `isi-password` | Untuk booking dan pembayaran |
| Penyedia | `isi-email-penyedia` | `isi-password` | Harus verified agar masuk dashboard |
| Penjaga | `isi-email-penjaga` | `isi-password` | Harus sudah ditugaskan ke lokasi |
| Super Admin | `isi-email-super-admin` | `isi-password` | Untuk verifikasi dan laporan global |

Jangan commit password production asli ke repo.

## 6. Checklist Supabase Sebelum Demo

- Auth provider email/password aktif.
- Google provider aktif bila ingin demo Google login.
- Redirect URL Supabase memuat:

```text
parkircepat://auth/callback
parkircepat://reset-password
```

- Tabel `profiles` berisi role yang benar: `customer`, `provider`, `parking_guard`, `super_admin`.
- Akun penyedia yang didemokan sudah `verified`.
- Akun penjaga sudah punya assignment lokasi.
- Lokasi parkir dan slot tersedia.
- Edge Function payment, guard account, delete account, dan push sudah dideploy bila ingin demo penuh.

## 7. Narasi Demo Per Role

### Customer

Customer dapat mencari lokasi parkir, melihat slot, menambah kendaraan, membuat booking, memilih pembayaran, menerima QR tiket, melihat riwayat, receipt, favorit, review, chat, komplain, dan notifikasi.

### Penyedia

Penyedia dapat mengelola lokasi, slot, penjaga, monitoring kendaraan, transaksi, notifikasi, profil, dan laporan pendapatan. Laporan juga menampilkan estimasi gaji penjaga sebesar 15% dari revenue lokasi yang memiliki penjaga.

### Penjaga

Penjaga login dari akun yang dibuat penyedia. Penjaga melihat lokasi tugas, scan QR customer, konfirmasi kendaraan masuk/keluar, mengecek pembayaran, melihat kendaraan aktif, dan laporan gaji.

### Super Admin

Super admin memantau pengguna, memverifikasi penyedia, mengelola status akun, menangani komplain, dan melihat laporan global lintas lokasi.

## 8. Catatan File Untuk Presentasi

Gunakan bagian ini sebagai komentar/penjelasan per file saat mempresentasikan kode.

| File/Folder | Fungsi Saat Dijelaskan |
| --- | --- |
| `lib/main.dart` | Entry point aplikasi dan bootstrap Supabase dari `--dart-define`. |
| `lib/app.dart` | Pusat routing, state controller, screen utama, session restore, deep link, dan Google login. |
| `lib/models/app_models.dart` | Model domain seperti booking, kendaraan, lokasi, notifikasi, komplain, dan role. |
| `lib/services/` | Layer integrasi ke Supabase, payment, push notification, chat, booking, review, dan profile. |
| `lib/services/supabase_booking_service.dart` | Query booking aktif, riwayat customer, operasi penjaga, dan status transaksi. |
| `lib/services/supabase_parking_service.dart` | Data lokasi, slot, laporan penyedia, laporan gaji penjaga, dan statistik. |
| `lib/services/supabase_super_admin_service.dart` | Ringkasan dashboard super admin, user management, verifikasi penyedia, dan laporan global. |
| `lib/services/supabase_payment_service.dart` | Receipt dan integrasi payment melalui data Supabase. |
| `lib/services/supabase_guard_service.dart` | Akun penjaga, assignment lokasi, dan manajemen penjaga. |
| `lib/utils/app_preferences.dart` | Teks pengaturan akun dan bahasa aplikasi. |
| `lib/utils/tariff_calculator.dart` | Perhitungan tarif parkir. |
| `lib/widgets/map_embed_view*.dart` | Tampilan embed peta per platform. |
| `supabase/functions/` | Edge Function untuk payment, webhook, push, delete account, dan create guard account. |
| `docs/PRD.md` | Product Requirements Document terbaru. |
| `docs/production_external_deploy_checklist.md` | Checklist konfigurasi Supabase, Firebase, Midtrans, dan Play Store. |
| `test/` | Test route guard, booking expiry, model, tarif, dan widget. |

## 9. Masalah Yang Sering Muncul Saat Demo

### Aplikasi balik ke login setelah Google login

Pastikan redirect URL `parkircepat://auth/callback` sudah terdaftar di Supabase dan Google provider aktif. Kode aplikasi sudah memproses callback PKCE dengan `exchangeCodeForSession`.

### Setelah tutup aplikasi harus login ulang

Kode sudah diperbaiki agar session Supabase tetap dipulihkan sampai user menekan logout. Toggle login sekarang hanya menyimpan email, bukan menentukan session aktif.

### Data kosong di dashboard

Periksa Supabase URL/key, role profil, status penyedia, assignment penjaga, dan data lokasi/slot.

### Payment tidak kembali otomatis

Gunakan tombol refresh/polling status, cek webhook Midtrans, dan pastikan finish URL memakai `parkircepat://payment-finish`.

## 10. Setelah Demo

Jika ada perubahan kode yang ingin masuk ke rilis Android:

1. Jalankan `flutter analyze`.
2. Jalankan `flutter test`.
3. Naikkan version code di `pubspec.yaml`.
4. Build ulang AAB.
5. Upload AAB baru ke Play Console.
