# PRD Sistem Role Parkir Cepat

## Ringkasan

Parkir Cepat memakai 4 role utama: Super Admin, Penyedia Parkir, Penjaga Parkir, dan Pelanggan. Tujuan perubahan ini adalah memisahkan akses operasional, approval, monitoring, dan flow pelanggan tanpa merusak booking customer yang sudah ada.

## Role dan Kewenangan

### 1. Super Admin

- Memantau seluruh pengguna aplikasi.
- Mengelola pelanggan, penyedia parkir, dan penjaga parkir.
- Memverifikasi penyedia parkir, pelanggan, dan penjaga.
- Memantau data penting dari penyedia tempat, penjaga, dan pelanggan.
- Melihat semua transaksi.
- Melihat laporan seluruh lokasi parkir.
- Menangani komplain pengguna aplikasi.
- Menonaktifkan akun bermasalah.

### 2. Penyedia Parkir

- Membuat dan mengelola lokasi parkir.
- Mendaftarkan lahan parkir dan data lahan.
- Mengelola slot parkir.
- Mengatur tarif parkir berdasarkan durasi dan aturan harga.
- Melihat transaksi dan pendapatan.
- Membuat akun penjaga parkir.
- Mengatur hak akses penjaga parkir.
- Menyetujui atau menolak aturan dari admin jika sistem approval diaktifkan.

### 3. Penjaga Parkir

- Login memakai akun yang dibuat Penyedia Parkir.
- Scan QR tiket pelanggan.
- Verifikasi kendaraan masuk.
- Verifikasi kendaraan keluar.
- Update status slot parkir.
- Melihat kendaraan aktif.
- Melihat status pembayaran.
- Konfirmasi pembayaran tunai.
- Melihat slot tersedia dan penuh.
- Hanya mengakses lokasi parkir milik Penyedia Parkir yang membuat akunnya.

### 4. Pelanggan

- Register dan login.
- Menambah kendaraan secara manual berdasarkan jenis kendaraan dan nomor plat.
- Mencari lokasi parkir.
- Booking tiket parkir.
- Melakukan pembayaran.
- Melihat tiket QR.
- Melihat riwayat parkir.
- Mendapat notifikasi.
- Memberi rating dan review.

## Scope Implementasi Flutter

- `AccountMode` memakai nilai `superAdmin`, `provider`, `parkingGuard`, dan `customer`.
- Login dan register menampilkan pilihan 4 role.
- Dashboard berbeda tersedia untuk setiap role.
- Route role tersedia untuk `/super-admin/*`, `/provider/*`, `/guard/*`, dan `/customer/*`.
- Screen Super Admin tersedia untuk dashboard, pengguna, laporan, dan komplain.
- Screen Penjaga Parkir tersedia untuk dashboard, scan QR, kendaraan aktif, slot, dan profil.
- Penyedia Parkir dapat membuat akun Penjaga Parkir dan mengatur akses lokasi serta permission.
- Penjaga Parkir difilter hanya ke lokasi yang ditugaskan oleh Penyedia Parkir.
- Flow customer tetap dipertahankan.

## Catatan Teknis

- Model role dan entity utama dipisah ke `lib/models/app_models.dart`.
- Data masih in-memory untuk prototype.
- Route `/admin/*` lama masih dipertahankan sebagai alias transisi agar navigasi lama tidak langsung rusak.
- Refactor screen berikutnya direkomendasikan ke folder `lib/features/` per role.

## Kriteria Sukses

- `flutter analyze` tanpa error.
- Customer tetap bisa booking sampai pembayaran.
- Penyedia bisa membuat akun penjaga.
- Penjaga hanya melihat lokasi yang assigned.
- Super Admin bisa membuka dashboard monitoring lintas role.
