# Tasklist Sistem Role dan Kolaborasi

## Status Implementasi

- [x] Update enum `AccountMode` menjadi 4 role.
- [x] Pisahkan model utama ke `lib/models/app_models.dart`.
- [x] Tambahkan pilihan 4 role di login/register.
- [x] Tambahkan route `/super-admin/*`, `/provider/*`, `/guard/*`, dan `/customer/*`.
- [x] Tambahkan screen Super Admin.
- [x] Tambahkan screen Penjaga Parkir.
- [x] Tambahkan fitur Penyedia Parkir untuk membuat akun Penjaga Parkir.
- [x] Batasi data lokasi Penjaga Parkir berdasarkan assignment dari Penyedia.
- [x] Pastikan flow customer tetap ada.
- [x] Jalankan `flutter analyze`.

## Task Lanjutan

- [ ] Pecah `lib/app.dart` ke `lib/features/customer/`, `lib/features/provider/`, `lib/features/guard/`, dan `lib/features/super_admin/`.
- [ ] Tambahkan persistence akun dan assignment penjaga ke backend.
- [ ] Tambahkan approval Super Admin untuk penyedia, pelanggan, dan penjaga.
- [ ] Tambahkan sistem komplain production.
- [ ] Tambahkan rating/review production.
- [ ] Tambahkan testing widget per role.
- [ ] Tambahkan guard route berbasis role saat backend auth tersedia.

## Aturan Kerja Tim

- Setiap perubahan fitur dibuat di branch feature terpisah.
- Setiap perubahan harus dibuat commit.
- Sebelum teman memperbarui atau membuat fitur baru, beri tahu zanafcmyk agar branch dan scope tidak bentrok.
- Sebelum merge, jalankan `flutter analyze`.
- Gunakan PR untuk masuk ke `development`.
- `development` menjadi tempat integrasi tim.
- `master` hanya untuk versi stabil.

## Pembagian Awal

- zanafcmyk: owner, inviter, reviewer, final merge.
- ethunder243-droid: fitur Penjaga Parkir, scan QR, verifikasi masuk/keluar.
- maulana-bintang: fitur Penyedia Parkir, lokasi, tarif, akun penjaga.
