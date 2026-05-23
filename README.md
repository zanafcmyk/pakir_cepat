# Parkir Cepat

Parkir Cepat adalah prototipe aplikasi mobile smart parking berbasis Flutter dengan dua mode:

- `Pengguna / Customer`
- `Penyedia Parkir / Admin`

Aplikasi ini memakai light mode premium dengan gaya visual modern yang terinspirasi dari Google Maps, Gojek, Grab, dan sistem smart city parking.

## Yang Sudah Dibangun

- Splash screen dan onboarding 3 halaman
- Login, register, forgot password, delete account
- Dashboard customer, map lokasi, detail parkir, tambah kendaraan, booking, tiket QR, pembayaran, riwayat, notifikasi, profil
- Dashboard admin, map monitoring, tambah lahan, monitoring kendaraan, scan QR, detail transaksi, cetak nota, statistik, kelola slot, notifikasi, profil
- Bottom navigation untuk customer dan admin
- State aplikasi in-memory untuk demo interaksi fitur tanpa backend
- UI premium light mode dengan rounded cards, soft shadows, dan komponen reusable

## Menjalankan Proyek

```bash
flutter pub get
flutter run
```

## Verifikasi

```bash
flutter analyze
flutter test
```

## Catatan Implementasi

Versi saat ini adalah prototype fungsional lokal:

- Booking, pembayaran, scan QR, tambah kendaraan, dan kelola slot sudah berjalan melalui state lokal
- Peta dibuat sebagai UI map interaktif kustom, belum memakai SDK map asli
- Scanner QR, login Google, OTP, pembayaran gateway, dan backend persistence belum terhubung ke layanan production

## Dokumen Produk

PRD tersedia di [docs/PRD.md](docs/PRD.md).
