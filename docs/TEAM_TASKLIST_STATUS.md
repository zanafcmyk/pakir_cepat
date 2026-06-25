# Tasklist Status dan Pembagian Tim

Dokumen ini dipakai sebagai acuan kerja tim Parkir Cepat. Tujuannya supaya fitur yang sudah berjalan tidak dikerjakan ulang, fitur demo terlihat jelas, dan fitur yang belum production bisa dicicil dengan aman.

Terakhir diperbarui: 26 Juni 2026 berdasarkan audit kode, Supabase live, Edge Function, analyzer, test, patch kendaraan, GPS/ETA, payment UI, laporan gaji penjaga, dan audit tasklist.

## Cara Pakai

- Kerjakan satu fitur kecil dalam satu waktu.
- Jangan mengerjakan banyak item sekaligus.
- Sebelum coding, pastikan branch dan scope tidak bentrok dengan anggota lain.
- Setelah satu fitur selesai, jalankan `flutter analyze` dan `flutter test` bila ada perubahan kode.
- Buat commit kecil setelah fitur terbukti jalan.
- Jika ada kerusakan, kembali ke commit aman sebelum perubahan tersebut.

## Status Umum

### Ringkasan Tasklist 26 Juni 2026

- Total item terhitung: 262.
- Selesai: 245.
- Belum selesai: 17.
- Item push notification, audit Midtrans, audit deep link, audit RLS, dan realtime production yang sebelumnya muncul berulang sudah dikonsolidasikan ke item utama masing-masing.

### Audit Terbaru 21 Juni 2026

#### Kritis - Wajib Sebelum Production

- [x] Patch kode dan SQL untuk memperketat RLS `bookings`/`payments` serta mencabut write langsung client sudah dibuat di `docs/supabase_booking_payment_security_patch.sql`.
- [x] Flutter tidak lagi mengirim `price_per_hour` atau `estimated_cost`; RPC menghitung tarif dari lahan, jenis kendaraan, tipe tarif, dan durasi lalu mengembalikan nominal server.
- [x] `docs/supabase_booking_payment_security_patch.sql` sudah dijalankan di Supabase production berdasarkan konfirmasi owner; uji ulang semua role tetap perlu dilanjutkan.
- [x] Konfirmasi pembayaran tunai penjaga dipindahkan dari service customer ke RPC khusus yang memvalidasi izin, assignment, status booking, nominal server, payment, receipt, dan activity log.
- [x] Scan masuk/keluar dipindahkan ke RPC atomik yang memvalidasi assignment penjaga, status sebelumnya, update slot, waktu scan, dan activity log.
- [x] Penyedia dapat menjadi operator scan/tunai untuk lokasi miliknya ketika tidak ada penjaga aktif yang ditugaskan; validasi kepemilikan dan ketiadaan penjaga dilakukan server-side.
- [x] Proses kedaluwarsa reservasi server-side tersedia di `docs/supabase_booking_expiry.sql`: booking lewat 15 menit dibatalkan, slot dilepas, payment pending dibatalkan, customer diberi notifikasi, dan proses dijadwalkan tiap menit dengan `pg_cron`.
- [ ] Jalankan `docs/supabase_booking_expiry.sql` di Supabase production, deploy ulang Edge Function Midtrans, lalu uji expiry dan callback terlambat.

#### Belum Berjalan Penuh

