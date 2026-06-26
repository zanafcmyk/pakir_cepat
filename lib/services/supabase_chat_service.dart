import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseChatService {
  SupabaseChatService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ChatRoom>> fetchRoomsForCurrentUser({
    required AccountMode mode,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final memberRows = await _client
        .from('chat_room_members')
        .select('room_id, profile_id, member_role, display_name, unread_count')
        .eq('profile_id', user.id);
    if (memberRows.isEmpty) {
      return const [];
    }

    final roomIds = [
      for (final row in memberRows) (row as Map)['room_id'] as String?,
    ].whereType<String>().toSet().toList();
    if (roomIds.isEmpty) {
      return const [];
    }

    final roomRows = await _client
        .from('chat_rooms')
        .select(
          'id, room_key, title, last_message, last_message_at, created_at',
        )
        .inFilter('id', roomIds)
        .order('last_message_at', ascending: false);
    final allMemberRows = await _client
        .from('chat_room_members')
        .select('room_id, profile_id, member_role, display_name, unread_count')
        .inFilter('room_id', roomIds);

    final membersByRoom = <String, List<Map<String, dynamic>>>{};
    for (final row in allMemberRows) {
      final member = Map<String, dynamic>.from(row as Map);
      final roomId = member['room_id'] as String?;
      if (roomId == null) {
        continue;
      }
      membersByRoom.putIfAbsent(roomId, () => []).add(member);
    }

    final rooms = <ChatRoom>[];
    for (final row in roomRows) {
      final room = _roomFromRow(
        Map<String, dynamic>.from(row as Map),
        membersByRoom,
        currentProfileId: user.id,
        mode: mode,
      );
      if (room != null) {
        rooms.add(room);
      }
    }
    return rooms;
  }

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
    final roomKey = _canonicalRoomKey(localRoomId);
    final sentByRpc = await _sendMessageWithRpc(
      roomKey: roomKey,
      title: title,
      senderMode: senderMode,
      senderName: senderName,
      targetRole: targetRole,
      participantName: participantName,
      message: message,
    );
    if (sentByRpc) {
      return;
    }

    final targetProfiles = await _targetProfilesForRoom(
      localRoomId: localRoomId,
      targetRole: targetRole,
    );

    final roomId = await _ensureRoom(
      localRoomId: localRoomId,
      title: title,
      senderProfile: senderProfile,
      senderMode: senderMode,
      senderName: senderName,
      targetProfiles: targetProfiles,
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

  Future<bool> _sendMessageWithRpc({
    required String roomKey,
    required String title,
    required AccountMode senderMode,
    required String senderName,
    required AccountMode? targetRole,
    required String participantName,
    required String message,
  }) async {
    try {
      await _client.rpc(
        'app_send_chat_message',
        params: {
          'p_room_key': roomKey,
          'p_room_type': _roomTypeFromKey(roomKey),
          'p_title': title,
          'p_sender_role': _roleToDb(senderMode),
          'p_sender_name': senderName,
          'p_target_role': targetRole == null ? null : _roleToDb(targetRole),
          'p_target_name': participantName,
          'p_message': message,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  ChatRoom? _roomFromRow(
    Map<String, dynamic> row,
    Map<String, List<Map<String, dynamic>>> membersByRoom, {
    required String currentProfileId,
    required AccountMode mode,
  }) {
    final roomId = row['id'] as String?;
    final roomKey = row['room_key'] as String?;
    if (roomId == null || roomKey == null) {
      return null;
    }

    final localRoomId = _localRoomIdForCanonicalKey(roomKey, mode);
    if (localRoomId == null) {
      return null;
    }

    final members = membersByRoom[roomId] ?? const [];
    final currentMember = members
        .where((member) => member['profile_id'] == currentProfileId)
        .firstOrNull;
    final participant = members
        .where((member) => member['profile_id'] != currentProfileId)
        .firstOrNull;
    final fallbackParticipant = members.firstOrNull;
    final displayParticipant = participant ?? fallbackParticipant;
    final participantRole = _roleLabel(
      displayParticipant?['member_role'] as String?,
    );
    final participantName =
        displayParticipant?['display_name'] as String? ?? participantRole;
    final lastMessageAt =
        DateTime.tryParse(row['last_message_at'] as String? ?? '') ??
        DateTime.tryParse(row['created_at'] as String? ?? '') ??
        DateTime.now();
    final rawTitle = row['title'] as String? ?? 'Chat';

    return ChatRoom(
      id: localRoomId,
      title: _displayTitleForRoom(
        rawTitle: rawTitle,
        roomKey: roomKey,
        mode: mode,
        participantRole: participantRole,
        participantName: participantName,
      ),
      participantRole: participantRole,
      participantName: participantName,
      lastMessage:
          row['last_message'] as String? ?? 'Room chat siap digunakan.',
      lastMessageAt: lastMessageAt,
      unreadCount: currentMember?['unread_count'] as int? ?? 0,
    );
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

  Future<List<Map<String, dynamic>>> _profilesByRole(AccountMode role) async {
    final rpcProfiles = await _profilesFromRpc('app_active_profiles_by_role', {
      'p_role': _roleToDb(role),
    });
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final rows = await _client
        .from('profiles')
        .select('id, full_name, role')
        .eq('role', _roleToDb(role))
        .eq('access_status', 'active')
        .order('created_at');

    return [for (final row in rows) Map<String, dynamic>.from(row as Map)];
  }

  Future<List<Map<String, dynamic>>> _targetProfilesForRoom({
    required String localRoomId,
    required AccountMode? targetRole,
  }) async {
    final roomKey = _canonicalRoomKey(localRoomId);
    final targetProfiles = await _contextTargetProfiles(
      roomKey: roomKey,
      targetRole: targetRole,
    );
    if (targetProfiles.isNotEmpty) {
      return targetProfiles;
    }
    if (targetRole == null) {
      return const [];
    }
    return _profilesByRole(targetRole);
  }

  Future<List<Map<String, dynamic>>> _contextTargetProfiles({
    required String roomKey,
    required AccountMode? targetRole,
  }) async {
    if (targetRole == AccountMode.provider &&
        roomKey.startsWith('customer_provider:')) {
      return _providerProfilesForLot(_contextId(roomKey));
    }

    if (roomKey.startsWith('customer_guard:')) {
      final ticketNumber = _contextId(roomKey);
      if (targetRole == AccountMode.parkingGuard) {
        final guards = await _guardProfilesForTicket(ticketNumber);
        if (guards.isNotEmpty) {
          return guards;
        }
        return _profilesByRole(AccountMode.parkingGuard);
      }
      if (targetRole == AccountMode.customer) {
        return _customerProfileForTicket(ticketNumber);
      }
    }

    if (roomKey.startsWith('provider_guard:')) {
      if (targetRole == AccountMode.parkingGuard) {
        return _currentProviderGuardProfiles();
      }
      if (targetRole == AccountMode.provider) {
        return _currentGuardProviderProfile();
      }
    }

    return const [];
  }

  String _contextId(String roomKey) {
    final separator = roomKey.indexOf(':');
    if (separator == -1 || separator == roomKey.length - 1) {
      return '';
    }
    return roomKey.substring(separator + 1);
  }

  Future<List<Map<String, dynamic>>> _providerProfilesForLot(
    String lotId,
  ) async {
    if (lotId.isEmpty) {
      return const [];
    }

    final rpcProfiles = await _profilesFromRpc('app_provider_profile_for_lot', {
      'p_parking_lot_id': lotId,
    });
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final rows = await _client
        .from('parking_lots')
        .select('providers(profiles(id, full_name, role, access_status))')
        .eq('id', lotId)
        .limit(1);
    if (rows.isEmpty) {
      return const [];
    }

    final lot = Map<String, dynamic>.from(rows.first as Map);
    final providerValue = lot['providers'];
    if (providerValue is! Map) {
      return const [];
    }

    final provider = Map<String, dynamic>.from(providerValue);
    final profileValue = provider['profiles'];
    if (profileValue is! Map) {
      return const [];
    }

    final profile = Map<String, dynamic>.from(profileValue);
    if (profile['access_status'] != 'active') {
      return const [];
    }
    return [profile];
  }

  Future<List<Map<String, dynamic>>> _guardProfilesForTicket(
    String ticketNumber,
  ) async {
    final rpcProfiles = await _profilesFromRpc(
      'app_guard_profiles_for_ticket',
      {'p_ticket_number': ticketNumber},
    );
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final lotId = await _parkingLotIdForTicket(ticketNumber);
    if (lotId == null) {
      return const [];
    }

    final rows = await _client
        .from('guard_lot_assignments')
        .select('parking_guards(profiles(id, full_name, role, access_status))')
        .eq('parking_lot_id', lotId);

    return _profilesFromGuardRows(rows);
  }

  Future<List<Map<String, dynamic>>> _customerProfileForTicket(
    String ticketNumber,
  ) async {
    if (ticketNumber.isEmpty) {
      return const [];
    }

    final rpcProfiles = await _profilesFromRpc(
      'app_customer_profile_for_ticket',
      {'p_ticket_number': ticketNumber},
    );
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final rows = await _client
        .from('bookings')
        .select('customers(profiles(id, full_name, role, access_status))')
        .eq('ticket_number', ticketNumber.toUpperCase())
        .limit(1);
    if (rows.isEmpty) {
      return const [];
    }

    final booking = Map<String, dynamic>.from(rows.first as Map);
    final customerValue = booking['customers'];
    if (customerValue is! Map) {
      return const [];
    }

    final customer = Map<String, dynamic>.from(customerValue);
    final profileValue = customer['profiles'];
    if (profileValue is! Map) {
      return const [];
    }

    final profile = Map<String, dynamic>.from(profileValue);
    if (profile['access_status'] != 'active') {
      return const [];
    }
    return [profile];
  }

  Future<List<Map<String, dynamic>>> _currentProviderGuardProfiles() async {
    final rpcProfiles = await _profilesFromRpc(
      'app_current_provider_guard_profiles',
    );
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final providerRows = await _client
        .from('providers')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);
    if (providerRows.isEmpty) {
      return const [];
    }

    final providerId = (providerRows.first as Map)['id'] as String?;
    if (providerId == null) {
      return const [];
    }

    final rows = await _client
        .from('parking_guards')
        .select('profiles(id, full_name, role, access_status)')
        .eq('provider_id', providerId);

    return _profilesFromDirectRows(rows);
  }

  Future<List<Map<String, dynamic>>> _currentGuardProviderProfile() async {
    final rpcProfiles = await _profilesFromRpc(
      'app_current_guard_provider_profile',
    );
    if (rpcProfiles.isNotEmpty) {
      return rpcProfiles;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final rows = await _client
        .from('parking_guards')
        .select('providers(profiles(id, full_name, role, access_status))')
        .eq('profile_id', user.id)
        .limit(1);
    if (rows.isEmpty) {
      return const [];
    }

    final guard = Map<String, dynamic>.from(rows.first as Map);
    final providerValue = guard['providers'];
    if (providerValue is! Map) {
      return const [];
    }

    final provider = Map<String, dynamic>.from(providerValue);
    final profileValue = provider['profiles'];
    if (profileValue is! Map) {
      return const [];
    }

    final profile = Map<String, dynamic>.from(profileValue);
    if (profile['access_status'] != 'active') {
      return const [];
    }
    return [profile];
  }

  Future<String?> _parkingLotIdForTicket(String ticketNumber) async {
    if (ticketNumber.isEmpty) {
      return null;
    }

    final rows = await _client
        .from('bookings')
        .select('parking_lot_id')
        .eq('ticket_number', ticketNumber.toUpperCase())
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return (rows.first as Map)['parking_lot_id'] as String?;
  }

  Future<List<Map<String, dynamic>>> _profilesFromRpc(
    String functionName, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final value = await _client.rpc(functionName, params: params);
      if (value is! List) {
        return const [];
      }
      return [
        for (final row in value)
          if (row is Map) Map<String, dynamic>.from(row),
      ];
    } catch (_) {
      return const [];
    }
  }

  List<Map<String, dynamic>> _profilesFromGuardRows(List<dynamic> rows) {
    final profiles = <Map<String, dynamic>>[];
    for (final row in rows) {
      final assignment = Map<String, dynamic>.from(row as Map);
      final guardValue = assignment['parking_guards'];
      if (guardValue is! Map) {
        continue;
      }
      final guard = Map<String, dynamic>.from(guardValue);
      final profileValue = guard['profiles'];
      if (profileValue is! Map) {
        continue;
      }
      final profile = Map<String, dynamic>.from(profileValue);
      if (profile['access_status'] == 'active') {
        profiles.add(profile);
      }
    }
    return profiles;
  }

  List<Map<String, dynamic>> _profilesFromDirectRows(List<dynamic> rows) {
    final profiles = <Map<String, dynamic>>[];
    for (final row in rows) {
      final value = Map<String, dynamic>.from(row as Map)['profiles'];
      if (value is! Map) {
        continue;
      }
      final profile = Map<String, dynamic>.from(value);
      if (profile['access_status'] == 'active') {
        profiles.add(profile);
      }
    }
    return profiles;
  }

  Future<String> _ensureRoom({
    required String localRoomId,
    required String title,
    required Map<String, dynamic> senderProfile,
    required AccountMode senderMode,
    required String senderName,
    required List<Map<String, dynamic>> targetProfiles,
    required String participantName,
  }) async {
    final roomKey = _canonicalRoomKey(localRoomId);
    final existingRooms = await _client
        .from('chat_rooms')
        .select('id')
        .eq('room_key', roomKey)
        .limit(1);

    if (existingRooms.isNotEmpty) {
      final roomId = (existingRooms.first as Map)['id'] as String;
      try {
        await _ensureRoomMembers(
          roomId: roomId,
          senderProfile: senderProfile,
          senderMode: senderMode,
          senderName: senderName,
          targetProfiles: targetProfiles,
          participantName: participantName,
        );
      } catch (_) {
        // Existing rooms may have stricter RLS for adding members. Keep sending
        // the message if the current user is already a room member.
      }
      return roomId;
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
    await _ensureRoomMembers(
      roomId: roomId,
      senderProfile: senderProfile,
      senderMode: senderMode,
      senderName: senderName,
      targetProfiles: targetProfiles,
      participantName: participantName,
    );
    return roomId;
  }

  Future<void> _ensureRoomMembers({
    required String roomId,
    required Map<String, dynamic> senderProfile,
    required AccountMode senderMode,
    required String senderName,
    required List<Map<String, dynamic>> targetProfiles,
    required String participantName,
  }) async {
    final members = [
      {
        'room_id': roomId,
        'profile_id': senderProfile['id'],
        'member_role': _roleToDb(senderMode),
        'display_name': senderName.isEmpty
            ? senderProfile['full_name']
            : senderName,
      },
      for (final targetProfile in targetProfiles)
        {
          'room_id': roomId,
          'profile_id': targetProfile['id'],
          'member_role': targetProfile['role'],
          'display_name': participantName.isEmpty
              ? targetProfile['full_name']
              : participantName,
        },
    ];

    await _client
        .from('chat_room_members')
        .upsert(members, onConflict: 'room_id,profile_id');
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

  String _displayTitleForRoom({
    required String rawTitle,
    required String roomKey,
    required AccountMode mode,
    required String participantRole,
    required String participantName,
  }) {
    final normalizedTitle = rawTitle.trim();
    final looksLikeTicketTitle =
        normalizedTitle.contains(RegExp(r'TKT-\d+', caseSensitive: false)) ||
        normalizedTitle.toLowerCase().startsWith('chat customer -') ||
        normalizedTitle.toLowerCase().startsWith('chat penjaga -');
    if (!looksLikeTicketTitle) {
      return normalizedTitle.isEmpty ? 'Percakapan' : normalizedTitle;
    }

    if (roomKey.startsWith('customer_guard:')) {
      if (mode == AccountMode.customer) {
        return participantName.toLowerCase().contains('penjaga')
            ? participantName
            : 'Penjaga Parkir';
      }
      if (mode == AccountMode.parkingGuard) {
        return participantName.toLowerCase().contains('customer')
            ? 'Customer Parkir'
            : participantName;
      }
    }

    if (roomKey.startsWith('customer_provider:')) {
      return mode == AccountMode.customer ? participantName : 'Customer Parkir';
    }

    if (roomKey.startsWith('customer_admin:')) {
      return mode == AccountMode.customer ? 'Admin Aplikasi' : participantName;
    }

    if (roomKey.startsWith('provider_guard:')) {
      return participantName;
    }

    return participantRole;
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

  String? _localRoomIdForCanonicalKey(String roomKey, AccountMode mode) {
    final separator = roomKey.indexOf(':');
    if (separator == -1 || separator == roomKey.length - 1) {
      return null;
    }

    final type = roomKey.substring(0, separator);
    final contextId = roomKey.substring(separator + 1);
    return switch ((type, mode)) {
      ('customer_provider', AccountMode.customer) =>
        'customer-provider-$contextId',
      ('customer_provider', AccountMode.provider) =>
        'provider-customer-$contextId',
      ('customer_guard', AccountMode.customer) => 'customer-guard-$contextId',
      ('customer_guard', AccountMode.parkingGuard) =>
        'guard-customer-$contextId',
      ('customer_admin', AccountMode.customer) => 'customer-admin-$contextId',
      ('customer_admin', AccountMode.superAdmin) =>
        'superadmin-customer-$contextId',
      ('provider_guard', AccountMode.provider) => 'provider-guard-$contextId',
      ('provider_guard', AccountMode.parkingGuard) =>
        'guard-provider-$contextId',
      ('provider_admin', AccountMode.provider) =>
        'provider-superadmin-$contextId',
      ('provider_admin', AccountMode.superAdmin) =>
        'superadmin-provider-$contextId',
      ('guard_admin', AccountMode.parkingGuard) => 'guard-admin-$contextId',
      ('guard_admin', AccountMode.superAdmin) => 'superadmin-guard-$contextId',
      ('group', _) => contextId,
      _ => null,
    };
  }
}
