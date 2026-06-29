# E2E Main Flow Audit - 25 Juni 2026

Audit ini mengecek alur utama Parkir Cepat:

Customer daftar/login -> tambah kendaraan -> pilih lokasi/slot -> booking ->
bayar -> tiket QR -> penjaga/operator scan masuk -> scan keluar -> nota/riwayat.

## Hasil Otomatis

- `flutter analyze --no-pub`: lulus, tidak ada issue.
- `flutter test --no-pub`: lulus, 6 test passed.
- Service kendaraan customer: sudah tidak bergantung pada `vehicles.created_at`
  dan bisa membuat profil/customer row yang hilang untuk akun baru.
- Service booking customer: memakai RPC `app_create_customer_booking`, bukan
  insert langsung ke tabel `bookings`.
- Service payment: Midtrans melalui Edge Function `create-midtrans-payment`;
  simulasi demo melalui RPC `app_simulate_customer_payment`.
- Service scan/tunai operator: memakai RPC `app_operator_process_ticket` dan
  `app_operator_confirm_cash_payment`.
- Receipt: membaca tabel `receipts` dan fallback ke riwayat transaksi jika data
  receipt belum tersedia.

## Catatan Build

- `flutter build web --no-pub` menghasilkan artefak `build/web/main.dart.js`,
  tetapi command timeout setelah 3 menit sebelum selesai rapi.
- Ada proses Flutter/Dart/Chrome lain yang sedang berjalan di mesin, jadi proses
  tersebut tidak dimatikan otomatis.
- Untuk verifikasi release, ulangi build saat dev server/debugger lain sudah
  ditutup.

## Checklist Uji Manual Live

### Customer

- [ ] Register customer baru dengan email unik.
- [ ] Login customer baru.
- [ ] Tambah kendaraan 1 plat.
- [ ] Tambah kendaraan beberapa plat sekaligus.
- [ ] Pastikan data kendaraan muncul ulang setelah logout/login.
- [ ] Pilih lokasi parkir yang berasal dari Supabase, bukan data demo.
- [ ] Pilih slot available.
- [ ] Isi waktu masuk manual.
- [ ] Buat booking.
- [ ] Pastikan booking tersimpan sebagai `pending_payment`.
- [ ] Tekan simulasi pembayaran.
- [ ] Pastikan halaman pindah ke Tiket digital.
- [ ] Pastikan QR tiket tampil.
- [ ] Buka nota dari halaman tiket.
- [ ] Pastikan notifikasi pembayaran masuk.
- [ ] Pastikan riwayat transaksi memuat booking tersebut.

### Penyedia

- [ ] Login penyedia terverifikasi.
- [ ] Pastikan lokasi dan slot yang dipakai customer terlihat.
- [ ] Pastikan slot berubah reserved/occupied sesuai status booking.
- [ ] Jika lokasi tanpa penjaga, buka operator scan dari akun penyedia.
- [ ] Konfirmasi pembayaran tunai dari operator penyedia untuk booking tunai.

### Penjaga

- [ ] Login akun penjaga yang ditugaskan ke lokasi booking.
- [ ] Buka daftar kendaraan aktif.
- [ ] Cari booking memakai nomor tiket.
- [ ] Cari booking memakai plat kendaraan.
- [ ] Scan/input manual QR untuk masuk.
- [ ] Pastikan status booking berubah `active`.
- [ ] Scan/input manual QR untuk keluar.
- [ ] Pastikan status booking berubah `completed`.
- [ ] Pastikan slot kembali available setelah keluar.

### Midtrans Sandbox

- [ ] Tekan Bayar melalui Midtrans.
- [ ] Pastikan halaman Snap terbuka.
- [ ] Selesaikan pembayaran sandbox.
- [ ] Pastikan webhook mengubah `payments.status` menjadi `paid`.
- [ ] Pastikan `bookings.status` menjadi `paid`.
- [ ] Pastikan app kembali ke tiket melalui deep link
  `parkircepat://payment-finish`.

## Yang Belum Bisa Dinyatakan Lulus Dari Otomatis Saja

- Midtrans settlement end-to-end dan callback terlambat.
- Realtime penjaga pada dua akun/perangkat berbeda.
- Scan kamera asli, karena perlu izin kamera/perangkat.
- Push notification HP, karena Firebase config belum production penuh.
- GPS jarak/ETA, karena saat ini masih demo/fixed.
- Build release APK, karena audit sebelumnya mencatat Gradle/JVM crash.

## Kesimpulan

Kode alur utama sudah konsisten memakai Supabase/RPC untuk titik sensitif:
booking, payment, scan, tunai, dan receipt. Hasil otomatis lulus, tetapi alur
end-to-end belum boleh dianggap production penuh sampai checklist manual live di
atas selesai, terutama Midtrans webhook, scan penjaga, dan realtime lintas akun.
