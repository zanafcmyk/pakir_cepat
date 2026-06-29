import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_cepat/models/app_models.dart';

ParkingLot _sampleLot() => ParkingLot(
  id: 'lot-1',
  name: 'Sudirman Plaza',
  address: 'Jl. Sudirman',
  pricePerHour: 12000,
  availableSlots: 36,
  totalSlots: 120,
  distanceKm: 1.2,
  etaMinutes: 4,
  openHours: '24 Jam',
  rating: 4.9,
  accent: Colors.blue,
  mapEmbedUrl: '',
  latitude: -6.2,
  longitude: 106.8,
);

void main() {
  group('ParkingLot', () {
    test('default tariffType adalah hourly', () {
      final lot = _sampleLot();
      expect(lot.tariffType, ParkingTariffType.hourly);
    });

    test('isFull true jika availableSlots <= 0', () {
      final empty = _sampleLot().copyWith(availableSlots: 0);
      final negative = _sampleLot().copyWith(availableSlots: -1);
      final notEmpty = _sampleLot().copyWith(availableSlots: 5);
      expect(empty.isFull, isTrue);
      expect(negative.isFull, isTrue);
      expect(notEmpty.isFull, isFalse);
    });

    test('copyWith hanya mengubah field yang disebutkan', () {
      final lot = _sampleLot();
      final updated = lot.copyWith(name: 'Bandung Plaza', motorRate: 5000);
      expect(updated.name, 'Bandung Plaza');
      expect(updated.motorRate, 5000);
      // field lain tidak berubah
      expect(updated.id, lot.id);
      expect(updated.pricePerHour, lot.pricePerHour);
    });
  });

  group('Vehicle', () {
    test('label sesuai VehicleKind', () {
      expect(
        const Vehicle(
          id: 'v1',
          plateNumber: 'B1',
          kind: VehicleKind.motor,
          quantity: 1,
          durationHours: 2,
        ).label,
        'Motor',
      );
      expect(
        const Vehicle(
          id: 'v2',
          plateNumber: 'B2',
          kind: VehicleKind.mobil,
          quantity: 1,
          durationHours: 2,
        ).label,
        'Mobil',
      );
      expect(
        const Vehicle(
          id: 'v3',
          plateNumber: 'B3',
          kind: VehicleKind.truk,
          quantity: 1,
          durationHours: 2,
        ).label,
        'Truk',
      );
    });
  });

  group('Booking', () {
    Booking booking({BookingStatus status = BookingStatus.paid}) => Booking(
      parkingLotId: 'lot-1',
      ticketNumber: 'TKT-ABC123',
      slotCode: 'A-12',
      locationName: 'Sudirman Plaza',
      plateNumber: 'B1234XYZ',
      vehicleLabel: 'Mobil',
      entryTime: DateTime(2026, 6, 26, 10, 0),
      durationHours: 2,
      estimatedCost: 24000,
      paymentMethod: PaymentMethod.qris,
      status: status,
    );

    test('isPaid true untuk paid/active/completed', () {
      expect(booking(status: BookingStatus.paid).isPaid, isTrue);
      expect(booking(status: BookingStatus.active).isPaid, isTrue);
      expect(booking(status: BookingStatus.completed).isPaid, isTrue);
    });

    test('isPaid false untuk pendingPayment dan cancelled', () {
      expect(booking(status: BookingStatus.pendingPayment).isPaid, isFalse);
      expect(booking(status: BookingStatus.cancelled).isPaid, isFalse);
    });

    test('canShowTicket hanya untuk paid/active', () {
      expect(booking(status: BookingStatus.paid).canShowTicket, isTrue);
      expect(booking(status: BookingStatus.active).canShowTicket, isTrue);
      expect(booking(status: BookingStatus.completed).canShowTicket, isFalse);
      expect(
        booking(status: BookingStatus.pendingPayment).canShowTicket,
        isFalse,
      );
    });

    test('copyWith status dan amountDue', () {
      final b = booking();
      final extended = b.copyWith(
        status: BookingStatus.active,
        amountDue: 5000,
      );
      expect(extended.status, BookingStatus.active);
      expect(extended.amountDue, 5000);
      // field lain tidak berubah
      expect(extended.ticketNumber, b.ticketNumber);
    });
  });
}