- [x] Cek pembayaran penjaga mencari nomor tiket/plat dari booking Supabase dan membatasi hasil ke lokasi assignment penjaga.
- [x] Daftar kendaraan aktif penjaga membaca seluruh booking operasional pada lokasi assignment, mendukung filter lokasi, muat ulang, dan konfirmasi tunai per tiket.
- [x] Listener realtime penjaga memuat ulang booking operasional saat tabel `bookings` atau `payments` berubah.
- [ ] Jalankan `docs/supabase_realtime_guard_operations.sql` di production agar perubahan booking/payment diterima realtime tanpa membuka ulang halaman.
- [ ] Jalankan `docs/supabase_guard_assignment_validation.sql`, simpan ulang assignment penjaga dari akun penyedia, lalu uji scan tiket di lahan yang sama.
- [x] Perpanjang durasi parkir memperbarui `duration_hours`, biaya total, dan sisa tagihan dari RPC Supabase di `docs/supabase_booking_extension_patch.sql`.
- [x] Perubahan status slot provider melakukan rollback state jika Supabase gagal, payment gagal membatalkan booking dan melepas slot, serta tersedia SQL repair `docs/supabase_slot_status_repair.sql`.
- [x] Tambahkan aksi nonaktif/hapus lahan dari aplikasi. Lokasi tanpa riwayat booking dapat dihapus, sedangkan lokasi dengan riwayat otomatis diarsipkan lewat `docs/supabase_provider_remove_parking_lot.sql`.
- [x] Pulihkan sesi Supabase saat aplikasi dibuka ulang dan fungsikan pilihan `Ingat saya`; role/email terakhir disimpan di perangkat, dan logout membersihkan session.
- [x] Daftarkan deep link Android/iOS untuk reset password dan callback selesai pembayaran memakai scheme `parkircepat://`.
- [x] Tambahkan `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, dan `NSLocationWhenInUseUsageDescription` pada iOS.
- [x] Tampilkan foto lahan dari `photo_url` pada kartu lokasi customer dan halaman detail; fallback tetap tersedia jika foto belum ada/gagal dimuat.
- [x] Simpan dan tampilkan `duration_hours` dari booking. Halaman pembayaran memakai durasi dari Supabase, bukan menurunkan dari total biaya.
- [x] Ganti QR tiket polos menjadi payload opaque dari `bookings.qr_payload`; patch SQL `docs/supabase_secure_ticket_qr.sql` menyiapkan token baru untuk booking lama dan booking baru.

#### Masih Demo atau Estimasi

- [x] Jarak dan ETA lokasi customer memakai GPS perangkat saat izin lokasi aktif; fallback data lama tetap dipakai bila GPS mati/ditolak. ETA masih estimasi garis lurus, belum rute/traffic maps.
- [x] QR pembayaran demo sebelum Midtrans dihapus; QRIS resmi hanya ditampilkan oleh halaman Midtrans, sedangkan aplikasi menampilkan QR tiket setelah pembayaran berhasil.
- [x] Input nomor e-wallet demo dihapus dari aplikasi; pilihan e-wallet hanya menjadi preferensi metode dan detail pembayaran diisi di Midtrans bila dibutuhkan.
- [x] Pengeluaran laporan penyedia memakai gaji penjaga 15% dari revenue lahan yang punya penjaga; lahan tanpa penjaga tidak memotong gaji, dan satu lahan dengan beberapa penjaga dibagi rata.
- [ ] Pilihan bahasa dan keamanan akun baru disimpan sebagai setting, belum mengubah bahasa atau mekanisme keamanan aplikasi.
- [x] Data seed lokasi, kendaraan, chat, notifikasi, dan laporan dibatasi untuk debug/profile; build release memakai state kosong.

#### Hasil Pemeriksaan Teknis

- [x] `flutter analyze --no-pub` lulus tanpa issue.
- [x] Seluruh 6 test saat ini lulus.
- [x] Audit alur utama end-to-end terbaru dicatat di `docs/e2e_main_flow_audit_2026-06-25.md`.
- [x] Verifikasi SQL production terbaru via `docs/supabase_production_sql_verification.sql` lulus: tabel, kolom, RPC, RLS, policy, trigger, realtime publication, storage bucket, dan cron expiry semuanya `OK`.
- [x] Audit kode dan deploy webhook Midtrans terbaru dicatat di `docs/midtrans_audit_2026-06-25.md`; webhook production aktif version 10 dan sudah diberi guard idempotensi agar payment `paid` tidak downgrade.
- [ ] Tambah test booking, perhitungan tarif, pembayaran, receipt, scan masuk/keluar, expiry reservasi, dan RLS. Test saat ini hanya mencakup splash dan route guard.
- [x] Supabase Auth live sehat dan tabel `parking_lots`, `receipts`, serta `device_push_tokens` tersedia.
- [x] Edge Function `create-midtrans-payment`, `midtrans-webhook`, `create-guard-account`, `delete-account`, `admin-delete-user`, dan `send-push-notification` terdeploy dan merespons.
- [ ] Build APK release belum berhasil diverifikasi. Flutter berhasil sampai tahap kompilasi/tree-shaking, lalu JVM Gradle crash; turunkan konfigurasi heap `-Xmx8G` dan ulangi build pada mesin yang cukup stabil.
- [ ] Edit ulang data lahan live lama dengan alamat lengkap. Dua lahan yang diaudit masih memakai koordinat default yang sama `-6.2087145, 106.8224854`.
- [x] `send-push-notification` sekarang mewajibkan `PUSH_FUNCTION_SECRET`; function sudah dideploy ulang sebagai version 6.

### Sudah Berjalan dan Terhubung Supabase

- [x] Login dan registrasi customer.
- [x] Login dan registrasi penyedia.
- [x] Login super admin.
- [x] Login penjaga dari akun yang dibuat penyedia.
- [x] Approval/verifikasi penyedia oleh super admin.
- [x] Status verifikasi penyedia disinkronkan ulang dari `profiles`, `providers`, dan `provider_applications`.
- [x] Super admin memuat pengajuan penyedia pending dari tabel `provider_applications`.
- [x] Super admin memuat fallback pengajuan penyedia pending dari tabel `providers` jika `provider_applications` belum ada/terbaca.
- [x] Super admin punya RPC/fallback untuk memuat dan memperbarui verifikasi penyedia dari Supabase.
- [x] Halaman verifikasi super admin punya tombol muat ulang pengajuan penyedia.
- [x] Data lokasi parkir dan slot penyedia ke Supabase.
- [x] Membaca lokasi parkir dan slot dari Supabase ke aplikasi.
- [x] Slot booking customer tampil sebagai grid slot per lokasi yang lebih realistis.
- [x] Penyedia bisa menambah slot parkir dari halaman kelola slot dan menyimpannya ke Supabase.
- [x] Daftar lokasi penyedia punya aksi tambah lokasi, edit lokasi, dan kelola slot per lokasi.
- [x] Kendaraan customer ke Supabase.
- [x] Form tambah kendaraan membuat satu input plat untuk setiap jumlah kendaraan dan menyimpan setiap plat sebagai kendaraan terpisah.
- [x] Halaman booking menyediakan pilihan kendaraan dan input waktu masuk manual dengan validasi format tanggal/jam.
- [x] Booking parkir memakai RPC untuk reserve slot, menghitung tarif server, dan membuat booking secara bersamaan; patch SQL masih harus diterapkan di production.
- [x] Payment online Midtrans memiliki jalur penyimpanan Supabase dan webhook; payment tunai penjaga sudah dipindahkan ke RPC aman dan menunggu penerapan SQL live.
- [x] Halaman pembayaran menyediakan dua aksi jelas: bayar melalui Midtrans atau bayar langsung/tunai di lokasi yang tetap membutuhkan konfirmasi penjaga/operator.
- [x] Metode debit/kredit dihapus dari aplikasi; metode tersisa scan QR/QRIS, e-wallet, dan tunai.
- [x] Payment gateway hanya memakai booking yang berhasil tersimpan di Supabase; fallback booking lokal/demo dihapus.
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
- [x] Sinkron notifikasi in-app antar role untuk booking, pembayaran, verifikasi akun, dan komplain dasar.
- [x] Notifikasi booking dan pembayaran diarahkan ke penyedia pemilik lokasi dan penjaga yang ditugaskan, dengan fallback role-level.
- [x] Notifikasi balasan komplain diarahkan ke profil pengirim komplain, dengan fallback role-level untuk data lama/demo.
- [x] Notifikasi verifikasi akun penyedia diarahkan ke profil penyedia yang diverifikasi, dengan fallback role-level untuk data lama/demo.
- [x] Chat room mencoba menargetkan member spesifik dari konteks lokasi/tiket/provider-guard sebelum fallback role-level.
- [x] Audit RLS sinkron antar-role dibuat dan kode memakai RPC optional untuk chat/notifikasi.
- [x] Super admin hapus akun Auth sungguhan siap lewat Edge Function `admin-delete-user`.
- [x] Audit route guard/deep link dasar dengan test role route.
- [x] UI payment tunai dan service sudah memakai RPC khusus penjaga; penerapan SQL production serta uji perangkat masih diperlukan.
- [x] Error handling refresh dashboard customer menampilkan data yang gagal dimuat.
- [x] Error handling dashboard penyedia, penjaga, dan super admin menampilkan kegagalan data Supabase.
- [x] Data demo/lokal mulai dipisah dengan flag `isUsingDemoData` dan notice dashboard.

### Sudah Ada Tapi Masih Demo/Lokal/Belum Production

- [x] Edge Function Midtrans dan webhook sudah terdeploy serta merespons pada proyek Supabase live.
- [ ] Lakukan uji settlement Midtrans end-to-end berulang dengan transaksi sandbox nyata: Snap, webhook, `payments.status`, `bookings.status`, receipt, dan tampilan tiket setelah aplikasi kembali aktif.
- [ ] Deploy ulang `create-midtrans-payment` agar callback selesai pembayaran memakai fallback `parkircepat://payment-finish`, lalu uji kembali otomatis dari Midtrans sandbox ke aplikasi.
- [ ] Push notification asli perlu audit akhir: pastikan Firebase config/secret live, token device tersimpan, dan pemicu server-side otomatis mengirim event booking/payment/guard ke HP.
- [x] App Flutter sudah menambahkan Firebase Messaging, permission Android, registrasi token FCM ke `device_push_tokens`, refresh token, dan unregister saat logout/delete account.
- [x] Notifikasi verifikasi akun sudah ditargetkan ke `profile_id` penerima spesifik saat data Supabase tersedia.
- [x] Realtime slot SQL `docs/supabase_realtime_slots.sql` sudah dijalankan di Supabase production.
- [x] Realtime lokasi/assignment penjaga/notifikasi SQL `docs/supabase_realtime_location_notifications.sql` sudah dijalankan di Supabase production.
- [ ] Chat target spesifik perlu uji perangkat dengan banyak penyedia/penjaga untuk memastikan RLS dan member room sesuai.
- [ ] SQL RLS/role-sync patch `docs/supabase_role_sync_rls_patch.sql` perlu diaudit ulang di Supabase production, termasuk RPC booking customer dan `app_provider_add_parking_slot`.
- [x] Edge Function `admin-delete-user` sudah terdeploy dan merespons; pastikan `SERVICE_ROLE_KEY` tetap tersedia serta audit aksi hapus memakai akun super admin.

