# Product Requirements Document — Parkir Cepat

**Versi Dokumen:** 3.0  
**Versi Aplikasi:** 1.0.2+3  
**Tanggal Terakhir Diperbarui:** 11 Juli 2026  
**Platform:** Android (Flutter)  
**Backend:** Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime)  
**Payment:** Midtrans Snap  
**Push Notification:** Firebase Cloud Messaging (FCM)

---

## 1. Ringkasan Produk

**Parkir Cepat** adalah aplikasi mobile smart parking berbasis Flutter yang menghubungkan empat jenis pengguna — customer, penyedia lahan parkir, penjaga parkir, dan super admin — dalam satu ekosistem digital yang terintegrasi penuh dengan Supabase.

Aplikasi membantu customer mencari lokasi parkir terdekat, melihat ketersediaan slot secara real-time, melakukan booking, membayar melalui Midtrans atau tunai, menggunakan tiket QR digital, melihat riwayat transaksi, memberikan review, mengirim komplain, dan menerima notifikasi.

Di sisi operasional, penyedia dapat mendaftarkan dan mengelola lokasi parkir beserta slotnya, membuat akun penjaga, memantau kendaraan yang masuk, serta melihat laporan pendapatan lengkap. Penjaga bertugas melakukan scan QR tiket customer dan mengonfirmasi status kendaraan masuk/keluar. Super admin memantau seluruh sistem, memverifikasi penyedia, mengelola komplain, dan melihat laporan global lintas lokasi.

### Status Rilis Saat Ini

Aplikasi telah melewati fase prototype dan kini berjalan penuh di atas Supabase production. Seluruh 272 item tasklist (100%) telah selesai dikerjakan per 29 Juni 2026. Versi `1.0.2+3` berhasil di-build sebagai AAB (45.8 MB) dan siap diupload ke Google Play Console.

Pembaruan paling terbaru pada `1.0.2+3` adalah penyempurnaan fitur geocoding real-time pada peta: saat penyedia mengetik alamat lokasi parkir di form tambah/edit lahan, peta dan marker titik koordinat langsung berpindah ke alamat tersebut secara otomatis menggunakan Nominatim OpenStreetMap API dengan debounce 800ms.

---

## 2. Tujuan Produk

### Tujuan Customer

- Menemukan lokasi parkir terdekat dengan cepat berdasarkan GPS.
- Melihat ketersediaan slot sebelum datang ke lokasi.
- Menyimpan kendaraan pribadi (motor, mobil, truk).
- Melakukan booking parkir dan menerima tiket QR digital.
- Membayar parkir melalui Midtrans (QRIS/e-wallet) atau tunai ke penjaga.
- Melihat riwayat transaksi, receipt, dan bukti pembayaran.
- Mengirim komplain dan chat dengan penyedia/admin.
- Memberikan rating dan review lokasi parkir.
- Menerima notifikasi booking, pembayaran, dan status parkir.

### Tujuan Penyedia Parkir

- Mendaftarkan dan mengelola lokasi parkir beserta slot.
- Membuat dan mengelola akun penjaga untuk operasional lapangan.
- Memantau kendaraan yang masuk dan keluar secara real-time.
- Melihat laporan pendapatan harian, bulanan, dan estimasi gaji penjaga.
- Berinteraksi dengan customer melalui chat dan notifikasi.
- Mengelola profil, foto lahan, dan dokumen identitas.

### Tujuan Penjaga Parkir

- Login menggunakan akun yang dibuat penyedia.
- Melihat daftar lokasi yang ditugaskan.
- Scan QR tiket customer untuk verifikasi kendaraan masuk.
- Mengonfirmasi kendaraan keluar dan pembayaran tunai.
- Melihat estimasi laporan gaji berdasarkan lokasi tugas.

### Tujuan Super Admin

- Memverifikasi dan menyetujui pendaftaran penyedia.
- Memantau aktivitas seluruh role dalam sistem.
- Mengelola status komplain dan membalas pesan.
- Mengelola user (aktif/nonaktif/hapus akun).
- Melihat laporan global: revenue, transaksi, statistik lintas lokasi.

