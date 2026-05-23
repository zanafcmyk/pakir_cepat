# Product Requirements Document

## 1. Ringkasan Produk

`Parkir Cepat` adalah aplikasi smart parking mobile untuk membantu pengguna menemukan, memesan, membayar, dan mengelola parkir secara cepat. Aplikasi juga menyediakan mode admin untuk operator lahan parkir agar dapat memantau transaksi, kendaraan, dan kapasitas slot secara realtime.

Fokus versi ini adalah:

- pengalaman mobile modern, premium, dan ringan
- flow end-to-end yang mudah diuji
- fondasi produk yang siap dikembangkan ke backend production

## 2. Tujuan Produk

### Tujuan bisnis

- meningkatkan okupansi lahan parkir
- mengurangi antrean masuk dan keluar
- mempercepat pembayaran parkir
- memberi visibilitas operasional bagi penyedia parkir

### Tujuan pengguna

- menemukan parkir terdekat dengan cepat
- mengetahui ketersediaan slot sebelum datang
- melakukan booking dan pembayaran digital dengan mudah
- menyimpan tiket digital QR yang praktis

### Tujuan admin

- memantau kendaraan masuk dan keluar
- melihat status pembayaran dan kapasitas slot
- mengelola lahan, slot, dan laporan transaksi

## 3. Persona

### Persona 1: Customer / Pengguna

- pekerja kantoran, pengunjung mall, atau pengemudi harian
- butuh parkir cepat dan minim antre
- mengutamakan kepastian slot, navigasi, dan pembayaran digital

### Persona 2: Penyedia Parkir / Admin

- operator gedung, mall, area komersial, atau pengelola parkir
- membutuhkan dashboard operasional yang rapi
- fokus pada monitoring kendaraan, pendapatan, dan utilisasi slot

## 4. Desain dan Brand Direction

- light mode only
- warna utama: putih, biru modern, hijau emerald, abu muda
- rounded card modern
- soft shadow
- banyak whitespace
- layout clean, premium, dan profesional
- font modern seperti Poppins
- bottom navigation modern
- nuansa visual gabungan Google Maps, Gojek, Grab, dan smart city parking

## 5. Scope Fitur

### 5.1 Autentikasi

- Splash Screen
- Onboarding 3 halaman
- Login
- Register
- Forgot Password
- Delete Account

### 5.2 Customer

- Home Dashboard
- Map Lokasi Parkir
- Detail Lokasi Parkir
- Tambah Kendaraan
- Booking Parkir
- Tiket Digital
- Pembayaran
- Riwayat Parkir
- Notifikasi Pengguna
- Profil Pengguna

### 5.3 Admin

- Dashboard Admin
- Map Monitoring Area Parkir
- Tambah Lahan Parkir
- Monitoring Kendaraan
- Scan QR Kendaraan
- Detail Transaksi
- Cetak Nota Parkir
- Statistik dan Laporan
- Kelola Slot Parkir
- Notifikasi Admin
- Profil Admin

## 6. User Flow Utama

### 6.1 Flow customer

1. Pengguna membuka aplikasi
2. Splash dan onboarding ditampilkan
3. Pengguna login atau register
4. Pengguna melihat dashboard dan daftar parkir terdekat
5. Pengguna membuka map atau detail lokasi
6. Pengguna menambahkan kendaraan jika perlu
7. Pengguna memilih slot dan waktu masuk
8. Pengguna mengonfirmasi booking
9. Pengguna menerima tiket QR digital
10. Pengguna menyelesaikan pembayaran
11. Riwayat dan notifikasi diperbarui

### 6.2 Flow admin

1. Admin login
2. Admin membuka dashboard operasional
3. Admin memantau statistik, transaksi, dan kapasitas
4. Admin menambah lahan parkir atau mengelola slot
5. Admin memverifikasi QR kendaraan
6. Admin mengonfirmasi kendaraan keluar
7. Dashboard dan notifikasi diperbarui

## 7. Kebutuhan Fungsional

### 7.1 Customer

- sistem harus menampilkan daftar lokasi parkir dan status ketersediaan
- sistem harus mengizinkan pengguna memilih lokasi parkir
- sistem harus mengizinkan pengguna menambahkan data kendaraan
- sistem harus mengizinkan pengguna memilih slot tersedia
- sistem harus menghitung estimasi biaya berdasarkan tarif dan durasi
- sistem harus membuat tiket digital setelah booking
- sistem harus mengubah status pembayaran setelah bayar
- sistem harus menyimpan riwayat booking dan transaksi
- sistem harus menampilkan notifikasi booking, pembayaran, dan verifikasi

### 7.2 Admin

- sistem harus menampilkan statistik operasional ringkas
- sistem harus menampilkan monitoring kendaraan dan transaksi
- sistem harus mengizinkan penambahan lahan parkir
- sistem harus mengizinkan pengelolaan status slot
- sistem harus menampilkan detail transaksi
- sistem harus menampilkan preview nota parkir
- sistem harus memverifikasi tiket aktif melalui QR flow
- sistem harus mengembalikan slot menjadi tersedia saat kendaraan keluar

## 8. Kebutuhan Non-Fungsional

- responsive untuk Android dan iOS
- performa UI halus dan modern
- desain bersih dan mudah dipahami
- navigasi sederhana dan konsisten
- struktur kode mudah dikembangkan ke backend production

## 9. Definisi MVP Versi Saat Ini

Versi yang sudah diimplementasikan dalam repo ini adalah `functional prototype`:

- semua halaman utama tersedia
- flow customer dan admin dapat dijalankan dari ujung ke ujung
- data dikelola lewat state lokal in-memory
- komponen visual reusable sudah tersedia
- QR ticket, pembayaran, dan kelola slot sudah punya perilaku aplikasi

## 10. Yang Belum Masuk Production Scope

Item berikut belum dihubungkan ke layanan nyata:

- autentikasi backend
- login Google asli
- OTP service
- SDK map production
- kamera scanner QR asli
- payment gateway real
- database dan sinkronisasi server
- push notification production
- storage upload foto lahan

## 11. Asumsi Teknis Versi Ini

- framework: Flutter
- state management: Riverpod
- routing: GoRouter
- chart: fl_chart
- QR UI: qr_flutter
- seluruh fitur disimulasikan dengan local state agar mudah diuji

## 12. Rencana Fase Lanjutan

### Fase 2

- integrasi backend auth dan database
- integrasi map SDK
- integrasi pembayaran nyata
- integrasi scanner kamera
- persistence akun, kendaraan, tiket, transaksi

### Fase 3

- multi-branch admin dengan role lebih detail
- laporan export PDF/Excel
- smart recommendation berbasis okupansi dan lokasi
- push notification dan live updates via websocket

## 13. Kriteria Sukses

- pengguna dapat menyelesaikan flow booking sampai pembayaran tanpa kebingungan
- admin dapat memantau slot dan transaksi dari dashboard
- semua halaman utama dapat dinavigasi tanpa error
- aplikasi lolos `flutter analyze` dan `flutter test`
