# Product Requirements Document - Parkir Cepat

## 1. Ringkasan Produk

Parkir Cepat adalah aplikasi mobile smart parking berbasis Flutter untuk mempertemukan customer, penyedia lahan parkir, penjaga parkir, dan super admin dalam satu sistem. Aplikasi membantu customer mencari lokasi parkir, menyimpan kendaraan, melakukan booking, membayar parkir, memakai tiket QR, memberi review, mengirim komplain, dan menerima notifikasi.

Di sisi operasional, penyedia dapat mengelola lokasi parkir, slot, penjaga, profil, dan data transaksi. Penjaga dapat login menggunakan akun yang dibuat penyedia, melakukan scan QR, serta memperbarui status kendaraan masuk dan keluar. Super admin bertugas memantau sistem, memverifikasi penyedia, mengelola komplain, dan melihat data lintas role.

Versi saat ini bukan lagi prototype lokal penuh. Sebagian besar alur utama sudah mulai terhubung ke Supabase, sementara beberapa fitur masih demo/lokal dan perlu diselesaikan bertahap sebelum production.

## 2. Tujuan Produk

### Tujuan Customer

- Menemukan lokasi parkir dengan cepat.
- Melihat ketersediaan slot sebelum datang.
- Menyimpan kendaraan pribadi.
- Melakukan booking parkir.
- Menerima tiket QR digital.
- Melihat riwayat transaksi dan parkir.
- Mengirim komplain dan chat dengan role terkait.
- Memberi rating dan review lokasi parkir.

### Tujuan Penyedia Parkir

- Mendaftarkan dan mengelola lokasi parkir.
- Mengelola slot parkir.
- Melihat kendaraan, booking, dan transaksi.
- Membuat dan mengelola akun penjaga.
- Melihat laporan pendapatan dan statistik operasional.
- Mengelola profil penyedia.

### Tujuan Penjaga Parkir

- Login memakai akun yang dibuat penyedia.
- Melihat lokasi yang ditugaskan.
- Scan QR booking customer.
- Memverifikasi kendaraan masuk.
- Memverifikasi kendaraan keluar.
- Melihat kendaraan aktif dan status pembayaran.

### Tujuan Super Admin

- Memverifikasi penyedia.
- Memantau aktivitas lintas role.
- Menangani komplain.
- Mengelola user management.
- Melihat laporan dan statistik global.
- Menjaga keamanan akses aplikasi.

## 3. Role Pengguna

### 3.1 Customer

Pengguna akhir yang mencari dan memakai layanan parkir.

Kebutuhan utama:

- Register dan login.
- Tambah kendaraan.
- Cari lokasi parkir.
- Booking parkir.
- Bayar parkir.
- Pakai tiket QR.
- Melihat riwayat.
- Chat, komplain, notifikasi, favorit, dan review.

### 3.2 Penyedia Parkir

Pemilik atau pengelola lokasi parkir.

Kebutuhan utama:

- Register dan menunggu verifikasi super admin.
- Login setelah disetujui.
- Tambah lokasi parkir.
- Kelola slot.
- Buat akun penjaga.
- Melihat laporan, transaksi, dan monitoring kendaraan.
- Edit profil dan avatar.

### 3.3 Penjaga Parkir

Petugas operasional di lokasi parkir.

Kebutuhan utama:

- Login memakai akun dari penyedia.
- Melihat lokasi yang ditugaskan.
- Scan QR customer.
- Update status masuk/keluar kendaraan.
- Melihat kendaraan aktif.
- Edit profil dan avatar.

### 3.4 Super Admin

Admin pusat aplikasi.

Kebutuhan utama:

- Login khusus super admin.
- Verifikasi penyedia.
- Memantau semua role.
- Menangani komplain.
- Mengelola user dan data production.
- Melihat laporan global.

## 4. Scope Fitur

### 4.1 Autentikasi dan Akun

- Splash screen.
- Onboarding.
- Login customer.
- Register customer.
- Login penyedia.
- Register penyedia.
- Verifikasi penyedia oleh super admin.
- Login penjaga.
- Login super admin.
- Edit profil customer.
- Edit profil penyedia.
- Edit profil penjaga.
- Upload avatar/profil ke Supabase Storage.
- Load avatar dari Supabase saat login.

Belum production:

- Forgot password Supabase sungguhan.
- Ganti password Supabase.
- Delete account sungguhan.
- Edit profil super admin ke Supabase.
- Route protection dan middleware auth ketat.

### 4.2 Customer

- Dashboard customer.
- Daftar lokasi parkir.
- Detail lokasi parkir.
- Tambah kendaraan.
- Booking parkir.
- Tiket QR.
- Payment demo.
- Riwayat transaksi.
- Favorit lokasi parkir.
- Review/rating lokasi parkir.
- Komplain.
- Chat.
- Notifikasi in-app.
- Profil customer.
- Settings customer.

