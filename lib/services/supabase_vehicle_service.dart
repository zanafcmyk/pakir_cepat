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

  Future<Vehicle?> saveCurrentCustomerVehicle({
    required String plateNumber,
    required VehicleKind kind,
    required int quantity,
    required int durationHours,
  }) async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return null;
    }

    final row = await _client
        .from('vehicles')
        .upsert({
          'customer_id': customerId,
          'plate_number': plateNumber,
          'kind': _kindToDb(kind),
        }, onConflict: 'customer_id,plate_number')
        .select('id, plate_number, kind')
        .single();

    return Vehicle(
      id: row['id'] as String,
      plateNumber: row['plate_number'] as String? ?? plateNumber,
      kind: _kindFromDb(row['kind'] as String?),
      quantity: quantity,
      durationHours: durationHours,
    );
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
