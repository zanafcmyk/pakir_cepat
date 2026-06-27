import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_cepat/models/app_models.dart';
import 'package:parkir_cepat/utils/booking_expiry.dart';

Booking _booking({DateTime? entryTime, int durationHours = 1}) {
  return Booking(
    parkingLotId: 'lot-1',
    ticketNumber: 'TKT-001',
    slotCode: 'A-01',
    locationName: 'Test Lot',
    plateNumber: 'B1234XYZ',
    vehicleLabel: 'Mobil',
    entryTime: entryTime ?? DateTime(2026, 6, 26, 10, 0),
    durationHours: durationHours,
    estimatedCost: 12000,
    paymentMethod: PaymentMethod.qris,
    status: BookingStatus.paid,
  );
}

void main() {
  group('BookingExpiry.expiresAt', () {
    test('entry + duration + grace 30 menit', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 2,
      );
      final expected = DateTime(2026, 6, 26, 12, 30);
      expect(BookingExpiry.expiresAt(b), expected);
    });

    test('grace 0 menit', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 1,
      );
      expect(
        BookingExpiry.expiresAt(b, graceMinutes: 0),
        DateTime(2026, 6, 26, 11, 0),
      );
    });
  });

  group('BookingExpiry.isExpired', () {
    test('sebelum expiry -> false', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 1,
      );
      final now = DateTime(2026, 6, 26, 10, 30);
      expect(BookingExpiry.isExpired(b, now: now), isFalse);
    });

    test('tepat pada expiry -> false (isAfter strict)', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 1,
      );
      final now = DateTime(2026, 6, 26, 11, 30); // pas 1h30m
      expect(BookingExpiry.isExpired(b, now: now), isFalse);
    });

    test('sesudah expiry -> true', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 1,
      );
      final now = DateTime(2026, 6, 26, 11, 31);
      expect(BookingExpiry.isExpired(b, now: now), isTrue);
    });

    test('jauh sesudah expiry -> true', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 2,
      );
      final now = DateTime(2026, 6, 27, 10, 0);
      expect(BookingExpiry.isExpired(b, now: now), isTrue);
    });
  });

  group('BookingExpiry.remaining', () {
    test('sebelum expiry -> sisa positif', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 2,
      );
      final now = DateTime(2026, 6, 26, 11, 0);
      expect(
        BookingExpiry.remaining(b, now: now),
        const Duration(hours: 1, minutes: 30),
      );
    });

    test('sesudah expiry -> Duration.zero (bukan negatif)', () {
      final b = _booking(
        entryTime: DateTime(2026, 6, 26, 10, 0),
        durationHours: 1,
      );
      final now = DateTime(2026, 6, 27, 0, 0);
      expect(BookingExpiry.remaining(b, now: now), Duration.zero);
    });
  });
}
