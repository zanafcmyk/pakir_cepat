# Tasklist Status dan Pembagian Tim

Dokumen ini dipakai sebagai acuan kerja tim Parkir Cepat. Tujuannya supaya fitur yang sudah berjalan tidak dikerjakan ulang, fitur demo terlihat jelas, dan fitur yang belum production bisa dicicil dengan aman.

## Cara Pakai

- Kerjakan satu fitur kecil dalam satu waktu.
- Jangan mengerjakan banyak item sekaligus.
- Sebelum coding, pastikan branch dan scope tidak bentrok dengan anggota lain.
- Setelah satu fitur selesai, jalankan `flutter analyze` dan `flutter test` bila ada perubahan kode.
- Buat commit kecil setelah fitur terbukti jalan.
- Jika ada kerusakan, kembali ke commit aman sebelum perubahan tersebut.

## Status Umum

### Sudah Berjalan dan Terhubung Supabase

- [x] Login dan registrasi customer.
- [x] Login dan registrasi penyedia.
- [x] Login super admin.
- [x] Login penjaga dari akun yang dibuat penyedia.
- [x] Approval/verifikasi penyedia oleh super admin.
- [x] Data lokasi parkir dan slot penyedia ke Supabase.
- [x] Membaca lokasi parkir dan slot dari Supabase ke aplikasi.
- [x] Kendaraan customer ke Supabase.
- [x] Booking parkir ke Supabase.
- [x] Payment demo tersimpan ke Supabase.
- [x] Load booking aktif customer dari Supabase.
- [x] Scan QR membaca booking dari Supabase.
- [x] Update masuk/keluar kendaraan ke Supabase.
- [x] Riwayat transaksi/customer history dari Supabase.
- [x] Komplain ke Supabase.
- [x] Chat membaca pesan lama dari Supabase.
- [x] Chat realtime dari Supabase.
- [x] Notifikasi in-app/table ke Supabase.
- [x] Akun penjaga ke Supabase.
- [x] Favorit lokasi parkir customer ke Supabase.
- [x] Review/rating parkir ke Supabase.
- [x] Edit profil customer ke Supabase.
- [x] Edit profil penyedia ke Supabase.
- [x] Edit profil penjaga ke Supabase.
- [x] Upload foto avatar/profil ke Supabase Storage.
- [x] Load avatar dari `profiles.avatar_url` saat login berikutnya.

### Sudah Ada Tapi Masih Demo/Lokal/Belum Production

- [ ] Onboarding masih lokal/demo.
- [ ] UI dashboard customer sudah ada, tetapi sebagian data masih perlu dicek integrasi Supabase.
- [ ] UI dashboard penyedia sudah ada, tetapi sebagian data statistik/laporan masih belum query Supabase penuh.
- [ ] UI dashboard penjaga sudah ada, tetapi perlu diperketat dengan role guard dan data assignment.
- [ ] UI dashboard super admin sudah ada, tetapi sebagian aksi user management belum tersimpan penuh ke Supabase.
- [ ] Statistik penyedia sebagian masih pakai data lokal/state.
- [ ] Statistik super admin sebagian masih pakai data lokal/state.
- [ ] Laporan penyedia sebagian masih pakai data lokal/history state.
- [ ] Laporan super admin sebagian masih pakai data lokal/history state.
- [ ] Monitoring kendaraan penyedia sebagian masih membaca history lokal/state.
- [ ] Pengaturan akun customer masih lokal.
- [ ] Forgot password masih simulasi UI/OTP, belum reset password Supabase sungguhan.
- [ ] Delete account masih reset state lokal, belum hapus akun Supabase sungguhan.
- [ ] Payment masih demo, belum gateway pembayaran asli.
- [ ] Nota/receipt sudah membaca Supabase jika ada, tetapi print/export masih UI/demo.
- [ ] Edit foto lahan masih memakai picker lokal, belum upload foto lahan ke Supabase Storage.
- [ ] Provider financial report belum sepenuhnya query agregasi Supabase.
- [ ] Provider daily revenue belum sepenuhnya query agregasi Supabase.
- [ ] Provider statistics belum sepenuhnya query agregasi Supabase.
- [ ] Notifikasi in-app sudah ada, tetapi push notification asli ke HP belum production.

