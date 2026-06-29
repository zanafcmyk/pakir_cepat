import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_cepat/models/app_models.dart';
import 'package:parkir_cepat/utils/tariff_calculator.dart';

ParkingLot _makeLot({
  int pricePerHour = 10000,
  ParkingTariffType tariffType = ParkingTariffType.hourly,
  int? motorRate,
  int? carRate,
  int? truckRate,
}) {
  return ParkingLot(
    id: 'lot-1',
    name: 'Test Lot',
    address: 'Test Address',
    pricePerHour: pricePerHour,
    availableSlots: 10,
    totalSlots: 50,
    distanceKm: 0.5,
    etaMinutes: 3,
    openHours: '24 Jam',
    rating: 4.5,
    accent: Colors.blue,
    mapEmbedUrl: '',
    latitude: 0,
    longitude: 0,
    tariffType: tariffType,
    motorRate: motorRate,
    carRate: carRate,
    truckRate: truckRate,
  );
}

void main() {
  group('TariffCalculator.baseRateFor', () {
    test('mengembalikan rate spesifik untuk motor/mobil/truk', () {
      final lot = _makeLot(
        pricePerHour: 10000,
        motorRate: 5000,
        carRate: 12000,
        truckRate: 20000,
      );
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.motor), 5000);
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.mobil), 12000);
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.truk), 20000);
    });

    test('fallback ke pricePerHour jika rate spesifik null', () {
      final lot = _makeLot(pricePerHour: 10000);
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.motor), 10000);
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.mobil), 10000);
      expect(TariffCalculator.baseRateFor(lot, VehicleKind.truk), 10000);
    });
  });

  group('TariffCalculator.estimateCost - hourly', () {
    test('biaya = rate * jam', () {
      final lot = _makeLot(
        tariffType: ParkingTariffType.hourly,
        carRate: 12000,
      );
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 3,
        ),
        36000,
      );
    });

    test('minimal 1 jam (0 jam -> 0 karena guard non-positif)', () {
      final lot = _makeLot(tariffType: ParkingTariffType.hourly);
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.motor,
          durationHours: 0,
        ),
        0,
      );
    });
  });

  group('TariffCalculator.estimateCost - flat', () {
    test('biaya tetap = 1x rate, durasi diabaikan', () {
      final lot = _makeLot(tariffType: ParkingTariffType.flat, carRate: 15000);
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 1,
        ),
        15000,
      );
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 24,
        ),
        15000,
      );
    });
  });

  group('TariffCalculator.estimateCost - daily', () {
    test('pembulatan ke atas per 24 jam', () {
      final lot = _makeLot(tariffType: ParkingTariffType.daily, carRate: 50000);
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 1,
        ),
        50000, // 1..24 jam => 1 hari
      );
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 24,
        ),
        50000, // tepat 1 hari
      );
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 25,
        ),
        100000, // 2 hari
      );
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: 48,
        ),
        100000, // 2 hari
      );
    });
  });

  group('TariffCalculator.estimateCost - input non-positif', () {
    test('mengembalikan 0 untuk duration <= 0', () {
      final lot = _makeLot(tariffType: ParkingTariffType.hourly);
      expect(
        TariffCalculator.estimateCost(
          lot: lot,
          kind: VehicleKind.mobil,
          durationHours: -1,
        ),
        0,
      );
    });
  });
}