#### Catatan audit baris 48-66

- Onboarding sudah tidak hanya state lokal sementara. Status selesai onboarding sekarang tersimpan di device dengan `SharedPreferences`.
- Dashboard customer sudah refresh data utama dari Supabase saat dibuka: lokasi/slot, kendaraan, booking aktif, riwayat, favorit, dan notifikasi. Search/filter lokasi sekarang query Supabase.
- Dashboard penyedia sudah memakai Supabase untuk kartu kendaraan masuk hari ini, pendapatan hari ini, slot tersedia, dan slot aktif.
- Provider daily revenue detail sudah membaca transaksi, total, rata-rata, transaksi terbesar, dan metode pembayaran dari Supabase untuk hari ini.
- Provider financial report sudah membaca transaksi bulan ini, total pendapatan, gaji penjaga 15% berbasis assignment lahan, dan laba estimasi dari Supabase.
- Provider statistics dan grafik revenue sudah membaca pendapatan harian, bulanan, slot tersedia/penuh, dan chart 7 hari dari Supabase.
- Data demo/seed sekarang hanya aktif di debug/profile. Build release mulai dari state kosong dan menunggu data Supabase.
- Dashboard penjaga sudah memuat akun penjaga dan lokasi assignment dari Supabase saat dibuka; hitungan slot dashboard dibatasi ke lokasi assigned.
- Monitoring kendaraan penyedia sudah memuat transaksi penyedia dari Supabase saat halaman dibuka.
- Dashboard super admin sudah membaca agregasi Supabase untuk jumlah user per role, pending verifikasi, akun nonaktif, komplain menunggu, lokasi aktif, kendaraan aktif, total transaksi, dan revenue.
- Laporan super admin sudah membaca transaksi Supabase dan grafik revenue 7 hari.
- User management super admin sudah membaca daftar `profiles` dari Supabase dan tombol aktif/nonaktif menyimpan ke `profiles.access_status`.
- Dashboard penyedia sudah diaudit agar kartu utama memakai summary Supabase dan grafik tidak menampilkan revenue demo saat data kosong.
- Error handling form/detail utama sudah diperkuat dengan notice menetap di form tambah lahan, akun penjaga, komplain customer, dan komplain penjaga.
- Checklist deploy eksternal dibuat di `docs/production_external_deploy_checklist.md`.
- Forgot password mengirim link reset Supabase dan route `/reset-password` sudah tersedia untuk set password baru. Perlu cek konfigurasi email/redirect Supabase saat uji perangkat.
- Delete account sungguhan memakai Edge Function `supabase/functions/delete-account`; function sudah terdeploy dan tetap membutuhkan environment `SERVICE_ROLE_KEY`.
- Payment gateway Midtrans dan webhook sudah terdeploy serta merespons. Production tetap membutuhkan audit settlement end-to-end, idempotensi payment, callback/deep link, dan monitoring kegagalan webhook.
- Payment gateway ditampung dulu; pilihan debit/kredit sudah dihapus dari aplikasi sesuai keputusan terbaru.
- Receipt sudah baca Supabase dan tombol cetak/export sekarang menghasilkan PDF.
- Upload foto lahan sudah berjalan lewat bucket `parking-lot-photos` dan menyimpan `photo_url` ke `parking_lots`.
- Settings penyedia dan penjaga membutuhkan SQL `docs/supabase_profile_settings.sql` dijalankan di Supabase.
- Upload dokumen identitas penyedia membutuhkan SQL `docs/supabase_storage_provider_identity_documents.sql` dijalankan di Supabase.
- Akun penjaga langsung memakai Edge Function `supabase/functions/create-guard-account`; function sudah terdeploy dan tetap membutuhkan secret `SERVICE_ROLE_KEY`.
- Push notification production sudah punya tabel token, registrasi token app-side, permission device, dan Edge Function FCM. Belum production penuh sampai Firebase config/secret dipasang dan trigger pengiriman otomatis diaktifkan.
- Matriks sinkron antar role dicatat di `docs/ROLE_SYNC_STATUS.md`.
- Audit RLS sinkron antar role dicatat di `docs/RLS_AUDIT_STATUS.md`.

