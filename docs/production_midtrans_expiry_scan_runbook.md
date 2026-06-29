# Production SQL, Midtrans, Expiry, dan Scan Runbook

Dokumen ini dipakai untuk uji production/sandbox terakhir setelah SQL production
dijalankan. Gunakan satu project Supabase yang sama dengan aplikasi yang sedang
di-run di HP.

## 1. SQL Production Yang Harus Sudah Jalan

Jalankan di Supabase SQL Editor dengan urutan ini jika belum yakin semua patch
sudah masuk. Untuk project lama, jangan jalankan `supabase_schema.sql` ulang.

1. `docs/supabase_role_sync_rls_patch.sql`
2. `docs/supabase_booking_payment_security_patch.sql`
3. `docs/supabase_booking_extension_patch.sql`
4. `docs/supabase_guard_assignment_validation.sql`
5. `docs/supabase_secure_ticket_qr.sql`
6. `docs/supabase_booking_expiry.sql`
7. `docs/supabase_realtime_guard_operations.sql`
8. `docs/supabase_notification_triggers.sql`
9. `docs/supabase_chat_server_sync.sql`
10. `docs/supabase_production_sql_verification.sql`

Untuk demo/sandbox saja, jalankan juga:

```sql
-- docs/supabase_simulate_customer_payment.sql
```

Setelah semua patch selesai, `docs/supabase_production_sql_verification.sql`
harus menghasilkan status `OK` untuk tabel, kolom, RPC, RLS, policy, trigger,
publication realtime, storage bucket, dan cron expiry.

## 2. Edge Function Yang Harus Dideploy

Jalankan dari terminal project:

```bash
supabase functions deploy create-midtrans-payment --project-ref <project-ref>
supabase functions deploy midtrans-webhook --no-verify-jwt --project-ref <project-ref>
```

Jika sedang audit semua function:

```bash
supabase functions deploy create-guard-account --project-ref <project-ref>
supabase functions deploy send-push-notification --project-ref <project-ref>
```

Secret Supabase yang wajib dicek:

```text
SERVICE_ROLE_KEY
MIDTRANS_SERVER_KEY
MIDTRANS_IS_PRODUCTION=false
APP_PAYMENT_FINISH_URL=parkircepat://payment-finish
```

Untuk production asli nanti, ganti `MIDTRANS_IS_PRODUCTION=true` dan pakai key
production Midtrans. Sandbox boleh tetap dipakai untuk demo pembayaran.

## 3. Setting Midtrans

Di dashboard Midtrans, pastikan Payment Notification URL:

```text
https://<project-ref>.supabase.co/functions/v1/midtrans-webhook
```

Finish/callback URL:

```text
parkircepat://payment-finish
```

Jika pembayaran sukses tapi aplikasi tidak kembali otomatis, cek lagi
`APP_PAYMENT_FINISH_URL`, deploy ulang `create-midtrans-payment`, lalu buat
booking baru. Snap lama biasanya masih memakai callback lama.

## 4. Uji End-to-End Midtrans

Pakai akun customer baru atau customer bersih.

1. Buat booking baru.
2. Pilih **Bayar melalui Midtrans**.
3. Selesaikan pembayaran sandbox di Snap.
4. Tunggu callback webhook masuk.
5. Cek database:

```sql
select ticket_number, status, estimated_cost, final_cost, qr_payload
from public.bookings
where ticket_number = '<TKT-...>';

select provider, provider_reference, status, amount, paid_at
from public.payments
where booking_id = '<booking-id>'
order by created_at desc;

select receipt_number, booking_id, payment_id
from public.receipts
where booking_id = '<booking-id>';
```

Hasil yang benar:

- `bookings.status = paid`.
- `payments.status = paid`.
- `receipts` punya satu nota untuk booking tersebut.
- `bookings.qr_payload` bukan nomor tiket polos.
- Aplikasi kembali ke layar tiket atau bisa dibuka ulang dan tiket tetap muncul.

## 5. Uji Expiry Reservasi 30 Menit

Buat booking baru, jangan dibayar.

1. Pastikan booking awal:

