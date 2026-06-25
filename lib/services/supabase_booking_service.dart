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

class SupabaseBookingExtensionResult {
  const SupabaseBookingExtensionResult({
    required this.durationHours,
    required this.effectiveRate,
    required this.estimatedCost,
    required this.amountDue,
    required this.additionalCost,
  });

  final int durationHours;
  final int effectiveRate;
  final int estimatedCost;
  final int amountDue;
  final int additionalCost;
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
          'id, ticket_number, qr_payload, entry_time, duration_hours, estimated_cost, status, '
          'parking_lot_id, parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind), '
          'payments(method, status, amount, created_at)',
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
          'id, ticket_number, qr_payload, entry_time, duration_hours, estimated_cost, status, '
          'parking_lot_id, parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind), '
          'payments(method, status, amount, created_at)',
        )
        .eq('ticket_number', ticketNumber)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);
    return _activeBookingFromRow(row);
  }

  Future<SupabaseActiveBooking?> fetchBookingByQrPayload(
    String qrPayload,
  ) async {
    final normalizedPayload = qrPayload.trim();
    if (normalizedPayload.isEmpty) {
      return null;
    }

    final rows = await _client
        .from('bookings')
        .select(
          'id, ticket_number, qr_payload, entry_time, duration_hours, estimated_cost, status, '
          'parking_lot_id, parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind), '
          'payments(method, status, amount, created_at)',
        )
        .eq('qr_payload', normalizedPayload)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(rows.first as Map);
    return _activeBookingFromRow(row);
  }

  Future<List<SupabaseActiveBooking>> fetchGuardOperationalBookings(
    List<String> assignedLotIds,
  ) async {
    if (assignedLotIds.isEmpty) {
      return const [];
    }

    final rows = await _client
        .from('bookings')
        .select(
          'id, ticket_number, qr_payload, entry_time, duration_hours, estimated_cost, status, '
          'parking_lot_id, parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind), '
          'payments(method, status, amount, created_at)',
        )
        .inFilter('parking_lot_id', assignedLotIds)
        .inFilter('status', ['pending_payment', 'paid', 'active'])
        .order('created_at', ascending: false)
        .limit(200);

    return Future.wait([
      for (final row in rows)
        _activeBookingFromRow(Map<String, dynamic>.from(row as Map)),
    ]);
  }

  Future<SupabaseActiveBooking?> searchGuardBooking({
    required List<String> assignedLotIds,
    required String ticketNumber,
    required String plateNumber,
  }) async {
    if (assignedLotIds.isEmpty) {
      return null;
    }

    final normalizedTicket = ticketNumber.trim().toUpperCase();
    final normalizedPlate = _normalizePlate(plateNumber);
    if (normalizedTicket.isEmpty && normalizedPlate.isEmpty) {
      return null;
    }

    final rows = await _client
        .from('bookings')
        .select(
          'id, ticket_number, qr_payload, entry_time, duration_hours, estimated_cost, status, '
          'parking_lot_id, parking_slot_id, parking_slots(label), '
          'parking_lots(name), vehicles(plate_number, kind), '
          'payments(method, status, amount, created_at)',
        )
        .inFilter('parking_lot_id', assignedLotIds)
        .order('created_at', ascending: false)
        .limit(200);

    for (final value in rows) {
      final row = Map<String, dynamic>.from(value as Map);
      final rowTicket = (row['ticket_number'] as String? ?? '').toUpperCase();
      final rowPlate = _normalizePlate(
        _nestedValue(row, 'vehicles', 'plate_number') ?? '',
      );
      final ticketMatches =
          normalizedTicket.isEmpty || rowTicket == normalizedTicket;
      final plateMatches =
          normalizedPlate.isEmpty || rowPlate == normalizedPlate;
      if (ticketMatches && plateMatches) {
        return _activeBookingFromRow(row);
      }
    }

    return null;
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
    await _processOperatorTicket(ticketNumber, 'check_in');
  }

  Future<void> checkOutBooking(String ticketNumber) async {
    await _processOperatorTicket(ticketNumber, 'check_out');
  }

  Future<SupabaseBookingExtensionResult> extendCurrentCustomerBooking({
    required String ticketNumber,
    required int additionalHours,
  }) async {
    final rows = await _client.rpc(
      'app_extend_customer_booking',
      params: {
        'p_ticket_number': ticketNumber,
        'p_additional_hours': additionalHours,
      },
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('RPC perpanjang durasi tidak mengembalikan hasil.');
    }
    final row = Map<String, dynamic>.from(rows.first as Map);
    return SupabaseBookingExtensionResult(
      durationHours: (row['duration_hours'] as num?)?.toInt() ?? 0,
      effectiveRate: (row['effective_rate'] as num?)?.toInt() ?? 0,
      estimatedCost: (row['estimated_cost'] as num?)?.toInt() ?? 0,
      amountDue: (row['amount_due'] as num?)?.toInt() ?? 0,
      additionalCost: (row['additional_cost'] as num?)?.toInt() ?? 0,
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

  Future<void> _processOperatorTicket(
    String ticketNumber,
    String action,
  ) async {
    final rows = await _client.rpc(
      'app_operator_process_ticket',
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
    final paymentMethod = await _paymentMethodFromBookingRow(row);
    final estimatedCost = (row['estimated_cost'] as num?)?.toInt() ?? 0;

    return SupabaseActiveBooking(
      booking: Booking(
        parkingLotId: row['parking_lot_id'] as String?,
        ticketNumber: row['ticket_number'] as String? ?? '-',
        qrPayload: row['qr_payload'] as String?,
        slotCode: _nestedValue(row, 'parking_slots', 'label') ?? '-',
        locationName: _nestedValue(row, 'parking_lots', 'name') ?? '-',
        plateNumber: _nestedValue(row, 'vehicles', 'plate_number') ?? '-',
        vehicleLabel: _vehicleLabel(_nestedValue(row, 'vehicles', 'kind')),
        entryTime:
            DateTime.tryParse(row['entry_time'] as String? ?? '') ??
            DateTime.now(),
        durationHours: (row['duration_hours'] as num?)?.toInt() ?? 1,
        estimatedCost: estimatedCost,
        amountDue: _amountDue(row, estimatedCost),
        paymentMethod: paymentMethod,
        status: _bookingStatusFromDb(row['status'] as String?),
      ),
      slotId: row['parking_slot_id'] as String?,
    );
  }

  Future<PaymentMethod> _paymentMethodFromBookingRow(
    Map<String, dynamic> row,
  ) async {
    final paymentValues = row['payments'];
    if (paymentValues is List && paymentValues.isNotEmpty) {
      final payments =
          [
            for (final value in paymentValues)
              Map<String, dynamic>.from(value as Map),
          ]..sort(
            (a, b) => (b['created_at'] as String? ?? '').compareTo(
              a['created_at'] as String? ?? '',
            ),
          );
      return _paymentMethodFromDb(payments.first['method'] as String?);
    }
    return _latestPaymentMethod(row['id'] as String);
  }

  int _amountDue(Map<String, dynamic> row, int estimatedCost) {
    final payments = row['payments'];
    if (payments is! List) {
      return estimatedCost;
    }
    var paidTotal = 0;
    for (final value in payments) {
      final payment = Map<String, dynamic>.from(value as Map);
      if (payment['status'] == 'paid') {
        paidTotal += (payment['amount'] as num?)?.toInt() ?? 0;
      }
    }
    final due = estimatedCost - paidTotal;
    return due > 0 ? due : 0;
  }

  String _normalizePlate(String value) =>
      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

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
