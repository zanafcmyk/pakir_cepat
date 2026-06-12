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
- [x] Pengaturan akun customer ke Supabase.
- [x] Forgot password mengirim link reset lewat Supabase.
- [x] Upload foto lahan parkir penyedia ke Supabase Storage.
- [x] Onboarding tersimpan lokal permanen di device dengan `SharedPreferences`.
- [x] Dashboard customer memuat ulang data utama dari Supabase saat dibuka.
- [x] Dashboard penyedia membaca kendaraan masuk dan pendapatan hari ini dari Supabase.
- [x] Provider daily revenue detail membaca transaksi hari ini dari Supabase.
- [x] Provider financial report membaca agregasi transaksi bulan ini dari Supabase.
- [x] Provider statistics dan grafik revenue membaca agregasi Supabase.
- [x] Monitoring kendaraan penyedia membaca transaksi dari Supabase saat halaman dibuka.
- [x] Dashboard penjaga memuat assignment dan lokasi tugas dari Supabase saat dibuka.
- [x] Dashboard super admin membaca ringkasan pengguna, komplain, lokasi, booking aktif, dan revenue dari Supabase.
- [x] Statistik dan laporan super admin membaca transaksi serta grafik 7 hari dari Supabase.
- [x] User management super admin memuat profil dari Supabase dan menyimpan aktif/nonaktif ke `profiles.access_status`.
- [x] Edit profil super admin tersimpan ke Supabase dan avatar memakai Supabase Storage.
- [x] Ganti password akun login tersimpan ke Supabase Auth.

### Sudah Ada Tapi Masih Demo/Lokal/Belum Production

- [ ] Delete account masih reset state lokal, belum hapus akun Supabase sungguhan.
- [ ] Payment masih demo, belum gateway pembayaran asli.
- [ ] Nota/receipt sudah membaca Supabase jika ada, tetapi print/export masih UI/demo.
- [ ] Notifikasi in-app sudah ada, tetapi push notification asli ke HP belum production.

#### Catatan audit baris 48-66

- Onboarding sudah tidak hanya state lokal sementara. Status selesai onboarding sekarang tersimpan di device dengan `SharedPreferences`.
- Dashboard customer sudah refresh data utama dari Supabase saat dibuka: lokasi/slot, kendaraan, booking aktif, riwayat, favorit, dan notifikasi. Search/filter lokasi masih belum production.
- Dashboard penyedia sudah memakai Supabase untuk kartu kendaraan masuk hari ini dan pendapatan hari ini.
- Provider daily revenue detail sudah membaca transaksi, total, rata-rata, transaksi terbesar, dan metode pembayaran dari Supabase untuk hari ini.
- Provider financial report sudah membaca transaksi bulan ini, total pendapatan, estimasi pengeluaran, dan laba estimasi dari Supabase.
- Provider statistics dan grafik revenue sudah membaca pendapatan harian, bulanan, slot tersedia/penuh, dan chart 7 hari dari Supabase.
- Dashboard penjaga sudah memuat akun penjaga dan lokasi assignment dari Supabase saat dibuka; hitungan slot dashboard dibatasi ke lokasi assigned.
- Monitoring kendaraan penyedia sudah memuat transaksi penyedia dari Supabase saat halaman dibuka.
- Dashboard super admin sudah membaca agregasi Supabase untuk jumlah user per role, pending verifikasi, akun nonaktif, komplain menunggu, lokasi aktif, kendaraan aktif, total transaksi, dan revenue.
- Laporan super admin sudah membaca transaksi Supabase dan grafik revenue 7 hari.
- User management super admin sudah membaca daftar `profiles` dari Supabase dan tombol aktif/nonaktif menyimpan ke `profiles.access_status`.
- Dashboard penyedia dan penjaga masih perlu audit data per kartu/section sebelum ditandai production.
- Forgot password sudah diganti dari simulasi OTP menjadi pengiriman link reset lewat Supabase. Perlu cek konfigurasi email/redirect Supabase saat uji perangkat.
- Delete account sungguhan belum dikerjakan karena penghapusan user Auth Supabase yang aman membutuhkan server/Edge Function.
- Payment gateway asli belum dikerjakan karena membutuhkan pilihan provider pembayaran, credential, webhook, dan environment production.
- Receipt sudah baca Supabase, tetapi print/export masih UI/demo.
- Upload foto lahan sudah berjalan lewat bucket `parking-lot-photos` dan menyimpan `photo_url` ke `parking_lots`.
- Push notification asli belum dikerjakan karena membutuhkan FCM/APNs, device token, permission, dan backend trigger.

