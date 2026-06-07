part of 'package:parkir_cepat/app.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final occupiedSlots = state.slots.where((slot) => !slot.isAvailable).length;
    return AdminShell(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.blue,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/admin/scan-qr'),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan QR'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          HeaderSection(
            title: 'Dashboard Admin',
            subtitle: 'Pantau kendaraan, pendapatan, dan kapasitas secara realtime.',
            trailing: IconButton.filledTonal(
              onPressed: () => context.push('/admin/add-lot'),
              icon: const Icon(Icons.add_business_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatCard(
                label: 'Kendaraan masuk',
                value: '182',
                accent: AppTheme.blue,
                icon: Icons.directions_car_rounded,
              ),
              StatCard(
                label: 'Pendapatan hari ini',
                value: 'Rp 8,4 jt',
                accent: AppTheme.emerald,
                icon: Icons.trending_up_rounded,
              ),
              StatCard(
                label: 'Slot tersedia',
                value: '${state.slots.where((slot) => slot.isAvailable).length}',
                accent: AppTheme.slate,
                icon: Icons.local_parking_rounded,
              ),
              StatCard(
                label: 'Slot aktif',
                value: '$occupiedSlots',
                accent: AppTheme.blue,
                icon: Icons.timelapse_rounded,
              ),
              StatCard(
                label: 'Multi cabang',
                value: '${state.lots.length}',
                accent: AppTheme.emerald,
                icon: Icons.apartment_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Monitoring kendaraan realtime',
            action: 'Lihat detail',
            onTap: () => context.push('/admin/monitoring'),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            child: SizedBox(
              height: 220,
              child: RevenueChart(),
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Aksi cepat',
            action: 'Statistik',
            onTap: () => context.push('/admin/statistics'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionCard(
                label: 'Tambah lahan parkir',
                icon: Icons.add_location_alt_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/admin/add-lot'),
              ),
              ActionCard(
                label: 'Kelola slot parkir',
                icon: Icons.grid_view_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/admin/manage-slots'),
              ),
              ActionCard(
                label: 'Detail transaksi',
                icon: Icons.receipt_long_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/admin/transaction-detail'),
              ),
              ActionCard(
                label: 'Cetak nota',
                icon: Icons.print_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/admin/receipt'),
              ),
              ActionCard(
                label: 'Export PDF/Excel',
                icon: Icons.file_download_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/admin/statistics'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'CCTV monitoring section'),
          const SizedBox(height: 12),
          PremiumCard(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview kamera area parkir',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerbang masuk, area A, dan lane keluar terpantau realtime.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.slate,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            accent: AppTheme.emeraldSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI parking density prediction',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Prediksi jam ramai berikutnya pukul 17:30 - 19:00 dengan okupansi hingga 92%.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMapScreen extends ConsumerWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final selectedLot = state.selectedLot ?? state.lots.first;
    return AdminShell(
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Map monitoring area',
            subtitle: 'Kelola multi cabang, marker lokasi, dan status slot.',
          ),
          const SizedBox(height: 18),
          MapEmbedView(
            key: ValueKey(selectedLot.id),
            title: selectedLot.name,
            embedUrl: selectedLot.mapEmbedUrl,
            latitude: selectedLot.latitude,
            longitude: selectedLot.longitude,
            height: 240,
          ),
          const SizedBox(height: 18),
          ...state.lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MiniInfoTile(
                icon: Icons.domain_add_rounded,
                iconColor: lot.accent,
                title: lot.name,
                subtitle: '${lot.availableSlots}/${lot.totalSlots} slot tersedia • ${lot.address}',
                onTap: () => ref.read(appControllerProvider.notifier).selectLot(lot),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddParkingLotScreen extends ConsumerStatefulWidget {
  const AddParkingLotScreen({super.key});

  @override
  ConsumerState<AddParkingLotScreen> createState() => _AddParkingLotScreenState();
}

class _AddParkingLotScreenState extends ConsumerState<AddParkingLotScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  double _capacity = 60;
  double _price = 12000;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Neo Smart Parking Hub');
    _addressController = TextEditingController(text: 'Jl. Gatot Subroto Smart Gate 8');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah lahan parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama lokasi parkir',
                    prefixIcon: Icon(Icons.local_parking_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                const ParkingMapPlaceholder(title: 'Pilih titik lokasi pada map'),
                const SizedBox(height: 18),
                LabeledSlider(
                  label: 'Kapasitas kendaraan',
                  value: _capacity,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  display: _capacity.toInt().toString(),
                  onChanged: (value) => setState(() => _capacity = value),
                ),
                const SizedBox(height: 16),
                LabeledSlider(
                  label: 'Harga parkir per jam',
                  value: _price,
                  min: 5000,
                  max: 25000,
                  divisions: 20,
                  display: formatCurrency(_price.toInt()),
                  onChanged: (value) => setState(() => _price = value),
                ),
                const SizedBox(height: 18),
                const MiniInfoTile(
                  icon: Icons.add_photo_alternate_rounded,
                  iconColor: AppTheme.blue,
                  title: 'Upload foto lahan',
                  subtitle: 'Placeholder galeri untuk desain prototipe.',
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Simpan lahan',
                  icon: Icons.save_rounded,
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).addLot(
                          name: _nameController.text,
                          address: _addressController.text,
                          capacity: _capacity.toInt(),
                          price: _price.toInt(),
                        );
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleMonitoringScreen extends ConsumerWidget {
  const VehicleMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appControllerProvider).history;
    return AdminShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Monitoring kendaraan',
            subtitle: 'Daftar kendaraan masuk, keluar, pembayaran, dan filter realtime.',
          ),
          const SizedBox(height: 18),
          const InlineNotice(
            icon: Icons.bolt_rounded,
            accent: AppTheme.emerald,
            message:
                'Monitoring kendaraan dan aktivitas parkir langsung update secara realtime.',
          ),
          const SizedBox(height: 18),
          const SearchField(label: 'Filter plat nomor atau lokasi'),
          const SizedBox(height: 18),
          ...history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryRow(label: item.plateNumber, value: item.status, valueColor: AppTheme.emerald),
                    const SizedBox(height: 8),
                    Text(
                      item.locationName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.timeLabel} • ${formatCurrency(item.total)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.slate,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanQrScreen extends ConsumerWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(appControllerProvider).activeBooking;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR kendaraan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  booking == null
                      ? 'Tidak ada tiket aktif saat ini.'
                      : 'Tiket aktif ${booking.ticketNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Verifikasi kendaraan',
                  icon: Icons.verified_user_rounded,
                  onPressed: booking == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tiket valid dan pembayaran terkonfirmasi'),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Konfirmasi kendaraan keluar',
                  icon: Icons.exit_to_app_rounded,
                  onPressed: booking == null
                      ? null
                      : () {
                          ref.read(appControllerProvider.notifier).markVehicleExit();
                          context.go('/admin/dashboard');
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(appControllerProvider).history.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryRow(label: 'ID transaksi', value: transaction.id),
                SummaryRow(label: 'Lokasi', value: transaction.locationName),
                SummaryRow(label: 'Kendaraan', value: transaction.plateNumber),
                SummaryRow(label: 'Waktu parkir', value: transaction.timeLabel),
                SummaryRow(label: 'Total biaya', value: formatCurrency(transaction.total)),
                SummaryRow(label: 'Status', value: transaction.status, valueColor: AppTheme.emerald),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(appControllerProvider).history.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak nota parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              children: [
                Text(
                  'Nota Digital',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: transaction.id,
                  size: 150,
                  eyeStyle: const QrEyeStyle(color: AppTheme.emerald),
                ),
                const SizedBox(height: 18),
                SummaryRow(label: 'Transaksi', value: transaction.id),
                SummaryRow(label: 'Pembayaran', value: transaction.status),
                SummaryRow(label: 'Total', value: formatCurrency(transaction.total)),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Cetak nota',
                  icon: Icons.print_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preview nota siap dicetak')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik dan laporan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              StatCard(
                label: 'Pendapatan harian',
                value: 'Rp 8,4 jt',
                accent: AppTheme.emerald,
                icon: Icons.calendar_today_rounded,
              ),
              StatCard(
                label: 'Pendapatan bulanan',
                value: 'Rp 214 jt',
                accent: AppTheme.blue,
                icon: Icons.insights_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: SizedBox(
              height: 220,
              child: RevenueChart(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Export PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan PDF berhasil disiapkan')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Export Excel',
                  icon: Icons.table_view_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan Excel berhasil disiapkan')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik slot parkir',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  label: 'Slot tersedia',
                  value: '${state.slots.where((slot) => slot.isAvailable).length}',
                ),
                SummaryRow(
                  label: 'Slot penuh',
                  value: '${state.slots.where((slot) => !slot.isAvailable).length}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManageSlotsScreen extends ConsumerWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola slot parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrimaryButton(
            label: 'Tambah slot',
            icon: Icons.add_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Slot baru ditambahkan ke prototipe')),
              );
            },
          ),
          const SizedBox(height: 18),
          ...state.slots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Slot ${slot.label}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slot.isAvailable ? 'Tersedia' : 'Penuh',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: slot.isAvailable
                                      ? AppTheme.emerald
                                      : AppTheme.slate,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: slot.isAvailable,
                      activeThumbColor: AppTheme.emerald,
                      onChanged: (_) =>
                          ref.read(appControllerProvider.notifier).toggleSlot(slot.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(appControllerProvider).adminNotifications;
    return AdminShell(
      currentIndex: 3,
      child: NotificationsList(
        title: 'Notifikasi admin',
        subtitle: 'Kendaraan masuk, keluar, pembayaran, dan kapasitas slot.',
        items: notices,
      ),
    );
  }
}

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return AdminShell(
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          PremiumCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.emeraldSoft,
                  backgroundImage: state.providerAvatarBytes == null
                      ? null
                      : MemoryImage(state.providerAvatarBytes!),
                  child: state.providerAvatarBytes == null
                      ? const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: AppTheme.emerald,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  state.providerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.businessName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                StatusBadge(
                  label: switch (state.accountStatus) {
                    AccountStatus.pending => 'Pending',
                    AccountStatus.verified => 'Verified',
                    AccountStatus.rejected => 'Rejected',
                  },
                  color: switch (state.accountStatus) {
                    AccountStatus.pending => const Color(0xFFD97706),
                    AccountStatus.verified => AppTheme.emerald,
                    AccountStatus.rejected => const Color(0xFFDC2626),
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.providerEmail} • ${state.providerPhone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola ${state.lots.length} lahan parkir dari ${state.businessAddress}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          MiniInfoTile(
            icon: Icons.edit_rounded,
            iconColor: AppTheme.blue,
            title: 'Edit profil',
            subtitle: 'Perbarui data admin dan kontak.',
            onTap: () => context.push('/admin/edit-profile'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.store_mall_directory_rounded,
            iconColor: AppTheme.emerald,
            title: 'Data lahan parkir',
            subtitle: '${state.lots.length} lokasi aktif',
            onTap: () => context.push('/admin/parking-lots'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.settings_rounded,
            iconColor: AppTheme.slate,
            title: 'Pengaturan akun',
            subtitle: 'Atur preferensi operasional dan notifikasi.',
            onTap: () => context.push('/admin/account-settings'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFDC2626),
            title: 'Hapus akun',
            subtitle: 'Menghapus akun penyedia parkir.',
            onTap: () => context.push('/delete-account'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            color: AppTheme.ink,
            onPressed: () {
              ref.read(appControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class AdminEditProfileScreen extends ConsumerStatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  ConsumerState<AdminEditProfileScreen> createState() =>
      _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState
    extends ConsumerState<AdminEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _businessAddressController;
  Uint8List? _avatarBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _nameController = TextEditingController(text: state.providerName);
    _emailController = TextEditingController(text: state.providerEmail);
    _phoneController = TextEditingController(text: state.providerPhone);
    _businessNameController = TextEditingController(text: state.businessName);
    _businessAddressController =
        TextEditingController(text: state.businessAddress);
    _avatarBytes = state.providerAvatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    ref.read(appControllerProvider.notifier).updateProviderAvatar(bytes);
    if (mounted) {
      setState(() => _avatarBytes = bytes);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final businessName = _businessNameController.text.trim();
    final businessAddress = _businessAddressController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama penyedia tidak boleh kosong.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Email penyedia tidak valid.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Nomor HP tidak boleh kosong.');
      return;
    }
    if (businessName.isEmpty) {
      setState(() => _errorMessage = 'Nama bisnis tidak boleh kosong.');
      return;
    }
    if (businessAddress.isEmpty) {
      setState(() => _errorMessage = 'Alamat tidak boleh kosong.');
      return;
    }

    ref.read(appControllerProvider.notifier).updateProviderProfile(
          name: name,
          email: email,
          phone: phone,
          businessName: businessName,
          businessAddress: businessAddress,
          avatarBytes: _avatarBytes,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil penyedia berhasil diperbarui')),
    );
    context.go('/admin/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil Penyedia')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.emeraldSoft,
                  backgroundImage:
                      _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
                  child: _avatarBytes == null
                      ? const Icon(
                          Icons.storefront_rounded,
                          size: 44,
                          color: AppTheme.emerald,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickLogo,
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Ganti Logo'),
                      ),
                      if (_avatarBytes != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(appControllerProvider.notifier)
                                .clearProviderAvatar();
                            setState(() => _avatarBytes = null);
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Hapus Logo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama penyedia/admin',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _businessNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama bisnis/tempat parkir',
                    prefixIcon: Icon(Icons.business_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _businessAddressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat kantor/lokasi utama',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  InlineNotice(
                    icon: Icons.error_outline_rounded,
                    accent: const Color(0xFFDC2626),
                    message: _errorMessage!,
                  ),
                ],
                const SizedBox(height: 18),
                _AdminCompactButton(
                  label: 'Simpan Perubahan',
                  icon: Icons.save_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminAccountSettingsScreen extends ConsumerStatefulWidget {
  const AdminAccountSettingsScreen({super.key});

  @override
  ConsumerState<AdminAccountSettingsScreen> createState() =>
      _AdminAccountSettingsScreenState();
}

class _AdminAccountSettingsScreenState
    extends ConsumerState<AdminAccountSettingsScreen> {
  late final TextEditingController _passwordController;
  late bool _transactionNotificationEnabled;
  late bool _fullSlotNotificationEnabled;
  late bool _newBookingNotificationEnabled;
  late bool _providerSecurityEnabled;
  late String _providerSelectedLanguage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _passwordController = TextEditingController();
    _transactionNotificationEnabled = state.transactionNotificationEnabled;
    _fullSlotNotificationEnabled = state.fullSlotNotificationEnabled;
    _newBookingNotificationEnabled = state.newBookingNotificationEnabled;
    _providerSecurityEnabled = state.providerSecurityEnabled;
    _providerSelectedLanguage = state.providerSelectedLanguage;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty && password.length < 6) {
      setState(() => _errorMessage = 'Password baru minimal 6 karakter.');
      return;
    }

    ref.read(appControllerProvider.notifier).updateProviderSettings(
          transactionNotificationEnabled: _transactionNotificationEnabled,
          fullSlotNotificationEnabled: _fullSlotNotificationEnabled,
          newBookingNotificationEnabled: _newBookingNotificationEnabled,
          providerSelectedLanguage: _providerSelectedLanguage,
          providerSecurityEnabled: _providerSecurityEnabled,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan akun berhasil disimpan')),
    );
    context.go('/admin/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Akun Penyedia')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi operasional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _transactionNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _transactionNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi transaksi'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.blue,
                ),
                SwitchListTile(
                  value: _fullSlotNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _fullSlotNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi slot penuh'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.emerald,
                ),
                SwitchListTile(
                  value: _newBookingNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _newBookingNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi booking baru'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun dan keamanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _providerSelectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Bahasa aplikasi',
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Indonesia',
                      child: Text('Indonesia'),
                    ),
                    DropdownMenuItem(
                      value: 'English',
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _providerSelectedLanguage = value ?? 'Indonesia',
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: _providerSecurityEnabled,
                  onChanged: (value) =>
                      setState(() => _providerSecurityEnabled = value),
                  title: const Text('Mode keamanan akun'),
                  subtitle: const Text('Aktifkan perlindungan akun penyedia.'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.emerald,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Ubah password',
                    hintText: 'Kosongkan jika tidak ingin mengubah',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            InlineNotice(
              icon: Icons.error_outline_rounded,
              accent: const Color(0xFFDC2626),
              message: _errorMessage!,
            ),
          ],
          const SizedBox(height: 18),
          _AdminCompactButton(
            label: 'Simpan Pengaturan',
            icon: Icons.save_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class AdminParkingLotsScreen extends ConsumerWidget {
  const AdminParkingLotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lots = ref.watch(appControllerProvider).lots;
    return Scaffold(
      appBar: AppBar(title: const Text('Data Lahan Parkir')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          HeaderSection(
            title: 'Data lahan parkir',
            subtitle: 'Daftar lokasi yang dikelola penyedia Parkir Cepat.',
            trailing: IconButton.filledTonal(
              onPressed: () => context.push('/admin/add-lot'),
              icon: const Icon(Icons.add_business_rounded),
            ),
          ),
          const SizedBox(height: 18),
          ...lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  ref.read(appControllerProvider.notifier).selectLot(lot);
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (sheetContext) => _ParkingLotDetailSheet(lot: lot),
                  );
                },
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: lot.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.local_parking_rounded,
                              color: lot.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lot.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lot.address,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.slate,
                                        height: 1.45,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: lot.isFull ? 'Penuh' : 'Aktif',
                            color: lot.isFull
                                ? const Color(0xFFDC2626)
                                : AppTheme.emerald,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SummaryRow(
                        label: 'Total slot',
                        value: '${lot.totalSlots} slot',
                      ),
                      SummaryRow(
                        label: 'Slot tersedia',
                        value: '${lot.availableSlots} slot',
                        valueColor:
                            lot.isFull ? const Color(0xFFDC2626) : AppTheme.emerald,
                      ),
                      SummaryRow(
                        label: 'Tarif per jam',
                        value: formatCurrency(lot.pricePerHour),
                        valueColor: AppTheme.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AdminCompactButton(
            label: 'Tambah Lahan Parkir',
            icon: Icons.add_location_alt_rounded,
            onPressed: () => context.push('/admin/add-lot'),
          ),
        ],
      ),
    );
  }
}

class _ParkingLotDetailSheet extends StatelessWidget {
  const _ParkingLotDetailSheet({required this.lot});

  final ParkingLot lot;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lot.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              lot.address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            SummaryRow(label: 'Total slot', value: '${lot.totalSlots} slot'),
            SummaryRow(
              label: 'Slot tersedia',
              value: '${lot.availableSlots} slot',
              valueColor: lot.isFull ? const Color(0xFFDC2626) : AppTheme.emerald,
            ),
            SummaryRow(
              label: 'Tarif per jam',
              value: formatCurrency(lot.pricePerHour),
              valueColor: AppTheme.blue,
            ),
            SummaryRow(label: 'Jam buka', value: lot.openHours),
            SummaryRow(
              label: 'Status aktif',
              value: lot.isFull ? 'Penuh sementara' : 'Aktif',
              valueColor: lot.isFull ? const Color(0xFFDC2626) : AppTheme.emerald,
            ),
            const SizedBox(height: 18),
            _AdminCompactButton(
              label: 'Tutup',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCompactButton extends StatelessWidget {
  const _AdminCompactButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
