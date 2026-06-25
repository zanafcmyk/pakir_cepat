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

class SupabaseGatewayPaymentResult {
  const SupabaseGatewayPaymentResult({
    required this.paymentId,
    required this.orderId,
    required this.redirectUrl,
  });

  final String paymentId;
  final String orderId;
  final String redirectUrl;
}

class SupabasePaymentService {
  SupabasePaymentService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SupabaseGatewayPaymentResult?> createMidtransPayment({
    required Booking booking,
    required PaymentMethod method,
  }) async {
    final response = await _client.functions.invoke(
      'create-midtrans-payment',
      body: {
        'ticketNumber': booking.ticketNumber,
        'method': _methodToDb(method),
      },
    );

    final data = response.data;
    if (data is! Map) {
      return null;
    }

    final paymentId = data['paymentId'] as String?;
    final orderId = data['orderId'] as String?;
    final redirectUrl = data['redirectUrl'] as String?;
    if (paymentId == null || orderId == null || redirectUrl == null) {
      return null;
    }

    return SupabaseGatewayPaymentResult(
      paymentId: paymentId,
      orderId: orderId,
      redirectUrl: redirectUrl,
    );
  }

  Future<void> confirmCurrentOperatorCashPayment(String ticketNumber) async {
    final rows = await _client.rpc(
      'app_operator_confirm_cash_payment',
      params: {'p_ticket_number': ticketNumber},
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('RPC pembayaran tunai tidak mengembalikan hasil.');
    }
  }

  Future<void> simulateCurrentCustomerPayment(String ticketNumber) async {
    final rows = await _client.rpc(
      'app_simulate_customer_payment',
      params: {'p_ticket_number': ticketNumber},
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('RPC simulasi pembayaran tidak mengembalikan hasil.');
    }
  }

  Future<SupabaseReceiptRecord?> fetchReceipt({String? ticketNumber}) async {
    try {
      String? bookingId;
      if (ticketNumber != null && ticketNumber.trim().isNotEmpty) {
        final booking = await _client
            .from('bookings')
            .select('id')
            .eq('ticket_number', ticketNumber.trim())
            .limit(1)
            .maybeSingle();
        bookingId = booking?['id'] as String?;
        if (bookingId == null) {
          return null;
        }
      }

      final rows = await _client
          .from('receipts')
          .select(
            'receipt_number, issued_at, '
            'bookings(ticket_number, estimated_cost, final_cost, parking_lots(name), vehicles(plate_number)), '
            'payments(method, status, amount)',
          )
          .match(bookingId == null ? const {} : {'booking_id': bookingId})
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
    'card' => 'Digital',
    _ => 'QRIS',
  };

  String _methodToDb(PaymentMethod method) => switch (method) {
    PaymentMethod.qris => 'qris',
    PaymentMethod.ewallet => 'ewallet',
    PaymentMethod.cash => 'cash',
  };
}
