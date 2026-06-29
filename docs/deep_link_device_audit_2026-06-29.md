# Audit Deep Link Production Perangkat Asli - 29 Juni 2026

## Status

Belum bisa ditutup sebagai lulus perangkat asli karena tidak ada HP Android/iOS yang terdeteksi di mesin audit.

Hasil cek perangkat:

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
