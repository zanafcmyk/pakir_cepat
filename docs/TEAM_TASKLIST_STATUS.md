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
- [x] Settings penyedia dan penjaga tersimpan ke Supabase lewat `profile_settings`.
- [x] Upload dokumen identitas penyedia ke Supabase Storage.
- [x] Search/filter lokasi customer memakai query Supabase.
- [x] Reset password dari link email diarahkan ke halaman set password baru.
- [x] Hapus akun sungguhan memakai Edge Function `delete-account`.
- [x] Nota/receipt bisa dicetak dan diexport sebagai PDF.
- [x] Penyedia membuat akun penjaga langsung lewat Edge Function `create-guard-account`.
- [x] Route protection dasar membatasi akses halaman berdasarkan role login.
- [x] Pondasi payment gateway Midtrans siap lewat Edge Function.
- [x] Pondasi push notification production siap lewat tabel token dan Edge Function FCM.
- [x] Pondasi realtime slot siap lewat listener `parking_slots`.
- [x] Pondasi realtime lokasi siap lewat listener `parking_lots`.
- [x] Realtime assignment penjaga siap lewat listener `parking_guards`.
- [x] Pondasi realtime notifikasi in-app siap lewat listener `notifications`.
- [x] Super admin hapus akun Auth sungguhan siap lewat Edge Function `admin-delete-user`.
- [x] Audit route guard/deep link dasar dengan test role route.
- [x] Payment tunai dikunci agar hanya penjaga berizin yang bisa konfirmasi.
- [x] Error handling refresh dashboard customer menampilkan data yang gagal dimuat.
- [x] Error handling dashboard penyedia, penjaga, dan super admin menampilkan kegagalan data Supabase.
- [x] Data demo/lokal mulai dipisah dengan flag `isUsingDemoData` dan notice dashboard.

### Sudah Ada Tapi Masih Demo/Lokal/Belum Production

- [ ] Payment gateway Midtrans perlu deploy Edge Function, isi secret, dan setting webhook di dashboard Midtrans.
- [ ] Push notification asli perlu Firebase project, file konfigurasi Android/iOS, secret FCM, dan registrasi token device.
- [x] Realtime slot SQL `docs/supabase_realtime_slots.sql` sudah dijalankan di Supabase production.
- [x] Realtime lokasi/assignment penjaga/notifikasi SQL `docs/supabase_realtime_location_notifications.sql` sudah dijalankan di Supabase production.
- [ ] Super admin hapus akun Auth perlu deploy Edge Function `admin-delete-user` dan secret `SUPABASE_SERVICE_ROLE_KEY`.

#### Catatan audit baris 48-66