### Belum Ada atau Belum Production

- [ ] Penyedia membuat akun penjaga langsung lewat sistem aman menggunakan Edge Function.
- [ ] Edit profil super admin ke Supabase.
- [ ] Ganti password Supabase.
- [ ] Reset password Supabase sungguhan.
- [ ] Hapus akun sungguhan di Supabase.
- [ ] Settings customer ke tabel `customer_settings`.
- [ ] Settings penyedia.
- [ ] Settings penjaga.
- [ ] Upload foto lahan parkir ke Supabase Storage.
- [ ] Upload dokumen identitas penyedia ke Supabase Storage.
- [ ] Search/filter lokasi sungguhan dari database.
- [ ] Laporan pendapatan dari query Supabase.
- [ ] Statistik dari query Supabase.
- [ ] Push notification asli ke HP.
- [ ] Role guard/route protection yang ketat.
- [ ] Middleware/auth protection penuh.
- [ ] Realtime slot.
- [ ] Realtime lokasi.
- [ ] Realtime notifikasi.
- [ ] Admin user management ke Supabase.
- [ ] Super admin user management ke Supabase.

## Pembagian Tim

### zanafcmyk - Owner, Super Admin, Review, Integrasi

#### Sudah Berjalan

- [x] Super admin bisa login.
- [x] Super admin bisa memverifikasi penyedia.
- [x] Komplain tersimpan ke Supabase.
- [x] Notifikasi in-app/table tersimpan ke Supabase.
- [x] Review/rating parkir tersimpan ke Supabase.
- [x] Avatar/profil bisa upload dan load dari Supabase.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Dashboard super admin sebagian masih memakai data lokal/state.
- [ ] Statistik super admin belum sepenuhnya dari query Supabase.
- [ ] Laporan super admin belum sepenuhnya dari query Supabase.
- [ ] Admin/super admin user management belum semua aksi tersimpan ke Supabase.

#### Belum Ada/Belum Production

- [ ] Edit profil super admin ke Supabase.
- [ ] User management super admin ke Supabase.
- [ ] Role guard dan route protection ketat.
- [ ] Middleware/auth protection penuh.
- [ ] Push notification asli ke HP.
- [ ] Review final sebelum merge ke `development` atau `master`.

### maulana-bintang - Penyedia Parkir

#### Sudah Berjalan

- [x] Login dan registrasi penyedia ke Supabase.
- [x] Penyedia menunggu verifikasi super admin sebelum aktif.
- [x] Penyedia bisa menambah lokasi parkir dan slot ke Supabase.
- [x] Penyedia bisa membaca lokasi parkir dan slot dari Supabase.
- [x] Penyedia bisa membuat/mengelola akun penjaga yang tersimpan ke Supabase.
- [x] Edit profil penyedia ke Supabase.
- [x] Avatar penyedia upload dan load dari Supabase.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Dashboard penyedia sebagian masih perlu dicek integrasi datanya.
- [ ] Monitoring kendaraan penyedia sebagian masih membaca history lokal/state.
- [ ] Statistik penyedia sebagian masih pakai data lokal/state.
- [ ] Laporan penyedia sebagian masih pakai data lokal/history state.
- [ ] Provider financial report belum sepenuhnya query agregasi Supabase.
- [ ] Provider daily revenue belum sepenuhnya query agregasi Supabase.
- [ ] Provider statistics belum sepenuhnya query agregasi Supabase.
- [ ] Edit foto lahan masih picker lokal.

#### Belum Ada/Belum Production

- [ ] Upload foto lahan parkir ke Supabase Storage.
- [ ] Upload dokumen identitas penyedia ke Supabase Storage.
- [ ] Settings penyedia.
- [ ] Search/filter data lokasi dari database.
- [ ] Query laporan pendapatan penyedia dari Supabase.
- [ ] Query statistik penyedia dari Supabase.
- [ ] Edge Function untuk membuat akun penjaga secara aman.

### ethunder243-droid - Penjaga Parkir

#### Sudah Berjalan