Belum production:

- Payment gateway asli.
- Search/filter lokasi dari query database penuh.
- Push notification asli ke HP.
- Receipt print/export sungguhan.

### 4.3 Penyedia

- Dashboard penyedia.
- Tambah lokasi parkir.
- Kelola slot.
- Membaca lokasi dan slot dari Supabase.
- Monitoring kendaraan.
- Membuat akun penjaga.
- Mengelola akun penjaga.
- Melihat notifikasi.
- Profil penyedia.

Belum production:

- Upload foto lahan ke Supabase Storage.
- Upload dokumen identitas penyedia.
- Statistik penyedia dari query agregasi Supabase.
- Laporan pendapatan penyedia dari Supabase.
- Daily revenue dari query Supabase.
- Settings penyedia.
- Edge Function untuk membuat akun penjaga secara aman.

### 4.4 Penjaga

- Dashboard penjaga.
- Melihat lokasi yang ditugaskan.
- Scan QR booking.
- Update kendaraan masuk.
- Update kendaraan keluar.
- Melihat kendaraan aktif.
- Komplain/chat/notifikasi.
- Profil penjaga.

Belum production:

- Settings penjaga.
- Role guard khusus agar penjaga tidak bisa membuka halaman role lain.
- Realtime status slot/lokasi penuh.
- Push notification tugas.

### 4.5 Super Admin

- Dashboard super admin.
- Login super admin.
- Verifikasi penyedia.
- Melihat komplain.
- Mengelola status komplain.
- Melihat notifikasi.
- Melihat data lintas role.

Belum production:

- Edit profil super admin.
- User management penuh ke Supabase.
- Statistik global dari query Supabase.
- Laporan global dari query Supabase.
- Route protection ketat.

## 5. Integrasi Supabase Saat Ini

### Sudah Terhubung

- Auth untuk customer, penyedia, penjaga, dan super admin.
- Tabel profil/role dasar.
- Lokasi parkir.
- Slot parkir.
- Kendaraan customer.
- Booking parkir.
- Payment demo.
- Booking aktif customer.
- Riwayat transaksi/customer history.
- Scan QR membaca booking.
- Update status masuk/keluar.
- Komplain.
- Chat pesan lama.
- Chat realtime.
- Notifikasi in-app/table.
- Akun penjaga.
- Favorit lokasi parkir.
- Review/rating.
- Edit profil customer.
- Edit profil penyedia.
- Edit profil penjaga.
- Settings customer.
- Upload avatar ke Supabase Storage.
- Load avatar saat login.

### Masih Demo/Lokal/Belum Production

- Onboarding.
- Beberapa data dashboard tiap role.
- Statistik dan laporan.
- Monitoring kendaraan penyedia sebagian.
- Settings penyedia/penjaga.
- Forgot password.
- Delete account.
- Payment gateway.
- Receipt print/export.
- Foto lahan parkir.
- Dokumen identitas penyedia.
- Search/filter database penuh.
- Push notification asli.
- Realtime slot/lokasi/notifikasi penuh.
- User management super admin penuh.

## 6. User Flow Utama

### 6.1 Flow Customer

1. Customer membuka aplikasi.
2. Customer login atau register.
3. Aplikasi membaca data profil, avatar, kendaraan, booking aktif, riwayat, favorit, notifikasi, lokasi, dan slot dari Supabase.
4. Customer memilih lokasi parkir.
5. Customer memilih kendaraan dan membuat booking.
6. Booking tersimpan ke Supabase.
7. Customer melakukan payment demo.
8. Tiket QR aktif.
9. Penjaga melakukan scan QR.
10. Status masuk/keluar diperbarui ke Supabase.
11. Customer melihat riwayat, receipt, notifikasi, review, dan komplain.

### 6.2 Flow Penyedia

1. Penyedia register.
2. Penyedia menunggu verifikasi super admin.
3. Setelah disetujui, penyedia login.
4. Penyedia membuat lokasi parkir dan slot.
5. Data lokasi dan slot tersimpan ke Supabase.
6. Penyedia membuat akun penjaga.
7. Penjaga memakai akun tersebut untuk login.
8. Penyedia memantau kendaraan, slot, dan transaksi.

### 6.3 Flow Penjaga

1. Penjaga menerima akun dari penyedia.
2. Penjaga login.
3. Aplikasi membaca data lokasi yang ditugaskan.
4. Penjaga scan QR customer.
5. Sistem membaca booking dari Supabase.
6. Penjaga mengonfirmasi kendaraan masuk.
7. Penjaga mengonfirmasi kendaraan keluar.
8. Status booking, slot, dan riwayat diperbarui.

### 6.4 Flow Super Admin

1. Super admin login.
2. Super admin melihat dashboard.
3. Super admin memverifikasi penyedia.
4. Super admin menangani komplain.
5. Super admin memantau data lintas role.
6. Super admin mengelola user dan laporan setelah fitur production selesai.