---

## 3. Role Pengguna

### 3.1 Customer

Pengguna akhir yang mencari dan memakai layanan parkir.

**Akses:** Register mandiri → langsung aktif.

Kebutuhan utama:
- Register dan login (email-password atau Google OAuth).
- Tambah kendaraan dengan input plat nomor.
- Cari, filter, dan lihat lokasi parkir dari Supabase.
- Booking parkir dengan pemilihan slot dan waktu masuk.
- Bayar via Midtrans atau tunai ke penjaga.
- Terima dan gunakan tiket QR digital.
- Lihat riwayat, receipt, favorit, review, chat, komplain, notifikasi.

### 3.2 Penyedia Parkir

Pemilik atau pengelola lokasi parkir.

**Akses:** Register → menunggu verifikasi super admin → aktif.

Kebutuhan utama:
- Register dengan data lahan, foto, dan dokumen identitas.
- Menunggu persetujuan super admin sebelum bisa masuk dashboard.
- Tambah lokasi parkir, kelola slot, dan atur tarif (per jam/flat/harian).
- Buat akun penjaga melalui Edge Function.
- Lihat laporan pendapatan, statistik grafik, dan estimasi gaji penjaga.
- Edit profil, avatar, dan pengaturan akun.

### 3.3 Penjaga Parkir

Petugas operasional di lokasi parkir.

**Akses:** Akun dibuat oleh penyedia → login langsung.

Kebutuhan utama:
- Login dengan akun dari penyedia.
- Lihat lokasi yang ditugaskan.
- Scan QR customer untuk verifikasi masuk/keluar.
- Konfirmasi pembayaran tunai melalui RPC khusus.
- Lihat kendaraan aktif dan estimasi laporan gaji.
- Edit profil dan avatar.

### 3.4 Super Admin

Admin pusat aplikasi dengan akses penuh.

**Akses:** Login khusus super admin (tidak melalui register publik).

Kebutuhan utama:
- Verifikasi penyedia dari daftar pengajuan.
- Pantau semua role, komplain, dan transaksi.
- Kelola user (aktif/nonaktif/hapus akun Auth).
- Lihat laporan dan statistik global lintas lokasi.

---

## 4. Scope Fitur

### 4.1 Autentikasi dan Akun

**Fitur:**
- Splash screen dengan pemeriksaan versi aplikasi minimum (via Supabase).
- Onboarding tersimpan permanen di perangkat (SharedPreferences).
- Login dan register customer, penyedia, penjaga, super admin.
- Google OAuth login customer dengan callback `parkircepat://auth/callback`.
- Restore session login otomatis saat aplikasi dibuka ulang.
- Forgot password: kirim email reset → halaman set password baru di aplikasi.
- Ganti password tersimpan ke Supabase Auth.
- Hapus akun sungguhan via Edge Function `delete-account`.
- Upload avatar/profil ke Supabase Storage, load saat login.
- Route protection berdasarkan role yang sedang login.

**Status Production:**
- Supabase Auth aktif untuk semua role.
- Google login dengan Supabase OAuth dan fallback PKCE berjalan.
- Session dipulihkan dari Supabase saat aplikasi dibuka, bertahan hingga logout.
- Reset password dari email mengarah ke halaman `/reset-password`.
- Edge Function `delete-account` dan `admin-delete-user` terdeploy.
- Route guard dasar sudah diaudit dan diuji di perangkat Android asli.
- Konfigurasi redirect Supabase memuat `parkircepat://auth/callback` dan `parkircepat://reset-password`.

---

### 4.2 Customer