```sql
select id, ticket_number, status, created_at, parking_slot_id
from public.bookings
where ticket_number = '<TKT-...>';
```

2. Setelah lebih dari 30 menit, cron harus menjalankan:

```sql
select public.app_expire_stale_bookings(200);
```

3. Cek hasil:

```sql
select status from public.bookings where ticket_number = '<TKT-...>';
select status from public.payments where booking_id = '<booking-id>';
select status from public.parking_slots where id = '<parking-slot-id>';
select title, message, type from public.notifications
where data->>'ticket_number' = '<TKT-...>'
order by created_at desc;
```

Hasil yang benar:

- Booking berubah menjadi `cancelled`.
- Payment pending berubah menjadi `cancelled`.
- Slot kembali `available`.
- Customer mendapat notifikasi reservasi berakhir.

Uji callback terlambat: setelah booking expired, lakukan callback/payment sukses
dari Midtrans sandbox. Hasil yang benar adalah booking tetap `cancelled`,
payment boleh tercatat `paid`, dan notifikasi `late_payment` muncul untuk proses
refund/dukungan.

## 6. Uji Scan Masuk dan Keluar

Syarat sebelum scan:

- Booking sudah `paid`.
- QR tiket tampil di aplikasi customer.
- Penjaga sudah punya assignment ke lahan yang sama lewat akun penyedia.
- SQL `docs/supabase_guard_assignment_validation.sql` dan
  `docs/supabase_realtime_guard_operations.sql` sudah dijalankan.

Langkah uji:

1. Login sebagai penjaga.
2. Scan QR tiket atau input manual nomor tiket.
3. Tekan verifikasi masuk.
4. Cek database:

```sql
select status, actual_entry_time, actual_exit_time
from public.bookings
where ticket_number = '<TKT-...>';

select status from public.parking_slots where id = '<parking-slot-id>';

select action, note
from public.parking_activity_logs
where booking_id = '<booking-id>'
order by created_at desc;
```

Hasil masuk yang benar:

- Booking menjadi `active`.
- Slot menjadi `occupied`.
- Activity log berisi aksi masuk.

Lanjut tekan konfirmasi keluar. Hasil keluar yang benar:

- Booking menjadi `completed`.
- Slot kembali `available`.
- Activity log berisi aksi keluar.

Uji negatif: login penjaga dari lahan lain lalu scan tiket yang sama. Hasil yang
benar adalah ditolak dengan pesan seperti penjaga tidak diizinkan scan tiket
untuk lahan tersebut.

## 7. Uji Tunai Operator/Penjaga

1. Customer buat booking dan pilih bayar langsung/tunai.
2. Penjaga atau operator penyedia membuka cek pembayaran.
3. Cari pakai nomor tiket atau plat.
4. Konfirmasi pembayaran tunai.
5. Cek:

```sql
select status, final_cost from public.bookings where ticket_number = '<TKT-...>';
select status, provider, amount from public.payments where booking_id = '<booking-id>';
select receipt_number from public.receipts where booking_id = '<booking-id>';
```

Hasil yang benar:

- Booking menjadi `paid`.
- Payment `cash` menjadi `paid`.
- Receipt dibuat.
- Tiket bisa discan masuk/keluar.

## 8. Template Bukti Uji

Isi tabel ini setiap kali selesai uji.

| Alur | Akun | Tiket | Order ID | Hasil DB | Hasil App | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Midtrans sukses | customer@example.com | TKT- | PC- | paid/paid/receipt ada | tiket tampil | OK/Gagal |
| Expiry 30 menit | customer@example.com | TKT- | PC- | cancelled/cancelled/slot available | notifikasi muncul | OK/Gagal |
| Callback terlambat | customer@example.com | TKT- | PC- | booking tetap cancelled | late payment notif | OK/Gagal |
| Scan masuk | guard@example.com | TKT- | - | active/occupied | berhasil masuk | OK/Gagal |
| Scan keluar | guard@example.com | TKT- | - | completed/available | berhasil keluar | OK/Gagal |
| Tunai | guard/provider | TKT- | - | paid/cash/receipt ada | tiket tampil | OK/Gagal |
