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

    await _client
        .from('parking_slots')
        .update({'status': 'reserved'})
        .eq('id', slot.id);

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
    await _updateBookingActivity(
      ticketNumber: ticketNumber,
      bookingStatus: 'active',
      slotStatus: 'occupied',
      activityAction: 'check_in',
      bookingTimeColumn: 'checked_in_at',
      guardColumn: 'checked_in_by',
      note: 'Kendaraan masuk diverifikasi dari scan QR.',
    );
  }

  Future<void> checkOutBooking(String ticketNumber) async {
    await _updateBookingActivity(
      ticketNumber: ticketNumber,
      bookingStatus: 'completed',
      slotStatus: 'available',
      activityAction: 'check_out',
      bookingTimeColumn: 'checked_out_at',
      guardColumn: 'checked_out_by',
      note: 'Kendaraan keluar dikonfirmasi dari scan QR.',
      setExitTime: true,
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

  Future<void> _updateBookingActivity({
    required String ticketNumber,
    required String bookingStatus,
    required String slotStatus,
    required String activityAction,
    required String bookingTimeColumn,
    required String guardColumn,
    required String note,
    bool setExitTime = false,
  }) async {
    final bookingRow = await _client
        .from('bookings')
        .select('id, parking_lot_id, parking_slot_id')
        .eq('ticket_number', ticketNumber)
        .limit(1)
        .maybeSingle();
    if (bookingRow == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    final guardId = await _currentGuardId();
    final bookingUpdate = <String, dynamic>{
      'status': bookingStatus,
      bookingTimeColumn: now,
      guardColumn: guardId,
    };
    if (setExitTime) {
      bookingUpdate['exit_time'] = now;
    }

    await _client
        .from('bookings')
        .update(bookingUpdate)
        .eq('id', bookingRow['id'] as String);

    final slotId = bookingRow['parking_slot_id'] as String?;
    if (slotId != null) {
      await _client
          .from('parking_slots')
          .update({'status': slotStatus})
          .eq('id', slotId);
    }

    await _insertActivityLogIfAvailable(
      bookingRow: bookingRow,
      action: activityAction,
      note: note,
      guardId: guardId,
    );
  }

  Future<String?> _currentGuardId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rows = await _client
        .from('parking_guards')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }

    return (rows.first as Map)['id'] as String?;
  }

  Future<void> _insertActivityLogIfAvailable({
    required Map<String, dynamic> bookingRow,
    required String action,
    required String note,
    required String? guardId,
  }) async {
    try {
      await _client.from('parking_activity_logs').insert({
        'booking_id': bookingRow['id'],
        'parking_lot_id': bookingRow['parking_lot_id'],
        'parking_slot_id': bookingRow['parking_slot_id'],
        'guard_id': guardId,
        'actor_profile_id': _client.auth.currentUser?.id,
        'action': action,
        'note': note,
      });
    } on PostgrestException catch (error) {
      if (!_isMissingActivityLogsTable(error)) {
        rethrow;
      }
    }
  }

  bool _isMissingActivityLogsTable(PostgrestException error) {
    return error.code == '42P01' ||
        error.message.contains('parking_activity_logs');
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