**Fitur:**
- Dashboard customer: lokasi terdekat, booking aktif, ETA berbasis GPS.
- Daftar dan detail lokasi parkir dengan foto, rating, tarif, slot tersedia.
- Search dan filter lokasi dari Supabase (nama/alamat).
- Tambah kendaraan (motor, mobil, truk) dengan plat nomor.
- Booking parkir: pilih lokasi, slot, kendaraan, waktu masuk; tarif dihitung server-side.
- Perpanjang durasi parkir dengan tagihan tambahan via Supabase RPC.
- Tiket QR digital berbasis token opaque `qr_payload` dari Supabase.
- Payment via Midtrans Snap (QRIS/e-wallet) atau tunai dikonfirmasi penjaga.
- Riwayat transaksi dan receipt dari Supabase.
- Receipt dapat dicetak/diekspor sebagai PDF.
- Favorit lokasi parkir tersimpan ke Supabase.
- Review dan rating lokasi parkir.
- Komplain tersimpan ke Supabase; balasan admin tampil sebagai thread.
- Chat realtime dengan penyedia/penjaga/admin.
- Notifikasi in-app untuk booking, pembayaran, verifikasi, dan komplain.
- Settings customer tersimpan ke Supabase.

**Status Production:**
- Booking memakai RPC server-side; tarif dihitung dari lahan, jenis kendaraan, tipe tarif, dan durasi.
- Midtrans Snap terhubung via Edge Function `create-midtrans-payment` (v17).
- Webhook Midtrans `midtrans-webhook` (v12) menerima callback dengan idempotensi payment.
- Callback selesai pembayaran kembali ke aplikasi via `parkircepat://payment-finish`.
- Booking expired otomatis diproses server-side via `pg_cron` tiap menit (30 menit).
- QR tiket menggunakan token opaque dari `bookings.qr_payload` (bukan ID langsung).
- Receipt customer dapat dicetak/diekspor sebagai PDF.
- ETA dan jarak lokasi berbasis GPS perangkat; fallback data lama bila GPS mati.

---

### 4.3 Penyedia Parkir

**Fitur:**
- Dashboard penyedia: ringkasan kendaraan masuk hari ini, pendapatan, slot tersedia/penuh.
- Tambah, edit, dan nonaktifkan/hapus lokasi parkir.
- Kelola slot parkir (tambah slot, ubah status).
- Penyedia dapat menjadi operator scan/tunai bila tidak ada penjaga aktif.
- Membuat akun penjaga via Edge Function `create-guard-account`.
- Monitoring kendaraan: transaksi dan booking dari lokasi milik penyedia.
- Laporan keuangan: pendapatan harian, bulanan, estimasi gaji penjaga 15%, estimasi laba bersih.
- Statistik grafik pendapatan 7 hari terakhir dari Supabase.
- Notifikasi in-app dari customer dan sistem.
- Profil penyedia dan avatar tersimpan ke Supabase.
- Upload foto lahan ke Supabase Storage (`parking-lot-photos`).
- Upload dokumen identitas ke Supabase Storage saat registrasi.
- **Geocoding real-time:** saat mengetik nama/alamat lahan di form tambah/edit, peta dan marker titik koordinat berpindah otomatis ke alamat tersebut (Nominatim OpenStreetMap, debounce 800ms).

**Status Production:**
- Upload foto lahan dan dokumen identitas berjalan via Supabase Storage.
- Statistik, laporan pendapatan, dan daily revenue membaca agregasi Supabase.
- Estimasi gaji penjaga dihitung 15% dari revenue lokasi berdasarkan assignment; dibagi rata bila ada beberapa penjaga per lokasi.
- Lokasi tanpa riwayat booking dapat dihapus; lokasi dengan riwayat diarsipkan (nonaktif).
- Settings penyedia tersimpan ke Supabase via `profile_settings`.
- Akun penjaga dibuat melalui Edge Function aman dengan validasi penyedia.
- Geocoding map: perbaikan `didUpdateWidget` + `addPostFrameCallback` memastikan kamera dan marker peta berpindah setelah frame selesai render.

---

### 4.4 Penjaga Parkir

