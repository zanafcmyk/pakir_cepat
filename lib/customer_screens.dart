import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard User')),
    body: const Center(child: Text('UI user overview')),
  );
}
class VehicleScreen extends StatelessWidget { const VehicleScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Vehicles'))); }
class BookingScreen extends StatelessWidget { const BookingScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Bookings'))); }
class TicketScreen extends StatelessWidget { const TicketScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tickets'))); }
class HistoryScreen extends StatelessWidget { const HistoryScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('History'))); }
