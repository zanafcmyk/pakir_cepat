import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wdtjrzynjygkmpmhiffw.supabase.co',
    publishableKey: 'sb_publishable_onxQFKPMNnA6SssvB4nG1g_n3fOs74R',
  );

  runApp(const ProviderScope(child: ParkirCepatApp()));
}
