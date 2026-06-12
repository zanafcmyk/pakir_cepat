import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileSettings {
  const SupabaseProfileSettings({
    required this.primaryNotificationEnabled,
    required this.secondaryNotificationEnabled,
    required this.reportNotificationEnabled,
    required this.selectedLanguage,
    required this.accountSecurityEnabled,
  });

  final bool primaryNotificationEnabled;
  final bool secondaryNotificationEnabled;
  final bool reportNotificationEnabled;
  final String selectedLanguage;
  final bool accountSecurityEnabled;

  factory SupabaseProfileSettings.defaults() {
    return const SupabaseProfileSettings(
      primaryNotificationEnabled: true,
      secondaryNotificationEnabled: true,
      reportNotificationEnabled: true,
      selectedLanguage: 'Indonesia',
      accountSecurityEnabled: true,
    );
  }

  factory SupabaseProfileSettings.fromRow(Map<String, dynamic> row) {
    return SupabaseProfileSettings(
      primaryNotificationEnabled:
          row['primary_notification_enabled'] as bool? ?? true,
      secondaryNotificationEnabled:
          row['secondary_notification_enabled'] as bool? ?? true,
      reportNotificationEnabled:
          row['report_notification_enabled'] as bool? ?? true,
      selectedLanguage: row['selected_language'] as String? ?? 'Indonesia',
      accountSecurityEnabled: row['account_security_enabled'] as bool? ?? true,
    );
  }
}

class SupabaseProfileSettingsService {
  SupabaseProfileSettingsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SupabaseProfileSettings> fetchCurrentProfileSettings() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return SupabaseProfileSettings.defaults();
    }

    final rows = await _client
        .from('profile_settings')
        .select(
          'primary_notification_enabled, secondary_notification_enabled, '
          'report_notification_enabled, selected_language, '
          'account_security_enabled',
        )
        .eq('profile_id', user.id)
        .limit(1);

    if (rows.isEmpty) {
      return SupabaseProfileSettings.defaults();
    }

    return SupabaseProfileSettings.fromRow(rows.first);
  }

  Future<void> saveCurrentProfileSettings({
    required bool primaryNotificationEnabled,
    required bool secondaryNotificationEnabled,
    required bool reportNotificationEnabled,
    required String selectedLanguage,
    required bool accountSecurityEnabled,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('profile_settings').upsert({
      'profile_id': user.id,
      'primary_notification_enabled': primaryNotificationEnabled,
      'secondary_notification_enabled': secondaryNotificationEnabled,
      'report_notification_enabled': reportNotificationEnabled,
      'selected_language': selectedLanguage,
      'account_security_enabled': accountSecurityEnabled,
    }, onConflict: 'profile_id');
  }
}
