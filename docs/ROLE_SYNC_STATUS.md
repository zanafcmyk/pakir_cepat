# Status Sinkron Antar Role

Dokumen ini mencatat sinkron fitur antar role Parkir Cepat. Status dibuat per arah komunikasi/data supaya pekerjaan berikutnya bisa dicicil tanpa mengganggu fitur yang sudah jalan.

## Sudah Disinkronkan

- [x] Customer ke penyedia: booking, pembayaran, review/rating, favorit lokasi, dan chat tersimpan lewat Supabase.
- [x] Penyedia ke customer: lokasi parkir, slot, status booking, riwayat/nota, dan chat dibaca dari Supabase.
- [x] Customer ke penjaga: booking aktif bisa dibaca dari QR dan status masuk/keluar kendaraan tersimpan ke Supabase.
- [x] Penjaga ke customer: update masuk/keluar kendaraan dan konfirmasi pembayaran tunai tersimpan ke Supabase.
- [x] Penyedia ke penjaga: akun penjaga, assignment lokasi, slot, dan chat memakai Supabase.
- [x] Penjaga ke penyedia: update kendaraan masuk/keluar dan monitoring kendaraan penyedia membaca Supabase.
- [x] Penyedia ke super admin: pengajuan verifikasi, data profil, laporan ringkasan, komplain, dan chat memakai Supabase.
- [x] Super admin ke penyedia: approval/reject penyedia, aktif/nonaktif akun, hapus akun, balasan komplain, dan chat memakai Supabase.
- [x] Customer ke super admin: komplain customer dan chat memakai Supabase.
- [x] Super admin ke customer: balasan komplain, user management, hapus akun, dan chat memakai Supabase.
- [x] Penjaga ke super admin: komplain penjaga, status akun penjaga, dan chat memakai Supabase.
- [x] Super admin ke penjaga: user management, hapus akun, balasan komplain, dan chat memakai Supabase.
- [x] Notifikasi in-app booking dan pembayaran dibuat ke tabel `notifications` untuk penyedia pemilik lokasi dan penjaga yang ditugaskan.
- [x] Notifikasi in-app balasan komplain dibuat ke tabel `notifications` untuk profil pengirim komplain.
- [x] Notifikasi in-app verifikasi dibuat ke tabel `notifications` untuk profil penyedia yang diverifikasi.
- [x] Chat customer-provider mencoba menargetkan penyedia pemilik lokasi.
- [x] Chat customer-penjaga mencoba menargetkan penjaga assignment dari tiket booking.
- [x] Chat penjaga-customer mencoba menargetkan customer pemilik tiket booking.
- [x] Chat penyedia-penjaga mencoba menargetkan penjaga milik penyedia atau penyedia milik penjaga.

## Perlu Dicek Saat Uji Perangkat

- [ ] Chat antar role sudah ditingkatkan ke target berbasis konteks, tetapi tetap perlu uji apakah setiap percakapan masuk ke orang/lokasi yang tepat saat ada banyak penyedia atau banyak penjaga.
- [x] Notifikasi booking/payment sudah ditargetkan berdasarkan lokasi parkir dan assignment penjaga.
- [x] Notifikasi balasan komplain sudah ditargetkan ke `sender_profile_id`.
- [x] Notifikasi verifikasi sudah ditargetkan ke `profile_id` saat data berasal dari Supabase.
- [ ] Push notification HP masih belum production penuh sampai Firebase config, token device, secret FCM, dan trigger pengiriman aktif.
- [ ] RLS/policy Supabase perlu audit akhir supaya setiap role hanya bisa melihat data miliknya.
- [ ] Payment Midtrans perlu webhook production agar perubahan status pembayaran dari Midtrans otomatis balik ke Supabase.

## Rekomendasi Berikutnya

1. Uji chat dan notifikasi dengan minimal 1 customer, 1 penyedia, 1 penjaga, dan 1 super admin.
2. Uji target room chat dengan banyak akun dan audit policy RLS jika ada member room yang gagal dibuat.
3. Audit RLS Supabase per role sebelum aplikasi dipakai publik.
