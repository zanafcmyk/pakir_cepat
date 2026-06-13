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