- Onboarding sudah tidak hanya state lokal sementara. Status selesai onboarding sekarang tersimpan di device dengan `SharedPreferences`.
- Dashboard customer sudah refresh data utama dari Supabase saat dibuka: lokasi/slot, kendaraan, booking aktif, riwayat, favorit, dan notifikasi. Search/filter lokasi sekarang query Supabase.
- Dashboard penyedia sudah memakai Supabase untuk kartu kendaraan masuk hari ini dan pendapatan hari ini.
- Provider daily revenue detail sudah membaca transaksi, total, rata-rata, transaksi terbesar, dan metode pembayaran dari Supabase untuk hari ini.
- Provider financial report sudah membaca transaksi bulan ini, total pendapatan, estimasi pengeluaran, dan laba estimasi dari Supabase.
- Provider statistics dan grafik revenue sudah membaca pendapatan harian, bulanan, slot tersedia/penuh, dan chart 7 hari dari Supabase.
- Data demo/seed sekarang hanya aktif di debug/profile. Build release mulai dari state kosong dan menunggu data Supabase.
- Dashboard penjaga sudah memuat akun penjaga dan lokasi assignment dari Supabase saat dibuka; hitungan slot dashboard dibatasi ke lokasi assigned.
- Monitoring kendaraan penyedia sudah memuat transaksi penyedia dari Supabase saat halaman dibuka.
- Dashboard super admin sudah membaca agregasi Supabase untuk jumlah user per role, pending verifikasi, akun nonaktif, komplain menunggu, lokasi aktif, kendaraan aktif, total transaksi, dan revenue.
- Laporan super admin sudah membaca transaksi Supabase dan grafik revenue 7 hari.
- User management super admin sudah membaca daftar `profiles` dari Supabase dan tombol aktif/nonaktif menyimpan ke `profiles.access_status`.
- Dashboard penyedia dan penjaga masih perlu audit data per kartu/section sebelum ditandai production.
- Forgot password mengirim link reset Supabase dan route `/reset-password` sudah tersedia untuk set password baru. Perlu cek konfigurasi email/redirect Supabase saat uji perangkat.
- Delete account sungguhan memakai Edge Function `supabase/functions/delete-account`. Perlu deploy function dan environment `SUPABASE_SERVICE_ROLE_KEY`.
- Payment gateway Midtrans sudah disiapkan di kode dan Edge Function, tetapi belum production penuh sampai secret `MIDTRANS_SERVER_KEY`, deploy function, dan webhook Midtrans aktif.
- Receipt sudah baca Supabase dan tombol cetak/export sekarang menghasilkan PDF.
- Upload foto lahan sudah berjalan lewat bucket `parking-lot-photos` dan menyimpan `photo_url` ke `parking_lots`.
- Settings penyedia dan penjaga membutuhkan SQL `docs/supabase_profile_settings.sql` dijalankan di Supabase.
- Upload dokumen identitas penyedia membutuhkan SQL `docs/supabase_storage_provider_identity_documents.sql` dijalankan di Supabase.
- Akun penjaga langsung membutuhkan Edge Function `supabase/functions/create-guard-account` dan secret `SUPABASE_SERVICE_ROLE_KEY`.
- Push notification production sudah punya tabel token dan Edge Function FCM, tetapi belum production penuh sampai Firebase config, permission device, token registration, dan trigger pengiriman diaktifkan.

### Belum Ada atau Belum Production

- [x] Upload foto lahan parkir ke Supabase Storage (kode dan SQL setup siap).
- [x] Upload dokumen identitas penyedia ke Supabase Storage (kode dan SQL setup siap).
- [x] Search/filter lokasi sungguhan dari database.
- [x] Laporan pendapatan utama dari query Supabase.
- [x] Statistik utama dari query Supabase.
- [ ] Push notification asli ke HP dengan Firebase config di aplikasi.
- [x] Role guard/route protection dasar.
- [x] Middleware/auth redirect dasar.
- [x] Realtime slot dari tabel `parking_slots` di aplikasi.
- [x] Realtime lokasi dari tabel `parking_lots` di aplikasi.
- [x] Realtime notifikasi in-app dari tabel `notifications` di aplikasi.
- [x] Super admin user management ke Supabase untuk lihat user dan aktif/nonaktif akun.
- [x] Super admin hapus akun Auth sungguhan lewat admin action.

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

- [x] User management super admin untuk hapus akun Auth sungguhan lewat Edge Function.
- [x] Role guard dasar dan redirect auth sudah tersedia.
- [x] Audit role guard dan middleware auth dasar untuk deep link role.
- [ ] Audit deep link production di perangkat asli sebelum release.
- [ ] Push notification asli ke HP dengan Firebase config di aplikasi.
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
- [x] Settings penyedia tersimpan ke Supabase lewat `profile_settings`.
- [x] Upload dokumen identitas penyedia tersimpan ke Supabase Storage saat registrasi.
- [x] Penyedia membuat akun login penjaga langsung lewat Edge Function.

#### Sudah Ada Tapi Masih Demo/Lokal

- [ ] Dashboard penyedia sebagian masih perlu dicek integrasi datanya.
- [ ] Payment provider untuk settlement asli masih menunggu deploy Midtrans dan webhook.

#### Belum Ada/Belum Production

- [x] Upload foto lahan parkir ke Supabase Storage (kode dan SQL setup siap).
- [x] Upload dokumen identitas penyedia ke Supabase Storage (kode dan SQL setup siap).
- [x] Search/filter data lokasi dari database.
- [x] Edge Function untuk membuat akun penjaga secara aman.

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
- [x] Settings penjaga tersimpan ke Supabase lewat `profile_settings`.

#### Sudah Ada Tapi Masih Demo/Lokal

- [x] Pembatasan route penjaga dasar sudah ada.
- [ ] Pembatasan route penjaga perlu audit deep link production.
- [x] Pembayaran tunai/manual hanya bisa dikonfirmasi penjaga yang punya izin.
- [ ] Pembayaran tunai/manual perlu audit kas/settlement production.

