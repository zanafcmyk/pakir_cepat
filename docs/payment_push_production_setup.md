# Payment Gateway dan Push Notification Production

Dokumen ini menjelaskan langkah setelah kode siap. Jangan taruh secret di Flutter.

## Payment Gateway Midtrans

Kode yang sudah disiapkan:

- `supabase/functions/create-midtrans-payment`
- `supabase/functions/midtrans-webhook`
- `lib/services/supabase_payment_service.dart`
- `lib/app.dart` bagian `PaymentScreen`

Secret Supabase yang dibutuhkan:

- `MIDTRANS_SERVER_KEY`
- `MIDTRANS_IS_PRODUCTION`
- `APP_PAYMENT_FINISH_URL` opsional
- `SERVICE_ROLE_KEY`

Function yang perlu dideploy:

```bash
supabase functions deploy create-midtrans-payment
supabase functions deploy midtrans-webhook --no-verify-jwt
```

Webhook URL yang dipasang di dashboard Midtrans:

```text
https://<project-ref>.supabase.co/functions/v1/midtrans-webhook
```

Alur production:

1. Customer klik bayar.
2. Flutter memanggil `create-midtrans-payment`.
3. Edge Function membuat transaksi Snap Midtrans dan mengembalikan `redirectUrl`.
4. Flutter membuka halaman Midtrans.
5. Midtrans memanggil `midtrans-webhook`.
6. Webhook mengubah `payments.status` dan `bookings.status` menjadi `paid`.

## Push Notification FCM

Kode yang sudah disiapkan:

- `docs/supabase_push_notifications.sql`
- `lib/services/supabase_push_notification_service.dart`
- `supabase/functions/send-push-notification`

Secret Supabase yang dibutuhkan:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_SERVICE_ACCOUNT_JSON`
- `PUSH_FUNCTION_SECRET`
- `SERVICE_ROLE_KEY`

SQL yang perlu dijalankan:

```text
docs/supabase_push_notifications.sql
```

Function yang perlu dideploy:

```bash
supabase functions deploy send-push-notification
```

Yang masih perlu sebelum push notification benar-benar muncul di HP:

1. Buat project Firebase.
2. Tambahkan app Android/iOS.
3. Pasang file Firebase ke project Flutter.
4. Tambahkan package Firebase di Flutter.
5. Minta permission notifikasi.
6. Ambil FCM token dan simpan ke `device_push_tokens`.
7. Panggil `send-push-notification` saat ada event booking/payment/komplain.
