import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_cepat/app.dart';
import 'package:parkir_cepat/models/app_models.dart';

void main() {
  AppState signedIn(AccountMode mode, {AccountStatus? status}) {
    return AppState.seeded().copyWith(
      isAuthenticated: true,
      currentMode: mode,
      accountStatus: status ?? AccountStatus.verified,
    );
  }

  group('app language preferences', () {
    test('maps saved language to runtime locale', () {
      expect(appLocaleForLanguage('Indonesia').languageCode, 'id');
      expect(appLocaleForLanguage('English').languageCode, 'en');
      expect(appLocaleForLanguage('english').languageCode, 'en');
    });

    test('returns localized account settings labels', () {
      expect(appText('Indonesia').accountSettingsTitle, 'Pengaturan Akun');
      expect(appText('English').accountSettingsTitle, 'Account Settings');
      expect(appText('English').saveSettings, 'Save Settings');
    });
  });

  group('guardedRedirect', () {
    test('redirects unauthenticated private routes to login', () {
      final redirect = guardedRedirect(
        '/customer/home',
        () => AppState.seeded(),
      );

      expect(redirect, '/login');
    });

    test('allows exact role sections only', () {
      expect(
        guardedRedirect('/customer/home', () => signedIn(AccountMode.customer)),
        isNull,
      );
      expect(
        guardedRedirect(
          '/customer-fake/home',
          () => signedIn(AccountMode.customer),
        ),
        '/customer/home',
      );
    });

    test('redirects users away from other role dashboards', () {
      expect(
        guardedRedirect(
          '/super-admin/dashboard',
          () => signedIn(AccountMode.customer),
        ),
        '/customer/home',
      );
      expect(
        guardedRedirect(
          '/customer/home',
          () => signedIn(AccountMode.parkingGuard),
        ),
        '/guard/dashboard',
      );
      expect(
        guardedRedirect(
          '/admin/dashboard',
          () => signedIn(AccountMode.superAdmin),
        ),
        '/super-admin/dashboard',
      );
    });

    test('allows provider legacy admin routes but blocks them for guards', () {
      expect(
        guardedRedirect(
          '/admin/dashboard',
          () => signedIn(AccountMode.provider),
        ),
        isNull,
      );
      expect(
        guardedRedirect(
          '/admin/dashboard',
          () => signedIn(AccountMode.parkingGuard),
        ),
        '/guard/dashboard',
      );
    });

    test('keeps pending providers on verification route', () {
      expect(
        guardedRedirect(
          '/provider/dashboard',
          () => signedIn(AccountMode.provider, status: AccountStatus.pending),
        ),
        '/provider-verification',
      );
      expect(
        guardedRedirect(
          '/provider-verification',
          () => signedIn(AccountMode.provider, status: AccountStatus.pending),
        ),
        isNull,
      );
    });
  });
}
