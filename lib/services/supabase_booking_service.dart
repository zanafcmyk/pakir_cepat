import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseBookingResult {
  const SupabaseBookingResult({
    required this.ticketNumber,
    required this.slotId,
    required this.durationHours,
    required this.effectiveRate,
    required this.estimatedCost,
  });

  final String ticketNumber;
  final String slotId;
  final int durationHours;
  final int effectiveRate;
  final int estimatedCost;
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

  Future<SupabaseBookingResult> createCurrentCustomerBooking({
    required ParkingLot lot,
    required ParkingSlot slot,
    required Vehicle vehicle,
    required DateTime entryTime,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sesi customer tidak ditemukan.');
    }
    _validateSupabaseBookingIds(lot: lot, slot: slot);

    final ticketNumber = _ticketNumber();

    return _createBookingWithRpc(
      lot: lot,
      slot: slot,
      vehicle: vehicle,
      entryTime: entryTime,
      ticketNumber: ticketNumber,
    );
  }

  Future<SupabaseBookingResult> _createBookingWithRpc({
    required ParkingLot lot,
    required ParkingSlot slot,
    required Vehicle vehicle,
    required DateTime entryTime,
    required String ticketNumber,
  }) async {
    final rows = await _client.rpc(
      'app_create_customer_booking',
      params: {
        'p_parking_lot_id': lot.id,
        'p_parking_slot_id': slot.id,
        'p_vehicle_plate': vehicle.plateNumber,
        'p_ticket_number': ticketNumber,
        'p_entry_time': entryTime.toIso8601String(),
        'p_duration_hours': vehicle.durationHours,
      },
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('RPC booking tidak mengembalikan hasil.');
    }
    final row = Map<String, dynamic>.from(rows.first as Map);
    final serverEstimatedCost = (row['estimated_cost'] as num?)?.toInt() ?? 0;
    if (serverEstimatedCost <= 0) {
      throw StateError('Server mengembalikan biaya booking yang tidak valid.');
    }
    return SupabaseBookingResult(
      ticketNumber: row['ticket_number'] as String? ?? ticketNumber,
      slotId: row['slot_id'] as String? ?? slot.id,
      durationHours:
          (row['duration_hours'] as num?)?.toInt() ?? vehicle.durationHours,
      effectiveRate: (row['effective_rate'] as num?)?.toInt() ?? 0,
      estimatedCost: serverEstimatedCost,
    );
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
    return _activeBookingFromRow(row);
  }

  Future<SupabaseActiveBooking?> fetchBookingByTicketNumber(
    String ticketNumber,
  ) async {
    final rows = await _client
        .from('bookings')
        .select(
          'id, ticket_number, entry_time, estimated_cost, status, '
          'parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind)',
        )
        .eq('ticket_number', ticketNumber)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);
    return _activeBookingFromRow(row);
  }

  Future<List<TransactionRecord>> fetchCurrentCustomerHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final customerId = await _currentCustomerId(user.id);
    final rows = await _client
        .from('bookings')
        .select(
          'ticket_number, entry_time, exit_time, estimated_cost, final_cost, status, '
          'parking_lots(name), vehicles(plate_number)',
        )
        .eq('customer_id', customerId)
        .inFilter('status', ['paid', 'active', 'completed'])
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        _transactionRecordFromRow(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<void> checkInBooking(String ticketNumber) async {
    await _processGuardTicket(ticketNumber, 'check_in');
  }

  Future<void> checkOutBooking(String ticketNumber) async {
    await _processGuardTicket(ticketNumber, 'check_out');
  }

  Future<String> _currentCustomerId(String profileId) async {
    final row = await _client
        .from('customers')
        .select('id')
        .eq('profile_id', profileId)
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

  Future<void> _processGuardTicket(String ticketNumber, String action) async {
    final rows = await _client.rpc(
      'app_guard_process_ticket',
      params: {'p_ticket_number': ticketNumber, 'p_action': action},
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('RPC scan tiket tidak mengembalikan hasil.');
    }
  }

  void _validateSupabaseBookingIds({
    required ParkingLot lot,
    required ParkingSlot slot,
  }) {
    if (!_isSupabaseUuid(lot.id)) {
      throw StateError(
        'Data lokasi masih demo/lokal. Muat ulang dashboard sampai lokasi Supabase tampil, lalu pilih lokasi lagi.',
      );
    }
    if (!_isSupabaseUuid(slot.id)) {
      throw StateError(
        'Data slot masih demo/lokal. Muat ulang data lokasi Supabase sebelum booking.',
      );
    }
  }

  bool _isSupabaseUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  Future<SupabaseActiveBooking> _activeBookingFromRow(
    Map<String, dynamic> row,
  ) async {
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

  TransactionRecord _transactionRecordFromRow(Map<String, dynamic> row) {
    final status = _bookingStatusFromDb(row['status'] as String?);
    final timeText =
        row['exit_time'] as String? ??
        row['entry_time'] as String? ??
        DateTime.now().toIso8601String();
    final time = DateTime.tryParse(timeText) ?? DateTime.now();

    return TransactionRecord(
      id: row['ticket_number'] as String? ?? '-',
      locationName: _nestedValue(row, 'parking_lots', 'name') ?? '-',
      plateNumber: _nestedValue(row, 'vehicles', 'plate_number') ?? '-',
      status: _historyStatusLabel(status),
      total:
          (row['final_cost'] as num?)?.toInt() ??
          (row['estimated_cost'] as num?)?.toInt() ??
          0,
      timeLabel: _formatDateTime(time),
    );
  }

  String _historyStatusLabel(BookingStatus status) => switch (status) {
    BookingStatus.completed => 'Selesai',
    BookingStatus.active => 'Sedang parkir',
    BookingStatus.paid => 'Lunas',
    BookingStatus.cancelled => 'Dibatalkan',
    BookingStatus.pendingPayment => 'Menunggu bayar',
  };

  String _formatDateTime(DateTime value) {
    final date =
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date, $time';
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
    _ => PaymentMethod.qris,
  };
}