**Fitur:**
- Dashboard penjaga: lokasi yang ditugaskan, slot aktif lokasi assignment.
- Scan QR tiket customer untuk verifikasi kendaraan masuk.
- Input manual nomor tiket `TKT-...` sebagai alternatif scan.
- Konfirmasi kendaraan keluar dan pembayaran tunai via RPC khusus.
- Cek status pembayaran customer berdasarkan nomor tiket/plat.
- Daftar kendaraan aktif dari seluruh booking di lokasi assignment.
- Listener realtime: booking/payment di lokasi assignment diperbarui tanpa reload halaman.
- Estimasi laporan gaji penjaga dari revenue lokasi tugas.
- Profil, avatar, dan settings penjaga tersimpan ke Supabase.

**Status Production:**
- Scan dan konfirmasi masuk/keluar memakai RPC atomik dengan validasi assignment, status sebelumnya, update slot, dan activity log.
- Konfirmasi tunai menggunakan RPC `app_operator_confirm_cash_payment` dengan validasi izin, assignment, nominal server, payment, receipt, dan activity log.
- Realtime booking/payment operasional aktif via Supabase Realtime.
- Settings penjaga tersimpan ke Supabase via `profile_settings`.

---

### 4.5 Super Admin

**Fitur:**
- Dashboard super admin: agregasi jumlah customer, penyedia, penjaga, pengajuan pending, akun nonaktif, komplain menunggu, lokasi aktif, kendaraan aktif, total transaksi, dan total revenue.
- Verifikasi penyedia dari daftar `provider_applications`.
- Melihat dan mengelola status komplain dari semua role.
- User management: daftar profil, aktif/nonaktif, hapus akun Auth via Edge Function.
- Laporan global: transaksi lintas lokasi, grafik revenue 7 hari.
- Edit profil dan avatar super admin tersimpan ke Supabase.
- Notifikasi in-app dari sistem.

**Status Production:**
- Dashboard membaca agregasi Supabase untuk semua metrik utama.
- Verifikasi penyedia membaca dari `provider_applications` dengan fallback `providers`.
- User management menyimpan `access_status` ke `profiles`.
- Edge Function `admin-delete-user` terdeploy untuk hapus akun Auth user lain.
- Laporan global membaca transaksi dan grafik revenue dari Supabase.

---

### 4.6 Laporan dan Statistik

#### Customer
- Riwayat transaksi hanya menampilkan booking milik customer yang sedang login.
- Detail: lokasi, kendaraan, waktu masuk/keluar, status, metode pembayaran, total biaya.
- Receipt dapat dicetak/diekspor sebagai PDF.

#### Penyedia
- Laporan keuangan membaca transaksi dari lokasi milik penyedia.
- Ringkasan: total pendapatan, pendapatan hari ini/bulan ini, estimasi pengeluaran gaji, estimasi laba bersih, jumlah transaksi, slot tersedia/terisi.
- Statistik: grafik pendapatan 7 hari terakhir.
- Gaji penjaga: 15% revenue lokasi yang memiliki assignment penjaga aktif; dibagi rata bila lebih dari satu penjaga per lokasi.

#### Penjaga
- Laporan gaji berdasarkan lokasi yang ditugaskan ke akun penjaga saat ini.
- Ringkasan: estimasi gaji hari ini, estimasi gaji bulan ini, revenue hari ini, revenue bulan ini, lokasi tugas.
- Perhitungan mengikuti aturan 15% dari revenue lokasi assignment.

#### Super Admin
- Agregasi jumlah customer, penyedia, penjaga, komplain, lokasi, dan transaksi.
- Laporan global: daftar transaksi lintas lokasi, grafik revenue 7 hari.
- Persiapan export PDF/Excel untuk kebutuhan administrasi.

**Status Production:**
- Semua laporan sudah membaca agregasi Supabase production.
- Perhitungan gaji penjaga 15% sudah diterapkan.
- Receipt customer sudah dapat dicetak/diekspor sebagai PDF.
- Nominal laporan konsisten menggunakan `final_cost` bila tersedia, fallback ke `estimated_cost`.

---

### 4.7 Keamanan dan Integritas Data

