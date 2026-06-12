import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseGuardService {
  SupabaseGuardService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ParkingGuardAccount>> fetchCurrentProviderGuards() async {
    final rows = await _client.rpc('list_current_provider_guards');
    return [
      for (final row in rows) _guardFromRow(Map<String, dynamic>.from(row)),
    ];
  }

  Future<ParkingGuardAccount?> fetchCurrentGuardAccount() async {
    final rows = await _client.rpc('current_guard_account');
    if (rows is! List || rows.isEmpty) {
      return null;
    }

    return _guardFromRow(Map<String, dynamic>.from(rows.first));
  }

  Future<ParkingGuardAccount> linkExistingGuard({
    required String name,
    required String email,
    required String phoneNumber,
    required List<String> assignedLotIds,
    required bool canScanQr,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) async {
    final rows = await _client.rpc(
      'link_parking_guard_by_email',
      params: {
        'p_guard_name': name,
        'p_guard_email': email,
        'p_guard_phone': phoneNumber,
        'p_parking_lot_ids': assignedLotIds,
        'p_can_scan_qr': canScanQr,
        'p_can_confirm_cash': canConfirmCash,
        'p_can_manage_slots': canManageSlots,
      },
    );

    if (rows is! List || rows.isEmpty) {
      throw const AuthException('Akun penjaga belum ditemukan.');
    }

    return _guardFromRow(Map<String, dynamic>.from(rows.first));
  }

  Future<ParkingGuardAccount> createGuardAccount({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required List<String> assignedLotIds,
    required bool canScanQr,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) async {
    final response = await _client.functions.invoke(
      'create-guard-account',
      body: {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'assignedLotIds': assignedLotIds,
        'canScanQr': canScanQr,
        'canConfirmCash': canConfirmCash,
        'canManageSlots': canManageSlots,
      },
    );

    final data = response.data;
    if (data is! Map || data['guard'] is! Map) {
      throw const AuthException('Akun penjaga gagal dibuat.');
    }

    return _guardFromRow(Map<String, dynamic>.from(data['guard'] as Map));
  }

  Future<void> unlinkGuard(String id) async {
    await _client.rpc('unlink_parking_guard', params: {'p_guard_id': id});
  }

  ParkingGuardAccount _guardFromRow(Map<String, dynamic> row) {
    return ParkingGuardAccount(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Penjaga Parkir',
      email: row['email'] as String? ?? '',
      phoneNumber: row['phone_number'] as String? ?? '',
      providerId: row['provider_id'] as String? ?? 'provider-main',
      assignedLotIds: [
        for (final id in (row['assigned_lot_ids'] as List? ?? const []))
          id.toString(),
      ],
      canScanQr: row['can_scan_qr'] as bool? ?? true,
      canConfirmCash: row['can_confirm_cash'] as bool? ?? true,
      canManageSlots: row['can_manage_slots'] as bool? ?? false,
    );
  }
}
