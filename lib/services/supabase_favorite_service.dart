import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFavoriteService {
  SupabaseFavoriteService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<String>> fetchCurrentCustomerFavoriteLotIds() async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return const [];
    }

    final rows = await _client
        .from('customer_favorite_lots')
        .select('parking_lot_id')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        if (row['parking_lot_id'] != null) row['parking_lot_id'] as String,
    ];
  }

  Future<void> saveFavoriteLot(String lotId) async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return;
    }

    await _client.from('customer_favorite_lots').upsert({
      'customer_id': customerId,
      'parking_lot_id': lotId,
    }, onConflict: 'customer_id,parking_lot_id');
  }

  Future<void> removeFavoriteLot(String lotId) async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return;
    }

    await _client
        .from('customer_favorite_lots')
        .delete()
        .eq('customer_id', customerId)
        .eq('parking_lot_id', lotId);
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