### Belum Ada atau Belum Production

- [x] Upload foto lahan parkir ke Supabase Storage (kode dan SQL setup siap).
- [x] Upload dokumen identitas penyedia ke Supabase Storage (kode dan SQL setup siap).
- [x] Search/filter lokasi sungguhan dari database.
- [x] Laporan pendapatan utama dari query Supabase.
- [x] Statistik utama dari query Supabase.
- [x] Item push notification production dikonsolidasikan ke item audit push notification utama di bagian "Sudah Ada Tapi Masih Demo/Lokal/Belum Production".
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
- [x] Item push notification production dikonsolidasikan ke item audit push notification utama di bagian "Sudah Ada Tapi Masih Demo/Lokal/Belum Production".
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

- [x] Dashboard penyedia diaudit dan kartu utama membaca agregasi Supabase.
- [x] Edge Function Midtrans dan webhook sudah terdeploy.
- [x] Item audit settlement provider dikonsolidasikan ke item audit Midtrans end-to-end utama.

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
- [x] Item audit deep link penjaga dikonsolidasikan ke item audit deep link production utama.
- [x] Konfirmasi tunai sudah memakai RPC khusus dengan validasi izin dan assignment penjaga.
- [ ] Jalankan patch SQL lalu audit kas/settlement payment tunai di production.
- [x] Cek pembayaran dan daftar kendaraan aktif penjaga memakai query Supabase lintas booking yang dibatasi assignment lokasi.
- [x] Item SQL publication booking/payment dikonsolidasikan ke item realtime operasional penjaga utama.

