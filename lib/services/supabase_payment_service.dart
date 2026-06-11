import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

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

  String _methodToDb(PaymentMethod method) => switch (method) {
    PaymentMethod.qris => 'qris',
    PaymentMethod.ewallet => 'ewallet',
    PaymentMethod.cash => 'cash',
    PaymentMethod.card => 'card',
  };
}
