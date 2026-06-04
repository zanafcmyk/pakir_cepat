import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(appRepositoryProvider).fetchParkingLocations();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Pengguna')),
      body: FutureBuilder(
        future: locationsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final locations = snapshot.data ?? const [];
          if (locations.isEmpty) {
            return const Center(child: Text('Belum ada lokasi parkir'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = locations[index];
              return Card(
                child: ListTile(
                  title: Text(item.parkingName),
                  subtitle: Text(
                    '${item.address}\nSlot: ${item.availableSlots}/${item.totalSlots} ? Rp${item.parkingPrice}',
                  ),
                  isThreeLine: true,
                  leading: const Icon(Icons.local_parking),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Vehicles')));
}
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Bookings')));
}
class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tickets')));
}
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('History')));
}
