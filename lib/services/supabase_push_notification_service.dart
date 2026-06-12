import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePushNotificationService {
  SupabasePushNotificationService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> registerCurrentDeviceToken({
    required String token,
    required String platform,
    String? deviceName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null || token.trim().isEmpty) {
      return;
    }

    await _client.from('device_push_tokens').upsert({
      'profile_id': user.id,
      'token': token.trim(),
      'platform': platform,
      'device_name': deviceName,
      'last_seen_at': DateTime.now().toIso8601String(),
    }, onConflict: 'token');
  }

  Future<void> unregisterDeviceToken(String token) async {
    final user = _client.auth.currentUser;
    if (user == null || token.trim().isEmpty) {
      return;
    }

    await _client
        .from('device_push_tokens')
        .delete()
        .eq('profile_id', user.id)
        .eq('token', token.trim());
  }
}
