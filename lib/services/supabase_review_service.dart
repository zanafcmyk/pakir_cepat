import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReviewService {
  SupabaseReviewService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> submitReviewForTicket({
    required String ticketNumber,
    required int rating,
    required String comment,
  }) async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return;
    }

    final booking = await _client
        .from('bookings')
        .select('id, parking_lot_id')
        .eq('ticket_number', ticketNumber)
        .eq('customer_id', customerId)
        .limit(1)
        .maybeSingle();

    if (booking == null) {
      throw const AuthException('Booking tidak ditemukan.');
    }

    await _client.from('reviews').insert({
      'booking_id': booking['id'],
      'customer_id': customerId,
      'parking_lot_id': booking['parking_lot_id'],
      'rating': rating,
      'comment': comment.isEmpty ? null : comment,
    });
  }

  Future<String?> _currentCustomerId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rows = await _client
        .from('customers')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['id'] as String?;
  }
}
