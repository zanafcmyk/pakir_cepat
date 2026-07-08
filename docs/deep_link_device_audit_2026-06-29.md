# Audit Deep Link Production Perangkat Asli - 29 Juni 2026

## Status

Belum bisa ditutup sebagai lulus production penuh. Audit Android device sudah
lulus di level intent filter dan cold start ADB, tetapi alur reset password dari
email Supabase dan payment finish dari Midtrans masih perlu diuji dengan
konfigurasi production/sandbox yang valid.

Update 8 Juli 2026:

- Android device terdeteksi: Vivo V2333 (`10DE6N00N600074`), Android 16 API 36.
- Debug APK berhasil terpasang sebagai `com.ti23a4.parkircepat`.
- Android package manager membaca intent filter custom scheme `parkircepat://` untuk:
  - `parkircepat://reset-password`
  - `parkircepat://payment-finish`
  - `parkircepat://auth/callback`
- Uji ADB cold start untuk ketiga link tersebut menghasilkan `Status: ok` dan membuka `com.ti23a4.parkircepat/.MainActivity`.
- Tidak ditemukan `FATAL EXCEPTION` pada logcat pendek setelah uji link.
- Catatan: build audit ini dipasang dengan Supabase key placeholder, sehingga audit alur production asli belum ditutup. Masih perlu uji reset password dari email Supabase dan payment finish dari Midtrans dengan `SUPABASE_URL` serta `SUPABASE_PUBLISHABLE_KEY` production/sandbox yang valid.

Update ulang 8 Juli 2026 dengan Supabase publishable key valid:

- Debug APK di-build ulang dengan `SUPABASE_URL=https://wdtjrzynjygkmpmhiffw.supabase.co` dan Supabase publishable key valid, lalu berhasil di-install ulang ke Vivo V2333.
- Uji ADB cold start ulang untuk `parkircepat://reset-password`, `parkircepat://payment-finish`, dan `parkircepat://auth/callback` semuanya menghasilkan `Status: ok`.
- Ketiga link membuka `com.ti23a4.parkircepat/.MainActivity` sebagai foreground app.
- Status window saat audit: `mShowingDream=false` dan `mDreamingLockscreen=false`.
- Logcat pendek setelah audit tidak menunjukkan `FATAL EXCEPTION` atau `Invalid API key` dari aplikasi.
- Audit Android via ADB lulus. Penutupan production penuh masih menunggu uji alur asli dari email reset password Supabase dan callback selesai pembayaran Midtrans.

Hasil cek perangkat 29 Juni 2026:

- `flutter devices`: hanya mendeteksi Windows, Chrome, dan Edge.
- `C:\Users\hp\AppData\Local\Android\sdk\platform-tools\adb.exe devices`: tidak ada device terhubung.
- `flutter doctor -v`: Android toolchain sehat, tetapi connected device hanya desktop/web. iOS tidak dapat diuji dari mesin Windows ini.

## Audit Konfigurasi yang Sudah Lulus

- Android `AndroidManifest.xml` sudah mendaftarkan custom scheme `parkircepat://`.
- Android sudah punya intent filter untuk:
  - `parkircepat://reset-password`
  - `parkircepat://payment-finish`
  - `parkircepat://auth/callback`
- iOS `Info.plist` sudah punya `CFBundleURLTypes` dengan scheme `parkircepat`.
- Flutter memakai `app_links` dan membaca initial link serta stream link saat app sudah terbuka.
- Handler Flutter mengenali:
  - `parkircepat://reset-password`
  - `parkircepat://auth/reset-password`
  - `parkircepat://auth/callback`
  - `parkircepat://payment-finish`
  - `parkircepat://payment/finish`
- Forgot password memakai redirect `parkircepat://reset-password`.
- Midtrans finish/callback URL terdokumentasi sebagai `parkircepat://payment-finish`.

## Langkah Uji Android Saat HP Tersambung

1. Aktifkan Developer Options dan USB debugging di HP.
2. Sambungkan HP dengan kabel USB.
3. Pastikan device muncul:

```powershell
flutter devices
& 'C:\Users\hp\AppData\Local\Android\sdk\platform-tools\adb.exe' devices
```

4. Install/jalankan app ke device:

```powershell
flutter run -d <device-id>
```

5. Uji reset password deep link:

```powershell
& 'C:\Users\hp\AppData\Local\Android\sdk\platform-tools\adb.exe' shell am start -a android.intent.action.VIEW -d "parkircepat://reset-password" com.ti23a4.parkircepat
```

Ekspektasi: aplikasi terbuka ke halaman reset password/set password baru.

6. Uji payment finish deep link:

```powershell
& 'C:\Users\hp\AppData\Local\Android\sdk\platform-tools\adb.exe' shell am start -a android.intent.action.VIEW -d "parkircepat://payment-finish" com.ti23a4.parkircepat
```

Ekspektasi:

- Jika sudah login dan ada booking aktif berstatus bayar/aktif, aplikasi menuju tiket.
- Jika sudah login tetapi booking belum lunas, aplikasi menuju pembayaran.
- Jika belum login, aplikasi meminta login.

7. Uji auth callback:

```powershell
& 'C:\Users\hp\AppData\Local\Android\sdk\platform-tools\adb.exe' shell am start -a android.intent.action.VIEW -d "parkircepat://auth/callback" com.ti23a4.parkircepat
```

Ekspektasi: link tidak crash; jika session Supabase valid, app memulihkan akun customer dan menuju halaman sesuai role.

## Langkah Uji iOS

iOS perlu diuji dari macOS/Xcode dengan iPhone asli karena mesin audit ini Windows.

Ekspektasi sama:

- `parkircepat://reset-password` membuka halaman reset password.
- `parkircepat://payment-finish` membuka tiket/pembayaran sesuai status booking.
- `parkircepat://auth/callback` tidak crash dan memproses session Supabase jika payload valid.

## Kesimpulan

Konfigurasi kode dan manifest/plist sudah siap untuk audit production deep link. Item checklist belum boleh ditandai selesai sampai minimal satu perangkat Android asli berhasil menjalankan skenario reset password dan payment finish, serta iOS diuji dari mesin macOS/Xcode bila target release mencakup iPhone.
