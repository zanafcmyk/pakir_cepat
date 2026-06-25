# Midtrans Audit - 25 Juni 2026

Audit ini mencakup alur Midtrans sandbox/production untuk Parkir Cepat.

## Hasil Verifikasi CLI

- Supabase project: `wdtjrzynjygkmpmhiffw`.
- Function `create-midtrans-payment`: ACTIVE, version 10.
- Function `midtrans-webhook`: ACTIVE, version 10.
- `midtrans-webhook` sudah dideploy ulang dengan `--no-verify-jwt`.
- `deno check supabase/functions/create-midtrans-payment/index.ts`: lulus.
- `deno check supabase/functions/midtrans-webhook/index.ts`: lulus.

## Hasil Audit Kode

### create-midtrans-payment

- Memvalidasi Authorization Supabase user sebelum membuat payment.
- Memastikan user adalah customer pemilik booking.
- Menolak booking yang bukan `pending_payment`, `paid`, atau `active`.
- Menolak booking `pending_payment` yang sudah melewati 15 menit.
- Menghitung nominal dari `estimated_cost - paid_amount`, bukan dari Flutter.
- Membuat row `payments` status `pending` dengan `provider_reference = orderId`.
- Mengirim transaksi ke Snap sandbox/production berdasarkan `MIDTRANS_IS_PRODUCTION`.
- Mengirim callback finish ke `APP_PAYMENT_FINISH_URL` jika secret tersedia.
- Jika request Snap gagal, payment ditandai `failed`.

### midtrans-webhook

- Memvalidasi signature Midtrans memakai SHA-512:
  `order_id + status_code + gross_amount + MIDTRANS_SERVER_KEY`.
- Mencari payment memakai `provider_reference`.
- Mapping status:
  - `settlement` dan `capture + accept` -> `paid`
  - `deny`, `cancel`, `expire`, `failure` -> `failed`
  - `refund`, `partial_refund` -> `refunded`
  - lainnya -> `pending`
- Jika payment sukses, booking `pending_payment` menjadi `paid`, `final_cost`
  diisi total pembayaran lunas, dan receipt dibuat/di-repair.
- Jika payment gagal saat booking masih `pending_payment`, booking dibatalkan,
  slot dilepas, activity log dibuat, dan customer diberi notifikasi.
- Jika pembayaran datang setelah booking `cancelled`, payment ditandai `paid`
  dan customer diberi notifikasi refund/dukungan.

## Perbaikan Yang Dilakukan Saat Audit

- Webhook sekarang idempotent terhadap callback terlambat:
  - payment yang sudah `paid` tidak bisa turun lagi menjadi `pending` atau
    `failed`;
  - payment yang sudah `refunded` tidak bisa ditimpa status non-refund.
- Patch sudah dideploy ke Supabase sebagai `midtrans-webhook` version 10.

## Yang Masih Harus Diuji Manual

- Buat booking customer baru.
- Tekan **Bayar melalui Midtrans**.
- Pastikan Snap sandbox terbuka.
- Selesaikan pembayaran sandbox sukses.
- Pastikan tabel `payments.status = paid`.
- Pastikan tabel `bookings.status = paid`.
- Pastikan row `receipts` dibuat.
- Pastikan app kembali ke tiket lewat `parkircepat://payment-finish`.
- Uji pembayaran gagal/expire dan pastikan booking menjadi `cancelled` serta
  slot kembali available.
- Uji callback ulang dari Midtrans Dashboard dan pastikan payment tidak
  downgrade dari `paid`.

## Catatan

- `supabase secrets list` tidak bisa dicek dari CLI saat audit ini karena CLI
  meminta access token. Namun function aktif dan dapat dideploy.
- Secret yang tetap wajib dipastikan di dashboard Supabase:
  - `SERVICE_ROLE_KEY`
  - `MIDTRANS_SERVER_KEY`
  - `MIDTRANS_IS_PRODUCTION`
  - `APP_PAYMENT_FINISH_URL`
- Untuk sandbox, `MIDTRANS_IS_PRODUCTION=false`.
- Untuk production sungguhan, webhook URL di Midtrans Dashboard:
  `https://wdtjrzynjygkmpmhiffw.supabase.co/functions/v1/midtrans-webhook`.
