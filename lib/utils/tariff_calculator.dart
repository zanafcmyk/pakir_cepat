// lib/utils/tariff_calculator.dart
//
// Pure-function helper untuk menghitung estimasi biaya parkir di sisi klien.
// TIDAK menggantikan RPC Supabase (server tetap sumber kebenaran), tetapi
// dipakai untuk preview harga sebelum user konfirmasi booking dan untuk
// pengujian unit.
//
// Aturan tarif:
//   - hourly : cost = baseRate * durationHours  (minimal 1 jam)
//   - flat   : cost = baseRate * 1               (biaya tetap, durationHours diabaikan)
//   - daily  : cost = baseRate * ceil(durationHours / 24)
//
// baseRate dipilih dari motorRate / carRate / truckRate sesuai VehicleKind.
// Jika rate untuk jenis kendaraan tersebut null, fallback ke pricePerHour.

import '../models/app_models.dart';

class TariffCalculator {
  const TariffCalculator._();

  /// Mengambil base rate yang berlaku untuk [kind] pada [lot].
  /// Urutan fallback: rate spesifik -> pricePerHour.
  static int baseRateFor(ParkingLot lot, VehicleKind kind) {
    switch (kind) {
      case VehicleKind.motor:
        return lot.motorRate ?? lot.pricePerHour;
      case VehicleKind.mobil:
        return lot.carRate ?? lot.pricePerHour;
      case VehicleKind.truk:
        return lot.truckRate ?? lot.pricePerHour;
    }
  }

  /// Menghitung estimasi biaya berdasarkan jenis tarif.
  /// Mengembalikan 0 untuk input non-positif (tidak melempar exception).
  static int estimateCost({
    required ParkingLot lot,
    required VehicleKind kind,
    required int durationHours,
  }) {
    if (durationHours <= 0) return 0;
    final rate = baseRateFor(lot, kind);
    switch (lot.tariffType) {
      case ParkingTariffType.hourly:
        return rate * durationHours;
      case ParkingTariffType.flat:
        return rate;
      case ParkingTariffType.daily:
        final days = (durationHours + 23) ~/ 24;
        return rate * days;
    }
  }
}