- RLS (Row Level Security) aktif di seluruh tabel utama Supabase.
- Booking dan payment tidak dapat dimanipulasi client-side; tarif dihitung server via RPC.
- Scan masuk/keluar menggunakan RPC atomik dengan validasi assignment penjaga.
- Konfirmasi tunai penjaga menggunakan RPC khusus dengan validasi izin server-side.
- Booking expired diproses server-side via `pg_cron` (30 menit) tanpa intervensi client.
- QR tiket menggunakan token opaque `qr_payload`, bukan ID booking langsung.
- Payment webhook Midtrans dilindungi dengan guard idempotensi agar status `paid` tidak bisa downgrade.
- Edge Function `send-push-notification` dilindungi `PUSH_FUNCTION_SECRET`.

---

### 4.8 Kesiapan Demo dan Presentasi

Aplikasi dapat dipresentasikan dari laptop untuk keperluan laporan, sidang, atau demonstrasi.

**Scope demo:**
- Aplikasi dapat dijalankan via Chrome, emulator Android, atau perangkat Android asli dengan `flutter run`.
- Demo Chrome: UI, dashboard, data Supabase, laporan, dan alur role dasar.
- Demo emulator/HP Android: kamera scan QR, callback Midtrans, push notification, custom scheme.
- Panduan presentasi: `docs/DEMO_PRESENTATION_GUIDE.md`.

**Alur demo yang direkomendasikan:**
1. Jalankan aplikasi dengan Supabase `--dart-define`.
2. Login customer → session tetap aktif setelah aplikasi ditutup/dibuka ulang.
3. Tunjukkan: cari lokasi, detail lokasi, kendaraan, booking, pembayaran, tiket QR, riwayat, receipt, komplain, notifikasi.
4. Login penyedia → lokasi, slot, akun penjaga, monitoring, laporan, geocoding map.
5. Login penjaga → lokasi tugas, scan QR, kendaraan aktif, konfirmasi tunai, laporan gaji.
6. Login super admin → verifikasi penyedia, user management, komplain, dashboard, laporan global.

---

## 5. Integrasi Supabase

### Sudah Terhubung Production

- Auth: customer, penyedia, penjaga, super admin (email-password + Google OAuth).
- Tabel profil, role, dan status verifikasi.
- Lokasi parkir dan slot parkir.
- Kendaraan customer.
- Booking parkir (RPC server-side, tarif server, atomic reserve slot).
- Payment Midtrans dan tunai penjaga (RPC aman).
- Booking aktif, riwayat transaksi, receipt.
- Perpanjangan durasi parkir (RPC).
- Booking expiry otomatis via `pg_cron` (30 menit).
- Scan QR (token opaque, RPC atomik masuk/keluar).
- Komplain, chat realtime, notifikasi in-app.
- Akun penjaga (Edge Function `create-guard-account`).
- Favorit lokasi, review/rating.
- Edit profil semua role, avatar (Supabase Storage).
- Foto lahan parkir (Supabase Storage `parking-lot-photos`).
- Dokumen identitas penyedia (Supabase Storage).
- Settings customer, penyedia, penjaga (tabel `profile_settings`).
- Google login (Supabase OAuth + PKCE fallback).
- Restore session login saat aplikasi dibuka ulang.
- Reset password + halaman set password baru.
- Hapus akun (Edge Function `delete-account`, `admin-delete-user`).
- Realtime slot, lokasi, assignment penjaga, notifikasi.
- Push notification via FCM (`send-push-notification` Edge Function).
- Laporan keuangan penyedia, statistik, laporan gaji penjaga.
- Laporan global super admin.
- User management super admin (aktif/nonaktif/hapus).
- App version check via Supabase di SplashScreen.
- Onboarding tersimpan lokal (SharedPreferences).
- Geocoding real-time via Nominatim OSM (untuk form lokasi penyedia).

### Belum Production / Perlu Audit Lanjut

- Export PDF/Excel laporan penyedia dan super admin (perlu audit menghasilkan file unduhan nyata).
- Filter periode, metode pembayaran, dan pencarian transaksi pada laporan lanjutan.
- Audit iOS bila aplikasi akan dirilis ke App Store.
- Monitoring production setelah rilis Play Store.
- Kebijakan privasi publik dan isian Data Safety Google Play.
- ETA berbasis rute (saat ini masih estimasi garis lurus).