#### Belum Ada/Belum Production

- [x] Role guard khusus penjaga agar tidak bisa membuka halaman role lain.
- [x] Realtime status slot/lokasi/assignment untuk penjaga.
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

- [ ] Payment online sudah diarahkan ke pondasi Midtrans, tetapi belum production sampai Edge Function, secret, dan webhook aktif.
- [x] Payment tunai/manual diarahkan ke penjaga dan customer tidak bisa melunasi sendiri.
- [ ] Payment tunai/manual perlu audit kas/settlement production.

#### Belum Ada/Belum Production

- [x] Reset password Supabase punya halaman set password baru dari link email.
- [x] Hapus akun sungguhan memakai Edge Function `delete-account`.
- [x] Search/filter lokasi sungguhan dari database.
- [ ] Push notification booking/payment ke HP setelah Firebase config dipasang.

### Backend/Supabase Bersama

#### Sudah Berjalan

- [x] Schema utama Supabase sudah dibuat.
- [x] Chat Supabase termasuk realtime sudah berjalan.
- [x] Notifikasi in-app/table sudah berjalan.
- [x] Storage avatar sudah dipakai untuk upload foto profil.
- [x] Trigger rating/review sudah disiapkan di dokumen SQL.
- [x] Trigger notifikasi otomatis sudah disiapkan di dokumen SQL.
- [x] Edge Function hapus akun sungguhan siap di `supabase/functions/delete-account`.

#### Sudah Ada Tapi Perlu Diperkuat

- [ ] Policy RLS perlu dicek ulang per role sebelum production.
- [ ] SQL trigger perlu dipastikan sudah dijalankan di Supabase production.
- [x] SQL realtime slot sudah dijalankan di Supabase production.
- [x] SQL realtime lokasi/assignment penjaga/notifikasi sudah dijalankan di Supabase production.
- [x] Data demo/lokal mulai dipisah dari data production lewat flag `isUsingDemoData`.
- [x] Data demo/lokal diaudit agar seed tidak muncul di build production.
- [x] Error handling koneksi Supabase mulai diperkuat di dashboard customer.
- [x] Error handling koneksi Supabase dashboard utama sudah diperkuat.
- [ ] Error handling koneksi Supabase perlu diaudit konsisten di form dan halaman detail.
- [x] Route protection dasar punya test deep link role.
- [ ] Route protection perlu audit production lanjutan di perangkat asli setelah semua deep link final.

#### Belum Ada/Belum Production

- [x] Edge Function untuk membuat akun penjaga.
- [x] Edge Function/admin flow untuk hapus akun sungguhan.
- [x] Edge Function `admin-delete-user` untuk super admin menghapus akun Auth user lain.
- [x] Edge Function `create-midtrans-payment` untuk membuat transaksi Midtrans Snap.
- [x] Edge Function `midtrans-webhook` untuk menerima callback Midtrans.
- [x] Edge Function `send-push-notification` untuk mengirim FCM HTTP v1.
- [x] Tabel `device_push_tokens` disiapkan di `docs/supabase_push_notifications.sql`.
- [x] SQL realtime slot disiapkan di `docs/supabase_realtime_slots.sql`.
- [x] SQL realtime lokasi/assignment penjaga/notifikasi disiapkan di `docs/supabase_realtime_location_notifications.sql`.
- [x] Storage bucket foto lahan (SQL setup siap di `docs/supabase_storage_parking_lot_photos.sql`).
- [x] Storage bucket dokumen identitas penyedia (SQL setup siap di `docs/supabase_storage_provider_identity_documents.sql`).
- [x] Query agregasi laporan/statistik utama.
- [x] Realtime lokasi/notifikasi in-app dasar.
- [ ] Realtime production perlu audit perangkat setelah SQL publication dijalankan.
- [ ] Push notification provider production setelah Firebase config dipasang.

## Prioritas Aman Berikutnya

1. Deploy Edge Function payment dan isi secret Midtrans.
2. Pasang Firebase config agar token push notification bisa didaftarkan dari HP.
3. Uji realtime slot/lokasi/notifikasi di dua perangkat.
4. Uji production route protection di perangkat asli.
