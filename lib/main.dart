// Konfigurasi runtime Supabase. Baca dari --dart-define:
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
// Fallback ke nilai bawaan agar build lama tidak break.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

class AppEnv {
  const AppEnv._();

  static const _url = String.fromEnvironment('SUPABASE_URL');

  static const _key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static String get supabaseUrl => _url;
  static String get supabasePublishableKey => _key;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final url = AppEnv.supabaseUrl;
  final key = AppEnv.supabasePublishableKey;

  if (url.isEmpty || key.isEmpty) {
    throw StateError(
      'Supabase env kosong. Jalankan dengan: '
      'flutter run --dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_PUBLISHABLE_KEY=...',
    );
  }

  if (kDebugMode) {
    final masked = key.length <= 8
        ? '****'
        : '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
    print('Supabase init: url=$url key=$masked');
  }

  await Supabase.initialize(url: url, publishableKey: key);

  runApp(const ProviderScope(child: ParkirCepatApp()));
}
