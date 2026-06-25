import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseVehicleService {
  SupabaseVehicleService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Vehicle>> fetchCurrentCustomerVehicles() async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return const [];
    }

    final rows = await _client
        .from('vehicles')
        .select('id, plate_number, kind')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        Vehicle(
          id: row['id'] as String,
          plateNumber: row['plate_number'] as String? ?? '-',
          kind: _kindFromDb(row['kind'] as String?),
          quantity: 1,
          durationHours: 2,
        ),
    ];
  }

  Future<List<Vehicle>> saveCurrentCustomerVehicles({
    required List<String> plateNumbers,
    required VehicleKind kind,
    required int durationHours,
  }) async {
    final customerId = await _ensureCurrentCustomerId();
    if (customerId == null) {
      throw StateError('Profil customer tidak ditemukan.');
    }

    final normalizedPlates = plateNumbers
        .map((plate) => plate.trim().toUpperCase())
        .where((plate) => plate.isNotEmpty)
        .toList();
    final rows = await _client
        .from('vehicles')
        .upsert([
          for (final plateNumber in normalizedPlates)
            {
              'customer_id': customerId,
              'plate_number': plateNumber,
              'kind': _kindToDb(kind),
            },
        ], onConflict: 'customer_id,plate_number')
        .select('id, plate_number, kind')
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        Vehicle(
          id: row['id'] as String,
          plateNumber: row['plate_number'] as String? ?? '-',
          kind: _kindFromDb(row['kind'] as String?),
          quantity: 1,
          durationHours: durationHours,
        ),
    ];
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

  Future<String?> _ensureCurrentCustomerId() async {
    final existingCustomerId = await _currentCustomerId();
    if (existingCustomerId != null) {
      return existingCustomerId;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final fullName =
        user.userMetadata?['full_name'] as String? ??
        user.email?.split('@').first ??
        'Customer';
    await _client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'email': user.email,
      'role': 'customer',
      'account_status': 'verified',
      'access_status': 'active',
      'verified_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');

    final rows = await _client
        .from('customers')
        .upsert({'profile_id': user.id}, onConflict: 'profile_id')
        .select('id')
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['id'] as String?;
  }

  VehicleKind _kindFromDb(String? value) => switch (value) {
    'motor' => VehicleKind.motor,
    'truk' => VehicleKind.truk,
    _ => VehicleKind.mobil,
  };

  String _kindToDb(VehicleKind kind) => switch (kind) {
    VehicleKind.motor => 'motor',
    VehicleKind.mobil => 'mobil',
    VehicleKind.truk => 'truk',
  };
}
