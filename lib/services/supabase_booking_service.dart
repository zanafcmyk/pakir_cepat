import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseBookingResult {
  const SupabaseBookingResult({
    required this.ticketNumber,
    required this.slotId,
  });

  final String ticketNumber;
  final String slotId;
}

class SupabaseActiveBooking {
  const SupabaseActiveBooking({required this.booking, required this.slotId});

  final Booking booking;
  final String? slotId;
}

class SupabaseBookingService {
  SupabaseBookingService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SupabaseBookingResult?> createCurrentCustomerBooking({
    required ParkingLot lot,
    required ParkingSlot slot,
    required Vehicle vehicle,
    required DateTime entryTime,
    required int estimatedCost,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final customerId = await _currentCustomerId(user.id);
    final vehicleId = await _vehicleId(customerId, vehicle.plateNumber);
    final ticketNumber = _ticketNumber();

    await _client.from('parking_slots').update({
      'status': 'reserved',
    }).eq('id', slot.id);

    await _client.from('bookings').insert({
      'ticket_number': ticketNumber,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'parking_lot_id': lot.id,
      'parking_slot_id': slot.id,
      'entry_time': entryTime.toIso8601String(),
      'duration_hours': vehicle.durationHours,
      'price_per_hour': lot.pricePerHour,
      'estimated_cost': estimatedCost,
      'status': 'pending_payment',
      'qr_payload': 'PARKIRCEPAT|ENTRY_EXIT|$ticketNumber',
    });

    return SupabaseBookingResult(ticketNumber: ticketNumber, slotId: slot.id);
  }

  Future<SupabaseActiveBooking?> fetchCurrentCustomerActiveBooking() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final customerId = await _currentCustomerId(user.id);
    final rows = await _client
        .from('bookings')
        .select(
          'id, ticket_number, entry_time, estimated_cost, status, '
          'parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind)',
        )
        .eq('customer_id', customerId)
        .inFilter('status', ['pending_payment', 'paid', 'active'])
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);
    final paymentMethod = await _latestPaymentMethod(row['id'] as String);

    return SupabaseActiveBooking(
      booking: Booking(
        ticketNumber: row['ticket_number'] as String? ?? '-',
        slotCode: _nestedValue(row, 'parking_slots', 'label') ?? '-',
        locationName: _nestedValue(row, 'parking_lots', 'name') ?? '-',
        plateNumber: _nestedValue(row, 'vehicles', 'plate_number') ?? '-',
        vehicleLabel: _vehicleLabel(_nestedValue(row, 'vehicles', 'kind')),
        entryTime:
            DateTime.tryParse(row['entry_time'] as String? ?? '') ??
            DateTime.now(),
        estimatedCost: (row['estimated_cost'] as num?)?.toInt() ?? 0,
        paymentMethod: paymentMethod,
        status: _bookingStatusFromDb(row['status'] as String?),
      ),
      slotId: row['parking_slot_id'] as String?,
    );
  }

  Future<String> _currentCustomerId(String profileId) async {
    final row = await _client
        .from('customers')
        .select('id')
        .eq('profile_id', profileId)
        .single();
    return row['id'] as String;
  }

  Future<String> _vehicleId(String customerId, String plateNumber) async {
    final row = await _client
        .from('vehicles')
        .select('id')
        .eq('customer_id', customerId)
        .eq('plate_number', plateNumber)
        .single();
    return row['id'] as String;
  }

  String _ticketNumber() {
    final now = DateTime.now();
    return 'TKT-${now.millisecondsSinceEpoch}';
  }

  Future<PaymentMethod> _latestPaymentMethod(String bookingId) async {
    final rows = await _client
        .from('payments')
        .select('method')
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      return PaymentMethod.qris;
    }

    return _paymentMethodFromDb((rows.first as Map)['method'] as String?);
  }

  String? _nestedValue(Map<String, dynamic> row, String table, String column) {
    final nested = row[table];
    if (nested is Map) {
      return nested[column] as String?;
    }
    return null;
  }

  String _vehicleLabel(String? kind) => switch (kind) {
    'motor' => 'Motor',
    'truk' => 'Truk',
    _ => 'Mobil',
  };

  BookingStatus _bookingStatusFromDb(String? status) => switch (status) {
    'paid' => BookingStatus.paid,
    'active' => BookingStatus.active,
    'completed' => BookingStatus.completed,
    'cancelled' => BookingStatus.cancelled,
    _ => BookingStatus.pendingPayment,
  };

  PaymentMethod _paymentMethodFromDb(String? method) => switch (method) {
    'ewallet' => PaymentMethod.ewallet,
    'cash' => PaymentMethod.cash,
    'card' => PaymentMethod.card,
    _ => PaymentMethod.qris,
  };
}