---

## 6. User Flow Utama

### 6.1 Flow Customer

1. Buka aplikasi → splash screen → cek versi minimum.
2. Onboarding (sekali saja, tersimpan di perangkat).
3. Login/register (email-password atau Google OAuth).
4. Session dipulihkan dari Supabase bila masih valid → langsung ke dashboard.
5. Dashboard memuat lokasi, slot, booking aktif, ETA berbasis GPS.
6. Pilih lokasi → lihat detail, foto, tarif, slot tersedia.
7. Pilih kendaraan, slot, waktu masuk → booking via RPC server-side.
8. Bayar via Midtrans Snap atau pilih tunai ke penjaga.
9. Callback `parkircepat://payment-finish` → tiket QR aktif.
10. Penjaga scan QR → verifikasi masuk → kendaraan masuk tercatat.
11. Penjaga konfirmasi keluar (dan tunai bila belum bayar).
12. Customer lihat riwayat, receipt, beri review, kirim komplain/chat.

### 6.2 Flow Penyedia

1. Register dengan data lahan, foto, dan dokumen identitas.
2. Tunggu verifikasi super admin.
3. Notifikasi verifikasi diterima → login → masuk dashboard.
4. Tambah lokasi parkir: isi nama, alamat → peta geocoding otomatis mengarahkan marker ke koordinat alamat.
5. Tambah slot parkir dan atur tarif.
6. Buat akun penjaga via Edge Function.
7. Pantau kendaraan masuk, pendapatan, dan laporan dari Supabase.

### 6.3 Flow Penjaga

1. Terima akun dari penyedia → login.
2. Dashboard memuat lokasi assignment dari Supabase.
3. Scan QR tiket customer → RPC validasi token → kendaraan masuk.
4. Konfirmasi kendaraan keluar → update slot → RPC.
5. Konfirmasi pembayaran tunai → RPC `app_operator_confirm_cash_payment`.
6. Lihat kendaraan aktif dan estimasi laporan gaji.

### 6.4 Flow Super Admin

1. Login khusus super admin.
2. Dashboard menampilkan agregasi Supabase seluruh sistem.
3. Verifikasi penyedia dari daftar pengajuan pending.
4. Tangani komplain dari customer/penyedia.
5. Kelola user: aktif/nonaktif/hapus akun Auth.
6. Lihat laporan global dan statistik revenue 7 hari.

---

## 7. Kebutuhan Fungsional

### Customer
- Sistem menyimpan akun customer di Supabase Auth dan `profiles`.
- Sistem mendukung login email-password dan Google OAuth.
- Sistem memulihkan session yang valid saat aplikasi dibuka ulang.
- Sistem menyimpan kendaraan, booking, payment, dan receipt ke Supabase.
- Sistem menampilkan lokasi dan slot dari Supabase.
- Tarif parkir dihitung server-side via RPC berdasarkan lahan, kendaraan, tipe tarif, dan durasi.
- Tiket QR menggunakan token opaque `qr_payload`.
- Booking expired diproses server-side; slot dilepas otomatis.
- Laporan/riwayat customer dibatasi ke transaksi milik akun yang login.

### Penyedia
- Sistem menyimpan akun dan status verifikasi penyedia.
- Penyedia belum disetujui tidak bisa masuk dashboard utama.
- Sistem menyimpan lokasi parkir, slot, foto, dan dokumen identitas ke Supabase.
- Sistem membuat akun penjaga via Edge Function dengan validasi server.
- Sistem menghitung laporan dari transaksi lokasi milik penyedia.
- Estimasi gaji penjaga dihitung 15% revenue lokasi yang memiliki assignment.
- Geocoding real-time mengarahkan marker peta ke koordinat alamat yang diketik.

