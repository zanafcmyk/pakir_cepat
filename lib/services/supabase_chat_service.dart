import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseChatService {
  SupabaseChatService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> sendMessage({
    required String localRoomId,
    required String title,
    required AccountMode senderMode,
    required String senderName,
    required String participantRole,
    required String participantName,
    required String message,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final senderProfile = await _profileById(user.id);
    if (senderProfile == null) {
      return;
    }

    final targetRole = _roleFromLabel(participantRole);
    final targetProfile = targetRole == null
        ? null
        : await _firstProfileByRole(targetRole);

    final roomId = await _ensureRoom(
      localRoomId: localRoomId,
      title: title,
      senderProfile: senderProfile,
      senderMode: senderMode,
      senderName: senderName,
      targetProfile: targetProfile,
      participantName: participantName,
    );

    await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_profile_id': user.id,
      'sender_role': _roleToDb(senderMode),
      'sender_name': senderName,
      'message': message,
    });
  }

  Future<Map<String, dynamic>?> _profileById(String profileId) async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, role')
        .eq('id', profileId)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(rows.first as Map);
  }

  Future<Map<String, dynamic>?> _firstProfileByRole(AccountMode role) async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, role')
        .eq('role', _roleToDb(role))
        .eq('access_status', 'active')
        .order('created_at')
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(rows.first as Map);
  }

  Future<String> _ensureRoom({
    required String localRoomId,
    required String title,
    required Map<String, dynamic> senderProfile,
    required AccountMode senderMode,
    required String senderName,
    required Map<String, dynamic>? targetProfile,
    required String participantName,
  }) async {
    final existingRooms = await _client
        .from('chat_rooms')
        .select('id')
        .eq('room_key', localRoomId)
        .limit(1);

    if (existingRooms.isNotEmpty) {
      return (existingRooms.first as Map)['id'] as String;
    }

    final insertedRoom = await _client
        .from('chat_rooms')
        .insert({
          'room_key': localRoomId,
          'room_type': _roomTypeFromKey(localRoomId),
          'title': title,
          'created_by': senderProfile['id'],
          'last_message': 'Room chat siap digunakan.',
        })
        .select('id')
        .single();

    final roomId = insertedRoom['id'] as String;
    final members = [
      {
        'room_id': roomId,
        'profile_id': senderProfile['id'],
        'member_role': _roleToDb(senderMode),
        'display_name': senderName.isEmpty
            ? senderProfile['full_name']
            : senderName,
      },
      if (targetProfile != null)
        {
          'room_id': roomId,
          'profile_id': targetProfile['id'],
          'member_role': targetProfile['role'],
          'display_name': participantName.isEmpty
              ? targetProfile['full_name']
              : participantName,
        },
    ];

    await _client.from('chat_room_members').insert(members);
    return roomId;
  }

  AccountMode? _roleFromLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('customer') || normalized.contains('pelanggan')) {
      return AccountMode.customer;
    }
    if (normalized.contains('penyedia') || normalized.contains('provider')) {
      return AccountMode.provider;
    }
    if (normalized.contains('penjaga') || normalized.contains('guard')) {
      return AccountMode.parkingGuard;
    }
    if (normalized.contains('admin')) {
      return AccountMode.superAdmin;
    }
    return null;
  }

  String _roleToDb(AccountMode mode) => switch (mode) {
    AccountMode.superAdmin => 'super_admin',
    AccountMode.provider => 'provider',
    AccountMode.parkingGuard => 'parking_guard',
    AccountMode.customer => 'customer',
  };

  String _roomTypeFromKey(String roomKey) {
    if (roomKey.contains('customer-provider')) return 'customer_provider';
    if (roomKey.contains('provider-customer')) return 'customer_provider';
    if (roomKey.contains('customer-guard')) return 'customer_guard';
    if (roomKey.contains('guard-customer')) return 'customer_guard';
    if (roomKey.contains('customer-admin')) return 'customer_admin';
    if (roomKey.contains('superadmin-customer')) return 'customer_admin';
    if (roomKey.contains('provider-guard')) return 'provider_guard';
    if (roomKey.contains('guard-provider')) return 'provider_guard';
    if (roomKey.contains('provider-superadmin')) return 'provider_admin';
    if (roomKey.contains('superadmin-provider')) return 'provider_admin';
    if (roomKey.contains('guard-admin')) return 'guard_admin';
    if (roomKey.contains('superadmin-guard')) return 'guard_admin';
    return 'group';
  }
}
