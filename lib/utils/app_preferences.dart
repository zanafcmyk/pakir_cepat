import 'package:flutter/widgets.dart';

bool isEnglishLanguage(String language) {
  return language.trim().toLowerCase().startsWith('english');
}

Locale appLocaleForLanguage(String language) {
  return isEnglishLanguage(language) ? const Locale('en') : const Locale('id');
}

AppPreferenceText appText(String language) {
  return isEnglishLanguage(language)
      ? AppPreferenceText.english()
      : AppPreferenceText.indonesia();
}

class AppPreferenceText {
  const AppPreferenceText({
    required this.appTitle,
    required this.accountSettingsTitle,
    required this.notificationSection,
    required this.accountPreferenceSection,
    required this.bookingNotification,
    required this.paymentNotification,
    required this.promoNotification,
    required this.appLanguage,
    required this.accountSecurityMode,
    required this.accountSecuritySubtitle,
    required this.saveSettings,
    required this.saving,
    required this.saved,
    required this.customerSettingsFailure,
    required this.roleSettingsSubtitle,
    required this.providerSettingsTitle,
    required this.guardSettingsTitle,
    required this.providerPrimaryNotification,
    required this.providerSecondaryNotification,
    required this.providerReportNotification,
    required this.guardPrimaryNotification,
    required this.guardSecondaryNotification,
    required this.guardReportNotification,
    required this.roleSettingsFailure,
  });

  final String appTitle;
  final String accountSettingsTitle;
  final String notificationSection;
  final String accountPreferenceSection;
  final String bookingNotification;
  final String paymentNotification;
  final String promoNotification;
  final String appLanguage;
  final String accountSecurityMode;
  final String accountSecuritySubtitle;
  final String saveSettings;
  final String saving;
  final String saved;
  final String customerSettingsFailure;
  final String roleSettingsSubtitle;
  final String providerSettingsTitle;
  final String guardSettingsTitle;
  final String providerPrimaryNotification;
  final String providerSecondaryNotification;
  final String providerReportNotification;
  final String guardPrimaryNotification;
  final String guardSecondaryNotification;
  final String guardReportNotification;
  final String roleSettingsFailure;

  factory AppPreferenceText.indonesia() {
    return const AppPreferenceText(
      appTitle: 'Parkir Cepat',
      accountSettingsTitle: 'Pengaturan Akun',
      notificationSection: 'Notifikasi',
      accountPreferenceSection: 'Preferensi akun',
      bookingNotification: 'Notifikasi booking',
      paymentNotification: 'Notifikasi pembayaran',
      promoNotification: 'Notifikasi promo',
      appLanguage: 'Bahasa aplikasi',
      accountSecurityMode: 'Mode keamanan akun',
      accountSecuritySubtitle:
          'Sesi login tetap aktif sampai Anda logout dari aplikasi.',
      saveSettings: 'Simpan Pengaturan',
      saving: 'Menyimpan...',
      saved: 'Pengaturan akun berhasil disimpan.',
      customerSettingsFailure: 'Gagal menyimpan pengaturan ke Supabase.',
      roleSettingsSubtitle: 'Preferensi akun ini disimpan di Supabase.',
      providerSettingsTitle: 'Pengaturan Penyedia',
      guardSettingsTitle: 'Pengaturan Penjaga',
      providerPrimaryNotification: 'Notifikasi booking masuk',
      providerSecondaryNotification: 'Notifikasi pembayaran',
      providerReportNotification: 'Notifikasi laporan harian',
      guardPrimaryNotification: 'Notifikasi tugas lokasi',
      guardSecondaryNotification: 'Notifikasi scan QR',
      guardReportNotification: 'Notifikasi aktivitas shift',
      roleSettingsFailure:
          'Gagal menyimpan pengaturan. Pastikan SQL profile_settings sudah dijalankan.',
    );
  }

  factory AppPreferenceText.english() {
    return const AppPreferenceText(
      appTitle: 'Fast Parking',
      accountSettingsTitle: 'Account Settings',
      notificationSection: 'Notifications',
      accountPreferenceSection: 'Account preferences',
      bookingNotification: 'Booking notifications',
      paymentNotification: 'Payment notifications',
      promoNotification: 'Promo notifications',
      appLanguage: 'App language',
      accountSecurityMode: 'Account security mode',
      accountSecuritySubtitle:
          'Login sessions stay active until you sign out of the app.',
      saveSettings: 'Save Settings',
      saving: 'Saving...',
      saved: 'Account settings saved.',
      customerSettingsFailure: 'Failed to save settings to Supabase.',
      roleSettingsSubtitle: 'These account preferences are stored in Supabase.',
      providerSettingsTitle: 'Provider Settings',
      guardSettingsTitle: 'Guard Settings',
      providerPrimaryNotification: 'Incoming booking notifications',
      providerSecondaryNotification: 'Payment notifications',
      providerReportNotification: 'Daily report notifications',
      guardPrimaryNotification: 'Location task notifications',
      guardSecondaryNotification: 'QR scan notifications',
      guardReportNotification: 'Shift activity notifications',
      roleSettingsFailure:
          'Failed to save settings. Make sure profile_settings SQL has been run.',
    );
  }
}
