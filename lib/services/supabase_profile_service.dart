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
}