#### Belum Ada/Belum Production

- [x] Role guard khusus penjaga agar tidak bisa membuka halaman role lain.
- [x] Realtime status slot/lokasi/assignment untuk penjaga.
- [x] Item push notification penjaga dikonsolidasikan ke item audit push notification utama di bagian "Sudah Ada Tapi Masih Demo/Lokal/Belum Production".

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

- [x] Payment online sudah diarahkan ke Midtrans dan Edge Function/webhook sudah terdeploy.
- [x] Tombol simulasi pembayaran customer tersedia untuk demo/sandbox lewat `docs/supabase_simulate_customer_payment.sql`, langsung membuat tiket aktif, receipt, dan notifikasi.
- [x] Item audit payment customer dikonsolidasikan ke item audit Midtrans end-to-end utama.
- [x] Payment tunai/manual diarahkan ke penjaga dan customer tidak bisa melunasi sendiri.
- [x] Penyimpanan payment tunai penjaga sudah diarahkan ke RPC khusus; menunggu patch SQL diterapkan di production.
- [x] Perpanjang durasi dan biaya parkir customer tersimpan ke Supabase melalui RPC dan pembayaran tambahan memakai sisa tagihan.

#### Belum Ada/Belum Production

- [x] Reset password Supabase punya halaman set password baru dari link email.
- [x] Hapus akun sungguhan memakai Edge Function `delete-account`.
- [x] Search/filter lokasi sungguhan dari database.
- [x] Item push notification customer dikonsolidasikan ke item audit push notification utama di bagian "Sudah Ada Tapi Masih Demo/Lokal/Belum Production".

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

