part of 'package:parkir_cepat/app.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final cheapestLot = state.lots.reduce(
      (a, b) => a.pricePerHour <= b.pricePerHour ? a : b,
    );
    final nearestLot = state.lots.reduce(
      (a, b) => a.distanceKm <= b.distanceKm ? a : b,
    );
    final leastBusyLot = state.lots.reduce((a, b) {
      final aRatio = a.availableSlots / a.totalSlots;
      final bRatio = b.availableSlots / b.totalSlots;
      return aRatio >= bRatio ? a : b;
    });
    return CustomerShell(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.blue,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/customer/booking'),
        icon: const Icon(Icons.flash_on_rounded),
        label: const Text('Booking cepat'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          HeaderSection(
            title: 'Halo, ${state.userName.split(' ').first}',
            subtitle: 'Lokasi Anda saat ini: Jakarta Pusat',
            trailing: const CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.blueSoft,
              child: Icon(Icons.person_rounded, color: AppTheme.blue),
            ),
          ),
          const SizedBox(height: 18),
          const SearchField(label: 'Cari lokasi parkir, mall, kantor'),
          const SizedBox(height: 18),
          HeroBanner(
            title: 'Parkir premium lebih cepat',
            body: 'Akses rekomendasi slot terbaik dengan status realtime dan navigasi instan.',
            accent: AppTheme.blue,
            actionLabel: 'Lihat peta',
            onPressed: () => context.go('/customer/map'),
          ),
          const SizedBox(height: 22),
          SectionTitle(title: 'AI smart recommendation'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AiRecommendationCard(
                title: 'Terdekat',
                subtitle: nearestLot.name,
                detail: '${nearestLot.distanceKm} km • ${nearestLot.etaMinutes} menit',
                accent: AppTheme.blueSoft,
                icon: Icons.near_me_rounded,
              ),
              AiRecommendationCard(
                title: 'Termurah',
                subtitle: cheapestLot.name,
                detail: '${formatCurrency(cheapestLot.pricePerHour)}/jam',
                accent: AppTheme.emeraldSoft,
                icon: Icons.sell_rounded,
              ),
              AiRecommendationCard(
                title: 'Tidak ramai',
                subtitle: leastBusyLot.name,
                detail:
                    '${leastBusyLot.availableSlots}/${leastBusyLot.totalSlots} slot siap',
                accent: AppTheme.blueSoft,
                icon: Icons.psychology_alt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionTitle(
            title: 'Tempat parkir terdekat',
            action: 'Riwayat',
            onTap: () => context.push('/customer/history'),
          ),
          const SizedBox(height: 14),
          ...state.lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ParkingLotCard(
                lot: lot,
                isFavorite: state.favoriteLotIds.contains(lot.id),
                onToggleFavorite: () => ref
                    .read(appControllerProvider.notifier)
                    .toggleFavoriteLot(lot.id),
                onDetail: () {
                  ref.read(appControllerProvider.notifier).selectLot(lot);
                  context.push('/customer/parking-detail');
                },
                onBooking: () {
                  ref.read(appControllerProvider.notifier).selectLot(lot);
                  context.push('/customer/booking');
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          SectionTitle(title: 'Live slot realtime'),
          const SizedBox(height: 14),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warna hijau = tersedia, merah = penuh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: state.slots.map((slot) {
                    final color = slot.isAvailable
                        ? AppTheme.emerald
                        : const Color(0xFFDC2626);
                    return Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Text(
                            slot.label,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.circle, size: 12, color: color),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SizedBox(height: 8),
          SectionTitle(title: 'Rekomendasi smart parking'),
          const SizedBox(height: 14),
          PremiumCard(
            accent: AppTheme.emeraldSoft,
            child: Row(
              children: [
                const Expanded(
                  child: SmartCityIllustration(height: 130, accent: AppTheme.emerald),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto entry lane',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Masuk parkir cukup scan QR digital tanpa antre panjang.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.slate,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryRow(
                  label: 'Multi kendaraan',
                  value: '${state.vehicles.length} kendaraan tersimpan',
                ),
                SummaryRow(
                  label: 'Favorite parking',
                  value: '${state.favoriteLotIds.length} lokasi favorit',
                ),
                SummaryRow(
                  label: 'Reminder notifikasi',
                  value: 'Aktif 30 menit sebelum habis',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerMapScreen extends ConsumerWidget {
  const CustomerMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return CustomerShell(
      currentIndex: 1,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.emerald,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/customer/booking'),
        icon: const Icon(Icons.book_online_rounded),
        label: const Text('Booking'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Map lokasi parkir',
            subtitle: 'Marker realtime, radius terdekat, dan ETA perjalanan.',
          ),
          const SizedBox(height: 18),
          ParkingMapCard(
            lots: state.lots,
            selected: state.selectedLot,
            onSelect: (lot) => ref.read(appControllerProvider.notifier).selectLot(lot),
          ),
          const SizedBox(height: 20),
          ...state.lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MiniInfoTile(
                icon: Icons.near_me_rounded,
                iconColor: lot.accent,
                title: '${lot.name} • ${lot.distanceKm} km',
                subtitle: 'ETA ${lot.etaMinutes} menit • ${lot.availableSlots}/${lot.totalSlots} slot',
                onTap: () {
                  ref.read(appControllerProvider.notifier).selectLot(lot);
                  context.push('/customer/parking-detail');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingDetailScreen extends ConsumerWidget {
  const ParkingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final lot = state.selectedLot ?? state.lots.first;
    final isFavorite = state.favoriteLotIds.contains(lot.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail lokasi parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            accent: lot.accent.withValues(alpha: 0.08),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      colors: [lot.accent.withValues(alpha: 0.9), AppTheme.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: SmartCityIllustration(height: 160),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref
                            .read(appControllerProvider.notifier)
                            .toggleFavoriteLot(lot.id),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFDC2626)
                              : AppTheme.blue,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Tersimpan di favorite'
                              : 'Simpan ke favorite',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lot.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.slate,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          InfoChip(
                            icon: Icons.payments_rounded,
                            label: '${formatCurrency(lot.pricePerHour)}/jam',
                          ),
                          InfoChip(
                            icon: Icons.local_parking_rounded,
                            label: '${lot.availableSlots} slot tersedia',
                          ),
                          InfoChip(
                            icon: Icons.schedule_rounded,
                            label: lot.openHours,
                          ),
                          InfoChip(
                            icon: Icons.star_rounded,
                            label: '${lot.rating}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Booking parkir',
                        icon: Icons.book_online_rounded,
                        onPressed: () => context.push('/customer/booking'),
                      ),
                    ],
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

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  late final TextEditingController _plateController;
  VehicleKind _kind = VehicleKind.mobil;
  double _quantity = 1;
  double _duration = 2;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: 'B 5678 PCP');
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah kendaraan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _plateController,
                  decoration: const InputDecoration(
                    labelText: 'Plat nomor kendaraan',
                    prefixIcon: Icon(Icons.directions_car_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                SegmentedChoice<VehicleKind>(
                  items: const [
                    ChoiceItem(
                      value: VehicleKind.motor,
                      label: 'Motor',
                      icon: Icons.two_wheeler_rounded,
                    ),
                    ChoiceItem(
                      value: VehicleKind.mobil,
                      label: 'Mobil',
                      icon: Icons.directions_car_rounded,
                    ),
                    ChoiceItem(
                      value: VehicleKind.truk,
                      label: 'Truk',
                      icon: Icons.local_shipping_rounded,
                    ),
                  ],
                  value: _kind,
                  onChanged: (value) => setState(() => _kind = value),
                ),
                const SizedBox(height: 20),
                LabeledSlider(
                  label: 'Jumlah kendaraan',
                  value: _quantity,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  display: _quantity.toInt().toString(),
                  onChanged: (value) => setState(() => _quantity = value),
                ),
                const SizedBox(height: 16),
                LabeledSlider(
                  label: 'Durasi parkir',
                  value: _duration,
                  min: 1,
                  max: 8,
                  divisions: 7,
                  display: '${_duration.toInt()} jam',
                  onChanged: (value) => setState(() => _duration = value),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Simpan kendaraan',
                  icon: Icons.save_rounded,
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).saveVehicle(
                          plateNumber: _plateController.text,
                          kind: _kind,
                          quantity: _quantity.toInt(),
                          durationHours: _duration.toInt(),
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

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedSlot;
  DateTime _entryTime = DateTime.now().add(const Duration(minutes: 15));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final lot = state.selectedLot ?? state.lots.first;
    final vehicle = state.selectedVehicle ?? state.vehicles.first;
    final total = lot.pricePerHour * vehicle.durationHours;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking parkir'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/customer/add-vehicle'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Kendaraan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            accent: AppTheme.blueSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${vehicle.plateNumber} • ${vehicle.label} • ${vehicle.durationHours} jam',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 18),
                const InlineNotice(
                  icon: Icons.lock_clock_rounded,
                  accent: AppTheme.blue,
                  message:
                      'Reservasi slot akan dikunci sementara selama 15 menit setelah booking dikonfirmasi.',
                ),
                const SizedBox(height: 18),
                Text(
                  'Pilih slot parkir',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: state.slots.map((slot) {
                    final selected = _selectedSlot == slot.label;
                    return GestureDetector(
                      onTap: slot.isAvailable
                          ? () => setState(() => _selectedSlot = slot.label)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: 84,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: !slot.isAvailable
                              ? AppTheme.slate.withValues(alpha: 0.08)
                              : selected
                                  ? AppTheme.blue
                                  : AppTheme.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: selected
                                ? AppTheme.blue
                                : slot.isAvailable
                                    ? AppTheme.blue.withValues(alpha: 0.15)
                                    : AppTheme.slate.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              slot.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              slot.isAvailable ? 'Ready' : 'Full',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : slot.isAvailable
                                            ? AppTheme.emerald
                                            : AppTheme.slate,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                MiniInfoTile(
                  icon: Icons.schedule_rounded,
                  iconColor: AppTheme.emerald,
                  title: 'Waktu masuk',
                  subtitle: formatDateTime(_entryTime),
                  onTap: () => setState(
                    () => _entryTime = _entryTime.add(const Duration(minutes: 30)),
                  ),
                ),
                const SizedBox(height: 12),
                SummaryRow(label: 'Estimasi biaya', value: formatCurrency(total)),
                const SizedBox(height: 8),
                SummaryRow(label: 'Durasi', value: '${vehicle.durationHours} jam'),
                const SizedBox(height: 8),
                SummaryRow(label: 'Ringkasan', value: '${vehicle.label} • ${vehicle.plateNumber}'),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Konfirmasi booking',
                  icon: Icons.check_circle_rounded,
                  onPressed: _selectedSlot == null
                      ? null
                      : () {
                          ref.read(appControllerProvider.notifier).createBooking(
                                slotCode: _selectedSlot!,
                                entryTime: _entryTime,
                              );
                          context.push('/customer/tickets');
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

class CustomerTicketScreen extends ConsumerWidget {
  const CustomerTicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final booking = state.activeBooking;
    final reservationLeft =
        state.reservationLockedUntil?.difference(DateTime.now());
    return CustomerShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Tiket digital',
            subtitle: 'Gunakan QR ini untuk masuk, bayar, dan verifikasi cepat.',
          ),
          const SizedBox(height: 18),
          if (booking == null)
            EmptyStateCard(
              title: 'Belum ada tiket aktif',
              body: 'Mulai booking dari dashboard atau peta untuk membuat karcis digital.',
              actionLabel: 'Booking sekarang',
              onPressed: () => context.push('/customer/booking'),
            )
          else
            PremiumCard(
              accent: AppTheme.blueSoft,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QrImageView(
                      data: booking.ticketNumber,
                      size: 210,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    booking.ticketNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SummaryRow(label: 'Plat kendaraan', value: booking.plateNumber),
                  SummaryRow(label: 'Jenis kendaraan', value: booking.vehicleLabel),
                  SummaryRow(label: 'Lokasi parkir', value: booking.locationName),
                  SummaryRow(label: 'Waktu masuk', value: formatDateTime(booking.entryTime)),
                  if (reservationLeft != null)
                    SummaryRow(
                      label: 'Countdown reservasi',
                      value: formatDuration(reservationLeft),
                      valueColor: AppTheme.blue,
                    ),
                  SummaryRow(
                    label: 'Status pembayaran',
                    value: booking.isPaid ? 'Lunas' : 'Menunggu',
                    valueColor: booking.isPaid ? AppTheme.emerald : AppTheme.blue,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Extend 1 jam',
                          icon: Icons.more_time_rounded,
                          onPressed: () => ref
                              .read(appControllerProvider.notifier)
                              .extendParkingTime(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'QR keluar',
                          icon: Icons.logout_rounded,
                          onPressed: booking.isPaid ? () {} : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: booking.isPaid ? 'QR sudah aktif' : 'Scan pembayaran',
                    icon: booking.isPaid
                        ? Icons.verified_rounded
                        : Icons.qr_code_scanner_rounded,
                    onPressed:
                        booking.isPaid ? null : () => context.push('/customer/payment'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.qris;

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(appControllerProvider).activeBooking;
    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada booking aktif.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metode pembayaran',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                SegmentedChoice<PaymentMethod>(
                  items: const [
                    ChoiceItem(value: PaymentMethod.qris, label: 'QRIS', icon: Icons.qr_code_rounded),
                    ChoiceItem(value: PaymentMethod.ewallet, label: 'E-wallet', icon: Icons.account_balance_wallet_rounded),
                    ChoiceItem(value: PaymentMethod.cash, label: 'Tunai', icon: Icons.payments_rounded),
                    ChoiceItem(value: PaymentMethod.card, label: 'Debit/Kredit', icon: Icons.credit_card_rounded),
                  ],
                  value: _method,
                  onChanged: (value) => setState(() => _method = value),
                ),
                const SizedBox(height: 20),
                SummaryRow(label: 'Ringkasan biaya', value: booking.locationName),
                SummaryRow(label: 'Nomor tiket', value: booking.ticketNumber),
                SummaryRow(label: 'Total pembayaran', value: formatCurrency(booking.estimatedCost)),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Bayar sekarang',
                  icon: Icons.lock_rounded,
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).payBooking(_method);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pembayaran berhasil')),
                    );
                    context.go('/customer/tickets');
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

class ParkingHistoryScreen extends ConsumerWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appControllerProvider).history;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: history
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SummaryRow(label: item.id, value: item.status, valueColor: AppTheme.emerald),
                      const SizedBox(height: 8),
                      Text(item.locationName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      const SizedBox(height: 6),
                      Text(
                        '${item.plateNumber} • ${item.timeLabel}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.slate,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatCurrency(item.total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.blue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(appControllerProvider).customerNotifications;
    return CustomerShell(
      currentIndex: 3,
      child: NotificationsList(
        title: 'Notifikasi pengguna',
        subtitle: 'Booking, pembayaran, verifikasi QR, dan status durasi parkir.',
        items: notices,
      ),
    );
  }
}

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return CustomerShell(
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          PremiumCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.blueSoft,
                  child: Icon(Icons.person_rounded, size: 40, color: AppTheme.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  state.userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.email,
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
            subtitle: 'Perbarui data akun dan kontak.',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.directions_car_rounded,
            iconColor: AppTheme.emerald,
            title: 'Data kendaraan',
            subtitle: '${state.vehicles.length} kendaraan tersimpan',
            onTap: () => context.push('/customer/add-vehicle'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.receipt_long_rounded,
            iconColor: AppTheme.blue,
            title: 'Riwayat transaksi',
            subtitle: '${state.history.length} transaksi',
            onTap: () => context.push('/customer/history'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.settings_rounded,
            iconColor: AppTheme.slate,
            title: 'Pengaturan akun',
            subtitle: 'Kelola preferensi parkir dan notifikasi.',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFDC2626),
            title: 'Hapus akun',
            subtitle: 'Menghapus akun secara permanen.',
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
