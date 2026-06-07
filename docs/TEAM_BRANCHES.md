# Branches Tim Parkir Cepat

## Anggota

- zanafcmyk: inviter, owner, reviewer utama.
- ethunder243-droid: collaborator fitur penjaga.
- maulana-bintang: collaborator fitur penyedia.

## Branch Utama

- `master`: versi stabil.
- `development`: integrasi aktif tim sebelum masuk `master`.
- `codex/parkir-cepat-23mei-2157`: branch kerja saat ini dari versi Parkir Cepat 23 Mei 2026 21:57.

## Branch Development Tim

- `development`: integrasi umum.
- `feature/zanafcmyk-super-admin`: fitur Super Admin, approval, komplain, laporan global.
- `feature/ethunder243-droid-parking-guard`: fitur Penjaga Parkir, scan QR, kendaraan aktif, pembayaran tunai.
- `feature/maulana-bintang-provider`: fitur Penyedia Parkir, lokasi, tarif, slot, akun penjaga.
- `feature/customer-flow-safe`: perlindungan flow pelanggan agar booking dan pembayaran tidak rusak.

## Branch Graph

```mermaid
gitGraph
  commit id: "initial"
  branch development
  checkout development
  commit id: "role-base"
  branch feature/zanafcmyk-super-admin
  checkout feature/zanafcmyk-super-admin
  commit id: "super-admin"
  checkout development
  branch feature/ethunder243-droid-parking-guard
  checkout feature/ethunder243-droid-parking-guard
  commit id: "parking-guard"
  checkout development
  branch feature/maulana-bintang-provider
  checkout feature/maulana-bintang-provider
  commit id: "provider"
  checkout development
  merge feature/zanafcmyk-super-admin
  merge feature/ethunder243-droid-parking-guard
  merge feature/maulana-bintang-provider
  checkout master
  merge development
```

## Flow Saat Teman Mau Update atau Buat Fitur Baru

1. Beri tahu zanafcmyk dulu tentang fitur yang akan dikerjakan.
2. Ambil update terbaru dari `development`.
3. Buat branch baru dengan format `feature/<username>-<nama-fitur>`.
4. Commit setiap perubahan kecil yang sudah jalan.
5. Jalankan `flutter analyze`.
6. Buat pull request ke `development`.
7. Tunggu review dari zanafcmyk sebelum merge.
