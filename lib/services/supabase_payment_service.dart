import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseReceiptRecord {
  const SupabaseReceiptRecord({
    required this.receiptNumber,
    required this.ticketNumber,
    required this.locationName,
    required this.plateNumber,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amount,
    required this.issuedAt,
  });

  final String receiptNumber;
  final String ticketNumber;
  final String locationName;
  final String plateNumber;
  final String paymentStatus;
  final String paymentMethod;
  final int amount;
  final DateTime issuedAt;
}

class SupabasePaymentService {
  SupabasePaymentService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> payCurrentCustomerBooking({
    required Booking booking,
    required PaymentMethod method,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final customerId = await _currentCustomerId(user.id);
    if (customerId == null) {
      return;
    }

    final bookingRow = await _client
        .from('bookings')
        .select('id')
        .eq('ticket_number', booking.ticketNumber)
        .eq('customer_id', customerId)
        .limit(1)
        .maybeSingle();

    if (bookingRow == null) {
      return;
    }

    final bookingId = bookingRow['id'] as String;
    final now = DateTime.now();
    final paymentRow = await _client
        .from('payments')
        .insert({
          'booking_id': bookingId,
          'customer_id': customerId,
          'method': _methodToDb(method),
          'status': 'paid',
          'amount': booking.estimatedCost,
          'provider_reference': 'DEMO-${booking.ticketNumber}',
          'paid_at': now.toIso8601String(),
        })
        .select('id')
        .single();

    await _client
        .from('bookings')
        .update({'status': 'paid', 'final_cost': booking.estimatedCost})
        .eq('id', bookingId);

    await _createReceiptIfAvailable(
      bookingId: bookingId,
      paymentId: paymentRow['id'] as String,
      ticketNumber: booking.ticketNumber,
      issuedBy: user.id,
    );
  }

  Future<SupabaseReceiptRecord?> fetchLatestReceipt() async {
    try {
      final rows = await _client
          .from('receipts')
          .select(
            'receipt_number, issued_at, '
            'bookings(ticket_number, estimated_cost, final_cost, parking_lots(name), vehicles(plate_number)), '
            'payments(method, status, amount)',
          )
          .order('issued_at', ascending: false)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }

      return _receiptFromRow(Map<String, dynamic>.from(rows.first as Map));
    } on PostgrestException catch (error) {
      if (_isMissingReceiptsTable(error)) {
        return null;
      }
      rethrow;
    }
  }

  Future<String?> _currentCustomerId(String profileId) async {
    final rows = await _client
        .from('customers')
        .select('id')
        .eq('profile_id', profileId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['id'] as String?;
  }

  Future<void> _createReceiptIfAvailable({
    required String bookingId,
    required String paymentId,
    required String ticketNumber,
    required String issuedBy,
  }) async {
    try {
      await _client.from('receipts').upsert({
        'booking_id': bookingId,
        'payment_id': paymentId,
        'receipt_number': 'RCT-$ticketNumber',
        'issued_by': issuedBy,
      }, onConflict: 'booking_id');
    } on PostgrestException catch (error) {
      if (!_isMissingReceiptsTable(error)) {
        rethrow;
      }
    }
  }

  bool _isMissingReceiptsTable(PostgrestException error) {
    return error.code == '42P01' || error.message.contains('receipts');
  }

  SupabaseReceiptRecord _receiptFromRow(Map<String, dynamic> row) {
    final booking = _nestedMap(row, 'bookings');
    final payment = _nestedMap(row, 'payments');
    final amount =
        (payment?['amount'] as num?)?.toInt() ??
        (booking?['final_cost'] as num?)?.toInt() ??
        (booking?['estimated_cost'] as num?)?.toInt() ??
        0;

    return SupabaseReceiptRecord(
      receiptNumber: row['receipt_number'] as String? ?? '-',
      ticketNumber: booking?['ticket_number'] as String? ?? '-',
      locationName: _nestedValue(booking, 'parking_lots', 'name') ?? '-',
      plateNumber: _nestedValue(booking, 'vehicles', 'plate_number') ?? '-',
      paymentStatus: _paymentStatusLabel(payment?['status'] as String?),
      paymentMethod: _paymentMethodLabel(payment?['method'] as String?),
      amount: amount,
      issuedAt:
          DateTime.tryParse(row['issued_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic>? _nestedMap(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _nestedValue(Map<String, dynamic>? row, String table, String column) {
    if (row == null) {
      return null;
    }
    final nested = row[table];
    if (nested is Map) {
      return nested[column] as String?;
    }
    return null;
  }

  String _paymentStatusLabel(String? status) => switch (status) {
    'paid' => 'Lunas',
    'pending' => 'Menunggu bayar',
    'failed' => 'Gagal',
    'refunded' => 'Dikembalikan',
    'cancelled' => 'Dibatalkan',
    _ => 'Lunas',
  };

  String _paymentMethodLabel(String? method) => switch (method) {
    'ewallet' => 'E-Wallet',
    'cash' => 'Tunai',
    'card' => 'Debit/Kredit',
    _ => 'QRIS',
  };

  String _methodToDb(PaymentMethod method) => switch (method) {
    PaymentMethod.qris => 'qris',
    PaymentMethod.ewallet => 'ewallet',
    PaymentMethod.cash => 'cash',
    PaymentMethod.card => 'card',
  };
}