- [x] Login penjaga dari akun yang dibuat penyedia.
- [x] Penjaga membaca data lokasi yang ditugaskan.
- [x] Scan QR membaca booking dari Supabase.
- [x] Update masuk kendaraan ke Supabase.
- [x] Update keluar kendaraan ke Supabase.
- [x] Edit profil penjaga ke Supabase.
- [x] Avatar penjaga upload dan load dari Supabase.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Dashboard penjaga sudah ada, tetapi perlu dicek lagi data yang masih lokal.
- [ ] Monitoring kendaraan penjaga perlu dipastikan selalu dari assignment Supabase.
- [ ] Pembayaran tunai/manual masih bagian dari flow demo.

#### Belum Ada/Belum Production

- [ ] Settings penjaga.
- [ ] Role guard khusus penjaga agar tidak bisa membuka halaman role lain.
- [ ] Realtime status slot/lokasi untuk penjaga.
- [ ] Push notification tugas/booking untuk penjaga.

### Customer Flow - Pelanggan Bersama

#### Sudah Berjalan

- [x] Login dan registrasi customer ke Supabase.
- [x] Customer membaca lokasi parkir dan slot dari Supabase.
- [x] Kendaraan customer tersimpan ke Supabase.
- [x] Booking parkir tersimpan ke Supabase.
- [x] Booking aktif customer dibaca dari Supabase.
- [x] Riwayat transaksi/customer history dibaca dari Supabase.
- [x] Favorit lokasi parkir customer tersimpan ke Supabase.
- [x] Review/rating parkir tersimpan ke Supabase.
- [x] Komplain customer tersimpan ke Supabase.
- [x] Chat customer membaca pesan lama dan realtime dari Supabase.
- [x] Edit profil customer ke Supabase.
- [x] Avatar customer upload dan load dari Supabase.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Onboarding masih lokal/demo.
- [ ] Dashboard customer sebagian perlu dicek integrasi datanya.
- [ ] Pengaturan akun customer masih lokal.
- [ ] Forgot password masih simulasi UI/OTP.
- [ ] Delete account masih reset state lokal.
- [ ] Payment masih demo.
- [ ] Nota/receipt print/export masih UI/demo.

#### Belum Ada/Belum Production

- [ ] Settings customer ke tabel `customer_settings`.
- [ ] Ganti password Supabase.
- [ ] Reset password Supabase sungguhan.
- [ ] Hapus akun sungguhan di Supabase.
- [ ] Search/filter lokasi sungguhan dari database.
- [ ] Push notification booking/payment ke HP.

### Backend/Supabase Bersama

#### Sudah Berjalan

- [x] Schema utama Supabase sudah dibuat.
- [x] Chat Supabase termasuk realtime sudah berjalan.
- [x] Notifikasi in-app/table sudah berjalan.
- [x] Storage avatar sudah dipakai untuk upload foto profil.
- [x] Trigger rating/review sudah disiapkan di dokumen SQL.
- [x] Trigger notifikasi otomatis sudah disiapkan di dokumen SQL.

#### Sudah Ada Tapi Perlu Diperkuat

- [ ] Policy RLS perlu dicek ulang per role sebelum production.
- [ ] SQL trigger perlu dipastikan sudah dijalankan di Supabase production.
- [ ] Data demo/lokal perlu dipisah dari data production.
- [ ] Error handling koneksi Supabase perlu dibuat lebih konsisten.

#### Belum Ada/Belum Production

- [ ] Edge Function untuk membuat akun penjaga.
- [ ] Edge Function/admin flow untuk hapus akun sungguhan.
- [ ] Storage bucket foto lahan.
- [ ] Storage bucket dokumen identitas penyedia.
- [ ] Query agregasi laporan/statistik.
- [ ] Realtime slot/lokasi/notifikasi penuh.
- [ ] Push notification provider production.

## Prioritas Aman Berikutnya

1. Settings customer ke Supabase.
2. Edit profil super admin ke Supabase.
3. Ganti password dan reset password Supabase.
4. Upload foto lahan ke Supabase Storage.
5. Search/filter lokasi dari Supabase.
6. Laporan pendapatan dan statistik dari query Supabase.
7. Edge Function untuk membuat akun penjaga.
8. Route protection dan middleware auth.
9. Realtime slot/lokasi/notifikasi.
10. Delete account sungguhan.