### Belum Ada atau Belum Production

- [ ] Penyedia membuat akun penjaga langsung lewat sistem aman menggunakan Edge Function.
- [ ] Reset password Supabase sungguhan.
- [ ] Hapus akun sungguhan di Supabase.
- [ ] Settings penyedia.
- [ ] Settings penjaga.
- [x] Upload foto lahan parkir ke Supabase Storage (kode dan SQL setup siap).
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
- [x] Dashboard super admin membaca ringkasan agregasi dari Supabase.
- [x] Statistik/laporan super admin membaca transaksi dan grafik revenue dari Supabase.
- [x] User management super admin membaca profil dari Supabase dan menyimpan aktif/nonaktif ke Supabase.
- [x] Edit profil super admin tersimpan ke Supabase.

#### Belum Ada/Belum Production

- [ ] User management super admin untuk hapus akun Auth sungguhan perlu Edge Function.
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
- [x] Foto lahan parkir penyedia upload ke Supabase Storage.
- [x] Dashboard penyedia membaca ringkasan kendaraan masuk dan pendapatan hari ini dari Supabase.
- [x] Provider daily revenue detail membaca transaksi hari ini dari Supabase.
- [x] Provider financial report membaca agregasi transaksi bulan ini dari Supabase.
- [x] Provider statistics dan grafik revenue membaca agregasi Supabase.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Dashboard penyedia sebagian masih perlu dicek integrasi datanya.

#### Belum Ada/Belum Production

- [x] Upload foto lahan parkir ke Supabase Storage (kode dan SQL setup siap).
- [ ] Upload dokumen identitas penyedia ke Supabase Storage.
- [ ] Settings penyedia.
- [ ] Search/filter data lokasi dari database.
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
- [x] Dashboard penjaga membaca assignment dan lokasi tugas dari Supabase saat dibuka.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Pembatasan route penjaga masih perlu middleware auth penuh.
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
- [x] Pengaturan akun customer tersimpan ke Supabase.
- [x] Forgot password mengirim link reset lewat Supabase.
- [x] Onboarding tersimpan di device dan tidak muncul ulang setelah selesai.
- [x] Dashboard customer memuat data utama dari Supabase saat halaman dibuka.
- [x] Ganti password akun login tersimpan ke Supabase Auth.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Delete account masih reset state lokal.
- [ ] Payment masih demo.
- [ ] Nota/receipt print/export masih UI/demo.

#### Belum Ada/Belum Production

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
- [x] Storage bucket foto lahan (SQL setup siap di `docs/supabase_storage_parking_lot_photos.sql`).
- [ ] Storage bucket dokumen identitas penyedia.
- [ ] Query agregasi laporan/statistik.
- [ ] Realtime slot/lokasi/notifikasi penuh.
- [ ] Push notification provider production.

## Prioritas Aman Berikutnya

1. Edit profil super admin ke Supabase.
2. Ganti password dan reset password Supabase.
3. Search/filter lokasi dari Supabase.
4. Laporan pendapatan dan statistik dari query Supabase.
5. Edge Function untuk membuat akun penjaga.
6. Route protection dan middleware auth.
7. Realtime slot/lokasi/notifikasi.
8. Delete account sungguhan.