## 7. Kebutuhan Fungsional

### Customer

- Sistem harus menyimpan akun customer di Supabase.
- Sistem harus menyimpan kendaraan customer di Supabase.
- Sistem harus menampilkan lokasi dan slot dari Supabase.
- Sistem harus membuat booking ke Supabase.
- Sistem harus membuat tiket QR dari booking aktif.
- Sistem harus menyimpan payment demo dan receipt ke Supabase.
- Sistem harus membaca riwayat transaksi dari Supabase.
- Sistem harus menyimpan favorit, review, chat, komplain, dan notifikasi.

### Penyedia

- Sistem harus menyimpan akun penyedia dan status verifikasi.
- Sistem harus mencegah penyedia belum disetujui masuk dashboard utama.
- Sistem harus menyimpan lokasi parkir dan slot.
- Sistem harus menampilkan lokasi milik penyedia.
- Sistem harus membuat akun penjaga.
- Sistem harus menyimpan profil dan avatar penyedia.

### Penjaga

- Sistem harus mengizinkan penjaga login memakai akun dari penyedia.
- Sistem harus membatasi data penjaga berdasarkan lokasi yang ditugaskan.
- Sistem harus membaca booking dari QR.
- Sistem harus update status masuk/keluar ke Supabase.
- Sistem harus menyimpan profil dan avatar penjaga.

### Super Admin

- Sistem harus mengizinkan super admin login.
- Sistem harus mengizinkan super admin memverifikasi penyedia.
- Sistem harus menampilkan komplain.
- Sistem harus memperbarui status komplain.
- Sistem harus disiapkan untuk user management production.

## 8. Kebutuhan Non-Fungsional

- Aplikasi harus berjalan di Android dan iOS.
- UI harus ringan, jelas, dan mudah dipahami.
- Integrasi Supabase harus dibuat bertahap dan aman.
- Perubahan fitur harus kecil, mudah dites, dan mudah di-rollback.
- Data role harus dipisahkan dengan jelas.
- Akses role harus diperketat sebelum production.
- Error koneksi Supabase harus ditangani dengan pesan yang jelas.
- Fitur production wajib lolos `flutter analyze` dan `flutter test`.

## 9. Desain dan Brand Direction

- Mobile-first.
- Light mode.
- Tampilan bersih, modern, dan profesional.
- Warna utama putih, hijau, biru, abu muda, dan aksen status yang jelas.
- Navigasi sederhana.
- Dashboard tiap role harus padat informasi tetapi tetap mudah dipindai.
- UI operasional penyedia/penjaga/super admin harus fokus pada aksi cepat, bukan tampilan marketing.

## 10. Prioritas Roadmap

### Fase 1 - Stabilkan Supabase Core

- Edit profil super admin ke Supabase.
- Ganti password dan reset password Supabase.
- Search/filter lokasi dari Supabase.
- Upload foto lahan ke Storage.

### Fase 2 - Operasional Penyedia dan Penjaga

- Query laporan pendapatan penyedia.
- Query statistik penyedia.
- Realtime slot/lokasi.
- Edge Function untuk membuat akun penjaga secara aman.
- Role guard penjaga.

### Fase 3 - Super Admin dan Production Hardening

- User management super admin.
- Statistik global.
- Laporan global.
- Route protection dan middleware auth penuh.
- RLS review per role.
- Delete account sungguhan.

### Fase 4 - Production Services

- Payment gateway asli.
- Push notification asli ke HP.
- Receipt print/export.
- Upload dokumen identitas penyedia.
- Map SDK production.

## 11. Kriteria Sukses

- Customer dapat register, login, tambah kendaraan, booking, bayar demo, melihat QR, riwayat, favorit, review, chat, komplain, dan notifikasi.
- Penyedia dapat register, diverifikasi, login, membuat lokasi, mengelola slot, membuat akun penjaga, dan melihat data operasional.
- Penjaga dapat login, melihat lokasi tugas, scan QR, dan update masuk/keluar.
- Super admin dapat login, memverifikasi penyedia, dan menangani komplain.
- Data utama tersimpan di Supabase.
- Fitur demo diberi batas jelas dan tidak dianggap production.
- Aplikasi lolos `flutter analyze` dan `flutter test` sebelum merge.

## 12. Dokumen Pendukung

- Pembagian role: `docs/ROLE_SYSTEM_PRD.md`
- Tasklist role: `docs/ROLE_SYSTEM_TASKLIST.md`
- Pembagian branch tim: `docs/TEAM_BRANCHES.md`
- Status tasklist tim: `docs/TEAM_TASKLIST_STATUS.md`
- Schema Supabase: `docs/supabase_schema.sql`
- SQL tambahan Supabase: `docs/supabase_schema_additions.sql`