- [x] Item audit policy RLS dikonsolidasikan ke item audit SQL RLS/role-sync production utama.
- [ ] SQL trigger perlu dipastikan sudah dijalankan di Supabase production.
- [ ] Jalankan `docs/supabase_secure_ticket_qr.sql` di Supabase production, lalu uji scan QR token baru dan input manual nomor tiket.
- [x] SQL realtime slot sudah dijalankan di Supabase production.
- [x] SQL realtime lokasi/assignment penjaga/notifikasi sudah dijalankan di Supabase production.
- [x] Data demo/lokal mulai dipisah dari data production lewat flag `isUsingDemoData`.
- [x] Data demo/lokal diaudit agar seed tidak muncul di build production.
- [x] Error handling koneksi Supabase mulai diperkuat di dashboard customer.
- [x] Error handling koneksi Supabase dashboard utama sudah diperkuat.
- [x] Error handling koneksi Supabase diaudit dan diperkuat di form/detail utama.
- [x] Route protection dasar punya test deep link role.
- [x] Item route protection production dikonsolidasikan ke item audit deep link production utama.

#### Belum Ada/Belum Production

- [x] Edge Function untuk membuat akun penjaga.
- [x] Edge Function/admin flow untuk hapus akun sungguhan.
- [x] Edge Function `admin-delete-user` untuk super admin menghapus akun Auth user lain.
- [x] Edge Function `create-midtrans-payment` untuk membuat transaksi Midtrans Snap.
- [x] Edge Function `midtrans-webhook` untuk menerima callback Midtrans.
- [x] Edge Function `send-push-notification` untuk mengirim FCM HTTP v1.
- [x] Checklist deploy eksternal admin-delete, Midtrans, dan Firebase dibuat di `docs/production_external_deploy_checklist.md`.
- [x] Tabel `device_push_tokens` disiapkan di `docs/supabase_push_notifications.sql`.
- [x] SQL realtime slot disiapkan di `docs/supabase_realtime_slots.sql`.
- [x] SQL realtime lokasi/assignment penjaga/notifikasi disiapkan di `docs/supabase_realtime_location_notifications.sql`.
- [x] Storage bucket foto lahan (SQL setup siap di `docs/supabase_storage_parking_lot_photos.sql`).
- [x] Storage bucket dokumen identitas penyedia (SQL setup siap di `docs/supabase_storage_provider_identity_documents.sql`).
- [x] Query agregasi laporan/statistik utama.
- [x] Realtime lokasi/notifikasi in-app dasar.
- [x] Item audit realtime production dikonsolidasikan ke item realtime operasional penjaga utama.
- [x] Item push notification provider dikonsolidasikan ke item audit push notification utama di bagian "Sudah Ada Tapi Masih Demo/Lokal/Belum Production".

## Prioritas Aman Berikutnya

1. Uji ulang booking, Midtrans, tunai, masuk, serta keluar setelah patch keamanan production.
2. Jalankan dan uji expiry reservasi server-side di Supabase production.
3. Jalankan SQL realtime operasional penjaga dan uji dengan akun customer serta penjaga.
4. Jalankan SQL perpanjangan durasi dan deploy ulang Edge Function Midtrans, lalu uji extend 1 jam sebelum/sesudah pembayaran.
5. Jalankan SQL repair slot, deploy ulang webhook Midtrans, lalu audit slot reserved/occupied lama yang pernah nyangkut.
6. Jalankan SQL hapus/nonaktif lahan lalu uji lokasi tanpa riwayat dan lokasi dengan riwayat booking.
7. Audit push notification live end-to-end dari event database sampai notifikasi muncul di HP.
8. Jalankan SQL secure QR ticket dan uji scan token baru.
9. Edit ulang koordinat/alamat data lahan live lama yang masih memakai koordinat default.
10. Tambah integration test multi-role/multi-device dan stabilkan build APK release.