### Penjaga
- Sistem mengizinkan penjaga login dengan akun dari penyedia.
- Sistem membatasi data penjaga berdasarkan lokasi assignment.
- Scan dan konfirmasi masuk/keluar menggunakan RPC atomik dengan validasi server.
- Konfirmasi tunai menggunakan RPC khusus dengan validasi izin.
- Laporan gaji dihitung dari revenue lokasi assignment.

### Super Admin
- Sistem mengizinkan super admin login dan mengakses semua data.
- Sistem memverifikasi penyedia dari `provider_applications`.
- Sistem menampilkan komplain dari semua role.
- Sistem mengelola status user dan menghapus akun Auth via Edge Function.
- Sistem menampilkan laporan global dari seluruh transaksi Supabase.

---

## 8. Kebutuhan Non-Fungsional

- Aplikasi berjalan di Android; rilis iOS menyusul setelah audit Xcode.
- UI ringan, bersih, modern, mudah dipahami oleh semua role.
- Integrasi Supabase dibuat bertahap, aman, dan mudah di-rollback.
- RLS diterapkan di seluruh tabel utama; akses role diperketat sebelum production.
- Tarif dan nominal transaksi selalu dihitung server-side, tidak dapat dimanipulasi client.
- Error koneksi Supabase ditangani dengan pesan yang jelas; laporan menampilkan empty/error state.
- Nominal laporan konsisten menggunakan `final_cost` bila tersedia, fallback `estimated_cost`.
- Aplikasi dapat didemonstrasikan dari laptop via Chrome/emulator.
- Alur mobile-only (Google callback, push notification, scan QR, payment callback) diuji di emulator/perangkat Android asli.
- Data seed/demo tidak muncul di build release (dibatasi via flag `isUsingDemoData`).
- Fitur production wajib lolos `flutter analyze` dan `flutter test`.

---

## 9. Desain dan Brand Direction

- Mobile-first, light mode.
- Tampilan bersih, modern, dan profesional.
- Warna utama: putih, hijau emerald, biru, abu muda, dengan aksen status yang jelas.
- Navigasi sederhana; setiap role memiliki shell navigasi sendiri.
- Dashboard tiap role padat informasi tapi mudah dipindai.
- UI operasional penyedia/penjaga/super admin fokus pada aksi cepat.
- Komponen map menggunakan flutter_map + OpenStreetMap tile.
- Geocoding menggunakan Nominatim OSM API.

---

## 10. Riwayat Versi dan Roadmap

### Selesai — Versi 1.0.1+2 (sebelumnya)

- Supabase core: auth, profil, role, lokasi, slot, booking, kendaraan, riwayat, chat, komplain, notifikasi, review, laporan utama.
- Reset password dari email sampai halaman set password baru.
- Restore session login sampai user logout.
- Google login customer dengan callback Supabase OAuth dan fallback PKCE.
- Midtrans payment flow, webhook, dan callback kembali ke aplikasi.
- Booking expiry server-side via `pg_cron`.
- QR tiket opaque token.
- RPC atomik scan masuk/keluar dan konfirmasi tunai penjaga.
- Push notification via FCM dan Edge Function.
- Realtime slot, lokasi, assignment, notifikasi.
- Laporan penyedia, statistik, laporan gaji penjaga.
- Receipt PDF.
- User management super admin.
- Hapus akun via Edge Function.
- App version check di SplashScreen.
- Build release Android (APK dan AAB) berhasil.
- Audit perangkat Android asli: deep link, payment callback, scan QR, push notification.

### Selesai — Versi 1.0.2+3 (saat ini)

- Penyempurnaan geocoding map real-time: marker dan kamera peta berpindah ke koordinat alamat yang diketik pengguna menggunakan `addPostFrameCallback` agar `MapController` siap sebelum `move()` dipanggil.
- Perbaikan bug referensi `widget.title` di `MapEmbedView`.
- Build release Android AAB 45.8 MB siap diupload ke Play Console.

### Prioritas Sebelum Publikasi Play Store

