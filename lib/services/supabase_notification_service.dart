import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseNotificationService {
  SupabaseNotificationService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<NoticeItem>> fetchCurrentUserNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final rows = await _client
        .from('notifications')
        .select('title, message, type, created_at')
        .eq('profile_id', user.id)
        .order('created_at', ascending: false);

    return [for (final row in rows) _noticeFromRow(row)];
  }

  Future<void> saveCurrentUserNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('notifications').insert({
      'profile_id': user.id,
      'title': title,
      'message': message,
      'type': type,
    });
  }

  Future<void> saveRoleNotification({
    required AccountMode role,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      await _client.rpc(
        'app_create_notifications_for_role',
        params: {
          'p_role': _roleToDb(role),
          'p_title': title,
          'p_message': message,
          'p_type': type,
        },
      );
      return;
    } catch (_) {
      // Fall back to direct table access when the optional RLS patch is absent.
    }

    final rows = await _client
        .from('profiles')
        .select('id')
        .eq('role', _roleToDb(role))
        .eq('access_status', 'active');

    if (rows.isEmpty) {
      return;
    }

    await _client.from('notifications').insert([
      for (final row in rows)
        {
          'profile_id': Map<String, dynamic>.from(row as Map)['id'],
          'title': title,
          'message': message,
          'type': type,
        },
    ]);
  }

  Future<bool> saveProviderNotification({
    required String providerId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      final result = await _client.rpc(
        'app_create_provider_notification',
        params: {
          'p_provider_id': providerId,
          'p_title': title,
          'p_message': message,
          'p_type': type,
        },
      );
      return result == true;
    } catch (_) {
      // Fall back to direct table access when the optional RLS patch is absent.
    }

    final rows = await _client
        .from('providers')
        .select('profiles(id, access_status)')
        .eq('id', providerId)
        .limit(1);

    if (rows.isEmpty) {
      return false;
    }

    final provider = Map<String, dynamic>.from(rows.first as Map);
    final profileValue = provider['profiles'];
    if (profileValue is! Map) {
      return false;
    }

    final profile = Map<String, dynamic>.from(profileValue);
    if (profile['access_status'] != 'active') {
      return false;
    }

    await saveProfileNotification(
      profileId: profile['id'] as String,
      title: title,
      message: message,
      type: type,
    );
    return true;
  }

  Future<bool> saveAssignedGuardNotifications({
    required String parkingLotId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      final result = await _client.rpc(
        'app_create_guard_notifications_for_lot',
        params: {
          'p_parking_lot_id': parkingLotId,
          'p_title': title,
          'p_message': message,
          'p_type': type,
        },
      );
      return (result as num?)?.toInt() != 0;
    } catch (_) {
      // Fall back to direct table access when the optional RLS patch is absent.
    }

    final rows = await _client
        .from('guard_lot_assignments')
        .select('parking_guards(profiles(id, access_status))')
        .eq('parking_lot_id', parkingLotId);

    final notificationRows = <Map<String, dynamic>>[];
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
      if (profile['access_status'] != 'active') {
        continue;
      }

      notificationRows.add({
        'profile_id': profile['id'],
        'title': title,
        'message': message,
        'type': type,
      });
    }

    if (notificationRows.isEmpty) {
      return false;
    }

    await _client.from('notifications').insert(notificationRows);
    return true;
  }

  Future<void> saveProfileNotification({
    required String profileId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      await _client.rpc(
        'app_create_notification',
        params: {
          'p_profile_id': profileId,
          'p_title': title,
          'p_message': message,
          'p_type': type,
        },
      );
      return;
    } catch (_) {
      // Fall back to direct table access when the optional RLS patch is absent.
    }

    await _client.from('notifications').insert({
      'profile_id': profileId,
      'title': title,
      'message': message,
      'type': type,
    });
  }

  String _roleToDb(AccountMode mode) => switch (mode) {
    AccountMode.superAdmin => 'super_admin',
    AccountMode.provider => 'provider',
    AccountMode.parkingGuard => 'parking_guard',
    AccountMode.customer => 'customer',
  };

  NoticeItem _noticeFromRow(Map<String, dynamic> row) {
    final type = row['type'] as String? ?? 'info';
    final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');

    return NoticeItem(
      title: row['title'] as String? ?? 'Notifikasi',
      message: row['message'] as String? ?? '',
      timeLabel: createdAt == null ? 'Baru saja' : _timeLabel(createdAt),
      icon: _iconForType(type),
      accent: _accentForType(type),
    );
  }

  String _timeLabel(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    }

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'booking' => Icons.local_parking_rounded,
      'payment' => Icons.payments_rounded,
      'vehicle_entry' => Icons.login_rounded,
      'vehicle_exit' => Icons.logout_rounded,
      'complaint' => Icons.support_agent_rounded,
      'verification' => Icons.verified_user_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color _accentForType(String type) {
    return switch (type) {
      'booking' => const Color(0xFF1F6BFF),
      'payment' => const Color(0xFF0F9D7A),
      'vehicle_entry' => const Color(0xFF0F9D7A),
      'vehicle_exit' => const Color(0xFF1F6BFF),
      'complaint' => const Color(0xFFD97706),
      'verification' => const Color(0xFF0F9D7A),
      _ => const Color(0xFF64748B),
    };
  }
}
