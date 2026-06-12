import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseChatService {
  SupabaseChatService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ChatMessage>> fetchMessages({required String localRoomId}) async {
    final roomId = await _roomIdForLocalRoom(localRoomId);
    if (roomId == null) {
      return const [];
    }

    final rows = await _client
        .from('chat_messages')
        .select('id, sender_role, sender_name, message, is_read, created_at')
        .eq('room_id', roomId)
        .order('created_at');

    return [
      for (final row in rows)
        _messageFromRow(Map<String, dynamic>.from(row as Map), localRoomId),
    ];
  }

  Future<Stream<List<ChatMessage>>> watchMessages({
    required String localRoomId,
  }) async {
    final roomId = await _roomIdForLocalRoom(localRoomId);
    if (roomId == null) {
      return const Stream.empty();
    }

    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map(
          (rows) => [
            for (final row in rows)
              _messageFromRow(Map<String, dynamic>.from(row), localRoomId),
          ],
        );
  }

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

  Future<String?> _roomIdForLocalRoom(String localRoomId) async {
    final rows = await _client
        .from('chat_rooms')
        .select('id')
        .eq('room_key', _canonicalRoomKey(localRoomId))
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first as Map)['id'] as String?;
  }

  ChatMessage _messageFromRow(Map<String, dynamic> row, String localRoomId) {
    return ChatMessage(
      id: row['id'] as String,
      roomId: localRoomId,
      senderRole: _roleLabel(row['sender_role'] as String?),
      senderName: row['sender_name'] as String? ?? 'Pengguna',
      receiverRole: '',
      receiverName: '',
      message: row['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      isRead: row['is_read'] as bool? ?? false,
    );
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
    final roomKey = _canonicalRoomKey(localRoomId);
    final existingRooms = await _client
        .from('chat_rooms')
        .select('id')
        .eq('room_key', roomKey)
        .limit(1);

    if (existingRooms.isNotEmpty) {
      return (existingRooms.first as Map)['id'] as String;
    }

    final insertedRoom = await _client
        .from('chat_rooms')
        .insert({
          'room_key': roomKey,
          'room_type': _roomTypeFromKey(roomKey),
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

  String _roleLabel(String? role) => switch (role) {
    'super_admin' => 'Super Admin',
    'provider' => 'Penyedia Parkir',
    'parking_guard' => 'Penjaga Parkir',
    _ => 'Customer',
  };

  String _roomTypeFromKey(String roomKey) {
    if (roomKey.startsWith('customer_provider:')) return 'customer_provider';
    if (roomKey.startsWith('customer_guard:')) return 'customer_guard';
    if (roomKey.startsWith('customer_admin:')) return 'customer_admin';
    if (roomKey.startsWith('provider_guard:')) return 'provider_guard';
    if (roomKey.startsWith('provider_admin:')) return 'provider_admin';
    if (roomKey.startsWith('guard_admin:')) return 'guard_admin';
    return 'group';
  }

  String _canonicalRoomKey(String localRoomId) {
    const prefixes = [
      ('customer-provider-', 'customer_provider:'),
      ('provider-customer-', 'customer_provider:'),
      ('customer-guard-', 'customer_guard:'),
      ('guard-customer-', 'customer_guard:'),
      ('customer-admin-', 'customer_admin:'),
      ('superadmin-customer-', 'customer_admin:'),
      ('provider-guard-', 'provider_guard:'),
      ('guard-provider-', 'provider_guard:'),
      ('provider-superadmin-', 'provider_admin:'),
      ('superadmin-provider-', 'provider_admin:'),
      ('guard-admin-', 'guard_admin:'),
      ('superadmin-guard-', 'guard_admin:'),
    ];

    for (final (localPrefix, canonicalPrefix) in prefixes) {
      if (localRoomId.startsWith(localPrefix)) {
        return '$canonicalPrefix${localRoomId.substring(localPrefix.length)}';
      }
    }

    return 'group:$localRoomId';
  }
}
