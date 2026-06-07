import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StatGrid(
            stats: [
              _StatData('Pengguna', 'Semua role', Icons.groups_rounded),
              _StatData('Verifikasi', 'Penyedia, pelanggan, penjaga', Icons.verified_user_rounded),
              _StatData('Transaksi', 'Semua lokasi', Icons.receipt_long_rounded),
              _StatData('Komplain', 'Antrian bantuan', Icons.support_agent_rounded),
            ],
          ),
          SizedBox(height: 16),
          _InfoCard(
            title: 'Kontrol aplikasi',
            body:
                'Super Admin memantau pelanggan, penyedia parkir, penjaga parkir, laporan semua lokasi, transaksi, komplain, dan akun bermasalah.',
          ),
        ],
      ),
    );
  }
}

class ParkingGuardDashboardScreen extends ConsumerWidget {
  const ParkingGuardDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final userId = session?.session?.user.id;
    final locationsFuture = userId == null
        ? Future.value(const [])
        : ref.watch(appRepositoryProvider).fetchGuardParkingLocations(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Penjaga Parkir')),
      body: FutureBuilder(
        future: locationsFuture,
        builder: (context, snapshot) {
          final locations = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatGrid(
                stats: [
                  _StatData('Lokasi akses', '${locations.length}', Icons.local_parking_rounded),
                  const _StatData('Scan QR', 'Tiket pelanggan', Icons.qr_code_scanner_rounded),
                  const _StatData('Masuk/Keluar', 'Verifikasi kendaraan', Icons.directions_car_rounded),
                  const _StatData('Tunai', 'Konfirmasi manual', Icons.payments_rounded),
                ],
              ),
              const SizedBox(height: 16),
              const _InfoCard(
                title: 'Batas akses penjaga',
                body:
                    'Penjaga hanya dapat melihat lokasi parkir yang ditugaskan oleh penyedia parkir pembuat akunnya.',
              ),
              const SizedBox(height: 16),
              for (final location in locations)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_parking_rounded),
                    title: Text(location.parkingName),
                    subtitle: Text('${location.availableSlots}/${location.totalSlots} slot tersedia'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ParkingGuardManagementScreen extends ConsumerStatefulWidget {
  const ParkingGuardManagementScreen({super.key});

  @override
  ConsumerState<ParkingGuardManagementScreen> createState() =>
      _ParkingGuardManagementScreenState();
}

class _ParkingGuardManagementScreenState
    extends ConsumerState<ParkingGuardManagementScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final selectedLocationIds = <String>{};
  bool canScanQr = true;
  bool canConfirmCash = true;
  bool canManageSlots = true;
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final providerId = session?.session?.user.id;
    final locationsFuture = providerId == null
        ? Future.value(const [])
        : ref.watch(appRepositoryProvider).fetchProviderParkingLocations(providerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Akun Penjaga Parkir')),
      body: FutureBuilder(
        future: locationsFuture,
        builder: (context, snapshot) {
          final locations = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama penjaga')),
              const SizedBox(height: 12),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email login')),
              const SizedBox(height: 12),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Nomor HP')),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password sementara'),
              ),
              const SizedBox(height: 16),
              const Text('Lokasi yang boleh diakses', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final location in locations)
                CheckboxListTile(
                  value: selectedLocationIds.contains(location.id),
                  title: Text(location.parkingName),
                  subtitle: Text(location.address),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        selectedLocationIds.add(location.id);
                      } else {
                        selectedLocationIds.remove(location.id);
                      }
                    });
                  },
                ),
              SwitchListTile(
                value: canScanQr,
                title: const Text('Boleh scan QR tiket'),
                onChanged: (value) => setState(() => canScanQr = value),
              ),
              SwitchListTile(
                value: canConfirmCash,
                title: const Text('Boleh konfirmasi pembayaran tunai'),
                onChanged: (value) => setState(() => canConfirmCash = value),
              ),
              SwitchListTile(
                value: canManageSlots,
                title: const Text('Boleh update status slot'),
                onChanged: (value) => setState(() => canManageSlots = value),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: loading || providerId == null || selectedLocationIds.isEmpty
                    ? null
                    : () async {
                        setState(() => loading = true);
                        await ref.read(authRepositoryProvider).createParkingGuard(
                              providerId: providerId,
                              fullName: name.text.trim(),
                              email: email.text.trim(),
                              phone: phone.text.trim(),
                              password: password.text,
                              assignedLocationIds: selectedLocationIds.toList(),
                              canScanQr: canScanQr,
                              canConfirmCash: canConfirmCash,
                              canManageSlots: canManageSlots,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Akun penjaga berhasil dibuat.')),
                          );
                        }
                        if (mounted) setState(() => loading = false);
                      },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(loading ? 'Membuat...' : 'Buat akun penjaga'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_StatData> stats;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final item in stats)
            SizedBox(
              width: 170,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon),
                      const SizedBox(height: 12),
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(item.value),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}

class _StatData {
  const _StatData(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(body),
            ],
          ),
        ),
      );
}