- Lengkapi URL Kebijakan Privasi publik.
- Selesaikan isian Data Safety Google Play.
- Upload AAB release ke Play Console.
- Uji internal testing dari Play Store pada perangkat asli.
- Pastikan konfigurasi Midtrans production, Supabase production, dan FCM secret final.

### Prioritas Setelah Rilis

- Monitoring transaksi, webhook Midtrans, dan error produksi.
- Finalisasi export PDF/Excel laporan penyedia dan super admin.
- Filter periode, lokasi, metode pembayaran, pencarian transaksi pada laporan.
- Audit akurasi laporan terhadap data Midtrans, booking tunai, final cost, dan status booking.
- Integration test multi-role/multi-device.
- Audit iOS untuk rilis App Store.
- Pertimbangkan Map SDK/routing production untuk ETA berbasis rute (bukan garis lurus).

---

## 11. Kriteria Sukses

- Customer dapat register, login, tambah kendaraan, booking, membayar (Midtrans/tunai), lihat QR, riwayat, favorit, review, chat, komplain, dan notifikasi.
- Customer login Google kembali ke dashboard melalui callback Supabase.
- Customer yang sudah login tetap masuk dashboard saat aplikasi dibuka ulang.
- Customer melihat receipt dan riwayat transaksi pribadi sesuai akun login.
- Penyedia dapat register, diverifikasi, login, tambah lokasi, kelola slot, buat akun penjaga, pantau kendaraan, dan baca laporan pendapatan.
- Penyedia mengetik alamat lahan → peta dan marker berpindah otomatis ke koordinat alamat tersebut.
- Penjaga dapat login, lihat lokasi tugas, scan QR, update masuk/keluar, konfirmasi tunai, dan lihat estimasi gaji.
- Super admin dapat login, verifikasi penyedia, tangani komplain, kelola user, dan lihat laporan global.
- Semua tarif dan nominal transaksi dihitung server-side; tidak dapat dimanipulasi client.
- Booking expired diproses otomatis server-side dalam 30 menit.
- Data production tidak tercampur data seed/demo di build release.
- Total laporan konsisten dengan transaksi Supabase, status booking, dan payment production.
- Aplikasi dapat dipresentasikan dari laptop menggunakan panduan demo.
- Build rilis Android menghasilkan AAB yang siap diuji di Play Console.
- `flutter analyze` dan `flutter test` lulus sebelum merge.

---

## 12. Teknikal Stack

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Routing | go_router |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime) |
| Payment | Midtrans Snap |
| Push Notification | Firebase Cloud Messaging (FCM) |
| Map | flutter_map + OpenStreetMap tile |
| Geocoding | Nominatim OpenStreetMap API |
| PDF | pdf + printing |
| QR | qr_flutter + mobile_scanner |
| Deep Link | app_links (scheme `parkircepat://`) |
| Local Storage | SharedPreferences |
| HTTP | http (Dart) |
| Fonts | Google Fonts |

---

## 13. Dokumen Pendukung

- Pembagian role: `docs/ROLE_SYSTEM_PRD.md`
- Tasklist role: `docs/ROLE_SYSTEM_TASKLIST.md`
- Pembagian branch tim: `docs/TEAM_BRANCHES.md`
- Status tasklist tim (272 item): `docs/TEAM_TASKLIST_STATUS.md`
- Panduan demo laptop: `docs/DEMO_PRESENTATION_GUIDE.md`
- Schema Supabase: `docs/supabase_schema.sql`
- SQL tambahan Supabase: `docs/supabase_schema_additions.sql`
- Checklist deploy eksternal: `docs/production_external_deploy_checklist.md`
- Audit E2E alur utama: `docs/e2e_main_flow_audit_2026-06-25.md`
- Audit deep link perangkat: `docs/deep_link_device_audit_2026-06-29.md`
- Audit Midtrans: `docs/midtrans_audit_2026-06-25.md`
- Runbook expiry & scan production: `docs/production_midtrans_expiry_scan_runbook.md`
- Status sinkron RLS: `docs/RLS_AUDIT_STATUS.md`
- Status sinkron role: `docs/ROLE_SYNC_STATUS.md`
