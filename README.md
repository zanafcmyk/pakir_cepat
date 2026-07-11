# Parkir Cepat

Parkir Cepat adalah aplikasi mobile smart parking berbasis Flutter untuk
customer, penyedia parkir, penjaga parkir, dan super admin.

Aplikasi membantu customer mencari lokasi parkir, menyimpan kendaraan, booking,
melakukan pembayaran, memakai tiket QR, melihat riwayat, menerima notifikasi,
chat, komplain, favorit, dan review. Di sisi operasional, penyedia mengelola
lokasi, slot, penjaga, transaksi, dan laporan. Penjaga melakukan scan tiket dan
validasi kendaraan masuk/keluar. Super admin memantau sistem, memverifikasi
penyedia, dan menangani komplain.

## Status Project

Project ini sudah melewati tahap prototype lokal sederhana. Sebagian besar alur
utama sudah diarahkan ke integrasi Supabase, dengan dukungan Firebase Cloud
Messaging, Midtrans, deep link, dan Supabase Edge Functions. Beberapa bagian
production tetap membutuhkan konfigurasi eksternal di dashboard Supabase,
Firebase, dan Midtrans.

## Tech Stack

- Flutter 3.41.x dan Dart 3.11.x
- Riverpod untuk state management
- GoRouter untuk routing
- Supabase Auth, Database, Storage, Realtime, RPC, dan Edge Functions
- Firebase Cloud Messaging untuk push notification
- Midtrans Snap melalui Supabase Edge Function
- Flutter Map, WebView, QR, PDF, printing, image picker, dan mobile scanner

## Struktur Penting

```text
lib/
  app.dart                         Main UI, routing, controller, dan screens
  main.dart                        Supabase bootstrap via dart-define
  firebase_options.dart            Firebase config via dart-define
  models/                          Model aplikasi
  services/                        Integrasi Supabase, Firebase, payment, dll
  utils/                           Helper domain
  widgets/                         Widget platform khusus

supabase/functions/                Edge Functions
docs/                              PRD, SQL patch, audit, dan checklist deploy
test/                              Unit/widget tests
android/, ios/, web/               Platform Flutter
```

## Prasyarat

Pastikan tool berikut tersedia di PATH:

- Flutter
- Git
- Android Studio atau Android SDK
- JDK yang kompatibel dengan Flutter/Android

Cek environment:

```bash
flutter doctor -v
git --version
```

## Environment

Supabase wajib diberikan lewat `--dart-define`. Aplikasi tidak lagi memakai
fallback URL/key hardcoded.

Minimal:

```bash
--dart-define=SUPABASE_URL=https://<project-ref>.supabase.co
--dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

Firebase bersifat opsional untuk build dasar, tetapi dibutuhkan untuk push
notification production:

```bash
--dart-define=FIREBASE_API_KEY=...
--dart-define=FIREBASE_APP_ID=...
--dart-define=FIREBASE_MESSAGING_SENDER_ID=...
--dart-define=FIREBASE_PROJECT_ID=...
--dart-define=FIREBASE_STORAGE_BUCKET=...
--dart-define=FIREBASE_WEB_VAPID_KEY=...
```

Tambahan platform jika diperlukan:

```bash
--dart-define=FIREBASE_ANDROID_CLIENT_ID=...
--dart-define=FIREBASE_IOS_BUNDLE_ID=...
--dart-define=FIREBASE_IOS_CLIENT_ID=...
```

## Menjalankan Project

Install dependency:

```bash
flutter pub get
```

Jalankan app:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

Di PowerShell, gunakan backtick untuk multi-line:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

## Verifikasi

```bash
flutter analyze
flutter test
```

Saat README ini diperbarui, hasil terakhir:

- `flutter analyze`: no issues found
- `flutter test`: 31 tests passed

## Build Android

Debug APK:

```bash
flutter build apk --debug \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

Release APK:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<supabase-publishable-key>
```

Release signing membaca `android/key.properties` jika file tersebut tersedia.
Jika signing belum dikonfigurasi, build release memakai signing debug sesuai
konfigurasi Gradle saat ini.

## Supabase dan Edge Functions

Kode Edge Function tersedia di:

```text
supabase/functions/
```

Function utama:

- `create-midtrans-payment`
- `midtrans-webhook`
- `send-push-notification`
- `delete-account`
- `admin-delete-user`
- `create-guard-account`

Secret seperti `SERVICE_ROLE_KEY`, `MIDTRANS_SERVER_KEY`,
`FIREBASE_SERVICE_ACCOUNT_JSON`, dan `PUSH_FUNCTION_SECRET` tidak boleh
dimasukkan ke Flutter. Simpan secret tersebut di Supabase.

Panduan terkait:

- `docs/payment_push_production_setup.md`
- `docs/production_external_deploy_checklist.md`
- `docs/production_midtrans_expiry_scan_runbook.md`

## Dokumen

- PRD: `docs/PRD.md`
- Panduan demo laptop: `docs/DEMO_PRESENTATION_GUIDE.md`
- Checklist deploy eksternal: `docs/production_external_deploy_checklist.md`
- Setup payment dan push notification: `docs/payment_push_production_setup.md`
- Audit deep link: `docs/deep_link_device_audit_2026-06-29.md`
- Status role system: `docs/ROLE_SYNC_STATUS.md`

## Catatan Maintenance

- `lib/app.dart` masih menjadi file utama yang besar. Refactor sebaiknya
  dilakukan bertahap per area fitur: auth, customer, provider, guard, super
  admin, routing, dan shared widgets.
- Update dependency sebaiknya dilakukan selektif, lalu selalu diikuti
  `flutter analyze` dan `flutter test`.
- Untuk production, selesaikan checklist SQL, Edge Functions, Firebase,
  Midtrans, deep link, dan uji perangkat asli.
