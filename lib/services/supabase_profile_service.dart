import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService {
  SupabaseProfileService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> updateCurrentUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    if ((user.email ?? '').toLowerCase() != email.toLowerCase()) {
      await _client.auth.updateUser(UserAttributes(email: email));
    }

    await _client
        .from('profiles')
        .update({'full_name': name, 'email': email, 'phone_number': phone})
        .eq('id', user.id);
  }

  Future<String?> uploadCurrentUserAvatar(Uint8List bytes) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final path =
        '${user.id}/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final url = _client.storage.from('avatars').getPublicUrl(path);
    await _client
        .from('profiles')
        .update({'avatar_url': url})
        .eq('id', user.id);
    return url;
  }

  Future<void> removeCurrentUserAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', user.id);
  }
}
