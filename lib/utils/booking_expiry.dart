// lib/utils/booking_expiry.dart
//
// Helper untuk menentukan apakah sebuah booking reservasi sudah kadaluarsa.
// Digunakan di sisi klien untuk menampilkan status "kadaluarsa" dan
// menyembunyikan tombol masuk. Sumber kebenaran tetap di server (RPC).
//
// Aturan kadaluarsa (sama dengan yang dipakai RPC create_booking):
//   expiry = entryTime + durationHours + graceMinutes
//   graceMinutes default 30 menit.

import '../models/app_models.dart';

class BookingExpiry {
  const BookingExpiry._();

  /// Mengembalikan DateTime kadaluarsa untuk booking [b].
  static DateTime expiresAt(Booking b, {int graceMinutes = 30}) {
    return b.entryTime.add(
      Duration(hours: b.durationHours, minutes: graceMinutes),
    );
  }

  /// True jika [now] sudah melewati masa kadaluarsa booking.
  static bool isExpired(
    Booking b, {
    DateTime? now,
    int graceMinutes = 30,
  }) {
    final expiry = expiresAt(b, graceMinutes: graceMinutes);
    final reference = now ?? DateTime.now();
    return reference.isAfter(expiry);
  }

  /// Sisa waktu sebelum kadaluarsa. Nol jika sudah lewat.
  static Duration remaining(
    Booking b, {
    DateTime? now,
    int graceMinutes = 30,
  }) {
    final expiry = expiresAt(b, graceMinutes: graceMinutes);
    final reference = now ?? DateTime.now();
    final diff = expiry.difference(reference);
    return diff.isNegative ? Duration.zero : diff;
  }
}
