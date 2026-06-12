import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCustomerSettings {
  const SupabaseCustomerSettings({
    required this.bookingNotificationEnabled,
    required this.paymentNotificationEnabled,
    required this.promoNotificationEnabled,
    required this.selectedLanguage,
    required this.accountSecurityEnabled,
  });

  final bool bookingNotificationEnabled;
  final bool paymentNotificationEnabled;
  final bool promoNotificationEnabled;
  final String selectedLanguage;
  final bool accountSecurityEnabled;

  factory SupabaseCustomerSettings.fromRow(Map<String, dynamic> row) {
    return SupabaseCustomerSettings(
      bookingNotificationEnabled:
          row['booking_notification_enabled'] as bool? ?? true,
      paymentNotificationEnabled:
          row['payment_notification_enabled'] as bool? ?? true,
      promoNotificationEnabled:
          row['promo_notification_enabled'] as bool? ?? false,
      selectedLanguage: row['selected_language'] as String? ?? 'Indonesia',
      accountSecurityEnabled: row['account_security_enabled'] as bool? ?? true,
    );
  }
}

class SupabaseCustomerSettingsService {
  SupabaseCustomerSettingsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SupabaseCustomerSettings?> fetchCurrentCustomerSettings() async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return null;
    }

    final rows = await _client
        .from('customer_settings')
        .select(
          'booking_notification_enabled, payment_notification_enabled, '
          'promo_notification_enabled, selected_language, '
          'account_security_enabled',
        )
        .eq('customer_id', customerId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    return SupabaseCustomerSettings.fromRow(rows.first);
  }

  Future<void> saveCurrentCustomerSettings({
    required bool bookingNotificationEnabled,
    required bool paymentNotificationEnabled,
    required bool promoNotificationEnabled,
    required String selectedLanguage,
    required bool accountSecurityEnabled,
  }) async {
    final customerId = await _currentCustomerId();
    if (customerId == null) {
      return;
    }

    await _client.from('customer_settings').upsert({
      'customer_id': customerId,
      'booking_notification_enabled': bookingNotificationEnabled,
      'payment_notification_enabled': paymentNotificationEnabled,
      'promo_notification_enabled': promoNotificationEnabled,
      'selected_language': selectedLanguage,
      'account_security_enabled': accountSecurityEnabled,
    }, onConflict: 'customer_id');
  }

  Future<String?> _currentCustomerId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rows = await _client
        .from('customers')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['id'] as String?;
  }
}
