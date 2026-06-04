import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/app_router.dart';
import 'src/core/app_theme.dart';

class ParkirCepatApp extends ConsumerWidget {
  const ParkirCepatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Parkir Cepat',
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
