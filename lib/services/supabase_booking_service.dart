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
}
