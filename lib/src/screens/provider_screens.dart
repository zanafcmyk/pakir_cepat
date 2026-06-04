import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(appRepositoryProvider).fetchParkingLocations();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Penyedia')),
      body: FutureBuilder(
        future: locationsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final locations = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Total lokasi: ${locations.length}'))),
              const SizedBox(height: 12),
              for (final item in locations)
                Card(
                  child: ListTile(
                    title: Text(item.parkingName),
                    subtitle: Text('${item.availableSlots}/${item.totalSlots} slot tersedia'),
                    trailing: Text('Rp${item.parkingPrice}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
class ProviderLocationScreen extends StatelessWidget {
  const ProviderLocationScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Provider Locations')));
}
class ProviderMonitoringScreen extends StatelessWidget {
  const ProviderMonitoringScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Monitoring')));
}
class ProviderStatisticsScreen extends StatelessWidget {
  const ProviderStatisticsScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Statistics')));
}
class ProviderPendingScreen extends StatelessWidget {
  const ProviderPendingScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Menunggu verifikasi')));
}
