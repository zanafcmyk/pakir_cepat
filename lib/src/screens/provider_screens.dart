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
              _SummaryGrid(totalLocations: locations.length),
              const SizedBox(height: 16),
              const Text('Lokasi aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final item in locations) ...[
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.local_parking_rounded, color: Color(0xFF2563EB)),
                    ),
                    title: Text(item.parkingName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.availableSlots}/${item.totalSlots} slot tersedia'),
                    trailing: Text('Rp${item.parkingPrice.toStringAsFixed(0)}'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.totalLocations});
  final int totalLocations;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatTile(label: 'Total lokasi', value: '$totalLocations'),
          const _StatTile(label: 'Slot aktif', value: '24'),
          const _StatTile(label: 'Reservasi', value: '08'),
          const _StatTile(label: 'Pendapatan', value: 'Rp 1.2jt'),
        ],
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 170,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
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