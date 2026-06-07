part of 'package:parkir_cepat/app.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    void openLotDetail(ParkingLot lot) {
      ref.read(appControllerProvider.notifier).selectLot(lot);
      context.push('/customer/parking-detail');
    }

    void startBooking(ParkingLot lot) {
      ref.read(appControllerProvider.notifier).selectLot(lot);
      context.push('/customer/booking');
    }

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
        onPressed: () => startBooking(state.selectedLot ?? nearestLot),
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
                onTap: () => openLotDetail(nearestLot),
              ),
              AiRecommendationCard(
                title: 'Termurah',
                subtitle: cheapestLot.name,
                detail: '${formatCurrency(cheapestLot.pricePerHour)}/jam',
                accent: AppTheme.emeraldSoft,
                icon: Icons.sell_rounded,
                onTap: () => openLotDetail(cheapestLot),
              ),
              AiRecommendationCard(
                title: 'Tidak ramai',
                subtitle: leastBusyLot.name,
                detail:
                    '${leastBusyLot.availableSlots}/${leastBusyLot.totalSlots} slot siap',
                accent: AppTheme.blueSoft,
                icon: Icons.psychology_alt_rounded,
                onTap: () => openLotDetail(leastBusyLot),
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
                onDetail: () => openLotDetail(lot),
                onBooking: () => startBooking(lot),
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
    final selectedLot = state.selectedLot ?? state.lots.first;
    return CustomerShell(
      currentIndex: 1,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.emerald,
        foregroundColor: Colors.white,
        onPressed: () {
          ref.read(appControllerProvider.notifier).selectLot(selectedLot);
          context.push('/customer/booking');
        },
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
          MapEmbedView(
            key: ValueKey(selectedLot.id),
            title: selectedLot.name,
            embedUrl: selectedLot.mapEmbedUrl,
            latitude: selectedLot.latitude,
            longitude: selectedLot.longitude,
            height: 240,
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Daftar lokasi parkir'),
          const SizedBox(height: 12),
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: MapEmbedView(
                    key: ValueKey(lot.id),
                    title: lot.name,
                    embedUrl: lot.mapEmbedUrl,
                    latitude: lot.latitude,
                    longitude: lot.longitude,
                    height: 230,
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
                      PremiumCard(
                        accent: AppTheme.slateSoft,
                        child: Column(
                          children: [
                            SummaryRow(label: 'Nama lokasi', value: lot.name),
                            SummaryRow(label: 'Alamat', value: lot.address),
                            SummaryRow(label: 'Jarak', value: '${lot.distanceKm} km'),
                            SummaryRow(
                              label: 'Slot tersedia',
                              value: '${lot.availableSlots} slot',
                              valueColor: lot.isFull ? AppTheme.slate : AppTheme.emerald,
                            ),
                            SummaryRow(label: 'Total slot', value: '${lot.totalSlots} slot'),
                            SummaryRow(
                              label: 'Tarif per jam',
                              value: formatCurrency(lot.pricePerHour),
                              valueColor: AppTheme.blue,
                            ),
                            SummaryRow(label: 'Rating', value: '${lot.rating} / 5'),
                            SummaryRow(label: 'Jam buka', value: lot.openHours),
                          ],
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
                        label: 'Booking Sekarang',
                        icon: Icons.book_online_rounded,
                        onPressed: lot.isFull
                            ? null
                            : () {
                                ref
                                    .read(appControllerProvider.notifier)
                                    .selectLot(lot);
                                context.push('/customer/booking');
                              },
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
          else if (!booking.canShowTicket)
            PremiumCard(
              accent: AppTheme.blueSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(
                    label: 'Menunggu Pembayaran',
                    color: AppTheme.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking berhasil dibuat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tiket QR akan aktif setelah pembayaran dikonfirmasi.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.slate,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SummaryRow(label: 'Nomor tiket', value: booking.ticketNumber),
                  SummaryRow(label: 'Lokasi parkir', value: booking.locationName),
                  SummaryRow(label: 'Plat kendaraan', value: booking.plateNumber),
                  SummaryRow(label: 'Slot parkir', value: booking.slotCode),
                  SummaryRow(label: 'Waktu masuk', value: formatDateTime(booking.entryTime)),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Lanjut ke Pembayaran',
                    icon: Icons.payments_rounded,
                    onPressed: () => context.push('/customer/payment'),
                  ),
                ],
              ),
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
                    value: _bookingStatusLabel(booking.status),
                    valueColor: AppTheme.emerald,
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
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'QR sudah aktif',
                    icon: Icons.verified_rounded,
                    onPressed: null,
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
  String _wallet = 'GoPay';
  late final TextEditingController _walletPhoneController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardNameController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  String? _paymentError;

  @override
  void initState() {
    super.initState();
    _walletPhoneController = TextEditingController(text: '081234567890');
    _cardNumberController = TextEditingController();
    _cardNameController = TextEditingController();
    _cardExpiryController = TextEditingController();
    _cardCvvController = TextEditingController();
  }

  @override
  void dispose() {
    _walletPhoneController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _completePayment({
    required Booking booking,
    required int total,
  }) async {
    ref.read(appControllerProvider.notifier).payBooking(_method);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PaymentSuccessDialog(
        ticketNumber: booking.ticketNumber,
        total: total,
        method: _method,
      ),
    );
  }

  Future<void> _handlePaymentAction({
    required Booking booking,
    required int total,
  }) async {
    setState(() => _paymentError = null);

    if (_method == PaymentMethod.ewallet &&
        _walletPhoneController.text.trim().length < 9) {
      setState(() => _paymentError = 'Nomor HP E-Wallet minimal 9 digit.');
      return;
    }

    if (_method == PaymentMethod.card) {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final validCard = cardNumber.length >= 12 &&
          _cardNameController.text.trim().isNotEmpty &&
          _cardExpiryController.text.trim().length >= 5 &&
          _cardCvvController.text.trim().length >= 3;
      if (!validCard) {
        setState(() => _paymentError = 'Lengkapi data kartu dengan benar.');
        return;
      }
    }

    await _completePayment(booking: booking, total: total);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final booking = state.activeBooking;
    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada booking aktif.')),
      );
    }
    final lot = state.lots.where((item) => item.name == booking.locationName).firstOrNull ??
        state.selectedLot ??
        state.lots.first;
    final vehicle = state.vehicles.where((item) => item.plateNumber == booking.plateNumber).firstOrNull ??
        state.selectedVehicle ??
        state.vehicles.first;
    final duration = vehicle.durationHours;
    final hourlyRate = duration == 0 ? lot.pricePerHour : booking.estimatedCost ~/ duration;
    final subtotal = booking.estimatedCost;
    const serviceFee = 0;
    final total = subtotal + serviceFee;
    final isPendingPayment = booking.status == BookingStatus.pendingPayment;

    if (!isPendingPayment) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran parkir')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PremiumCard(
              accent: AppTheme.emeraldSoft,
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.emerald,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Pembayaran sudah dikonfirmasi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SummaryRow(label: 'Nomor tiket', value: booking.ticketNumber),
                  SummaryRow(label: 'Total pembayaran', value: formatCurrency(total)),
                  SummaryRow(label: 'Metode', value: _paymentMethodLabel(booking.paymentMethod)),
                  SummaryRow(label: 'Status', value: _bookingStatusLabel(booking.status), valueColor: AppTheme.emerald),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Lihat Tiket QR',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: () => context.go('/customer/tickets'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran parkir')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          HeaderSection(
            title: 'Selesaikan pembayaran',
            subtitle: 'Periksa detail tiket dan pilih metode pembayaran yang paling sesuai.',
            trailing: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.blueSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.blue),
            ),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Tiket',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                SummaryRow(label: 'Nama lokasi parkir', value: booking.locationName),
                SummaryRow(label: 'Nomor tiket', value: booking.ticketNumber),
                SummaryRow(label: 'Plat kendaraan', value: booking.plateNumber),
                SummaryRow(label: 'Jenis kendaraan', value: booking.vehicleLabel),
                SummaryRow(label: 'Slot parkir', value: booking.slotCode),
                SummaryRow(label: 'Waktu masuk', value: formatDateTime(booking.entryTime)),
                SummaryRow(label: 'Durasi parkir', value: '$duration jam'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rincian Biaya',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                SummaryRow(label: 'Tarif parkir per jam', value: formatCurrency(hourlyRate)),
                SummaryRow(label: 'Durasi', value: '$duration jam'),
                SummaryRow(label: 'Subtotal', value: formatCurrency(subtotal)),
                SummaryRow(label: 'Biaya layanan', value: formatCurrency(serviceFee)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.blueSoft,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total pembayaran',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Text(
                        formatCurrency(total),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.blue,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
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
                  'Metode Pembayaran',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: PaymentMethod.values.map((method) {
                    return _PaymentMethodTile(
                      method: method,
                      selected: method == _method,
                      onTap: () => setState(() {
                        _method = method;
                        _paymentError = null;
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PaymentActionPanel(
            method: _method,
            total: total,
            wallet: _wallet,
            walletPhoneController: _walletPhoneController,
            cardNumberController: _cardNumberController,
            cardNameController: _cardNameController,
            cardExpiryController: _cardExpiryController,
            cardCvvController: _cardCvvController,
            errorMessage: _paymentError,
            onWalletChanged: (value) => setState(() => _wallet = value),
            onSubmit: () => _handlePaymentAction(booking: booking, total: total),
          ),
          const SizedBox(height: 16),
          const InlineNotice(
            icon: Icons.shield_rounded,
            accent: AppTheme.blue,
            message: 'Pembayaran aman dan terenkripsi.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 6, 20, 14),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: () => _handlePaymentAction(booking: booking, total: total),
            icon: const Icon(Icons.lock_rounded, size: 20),
            label: Text(
              'Bayar Sekarang - ${formatCurrency(total)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentActionPanel extends StatelessWidget {
  const _PaymentActionPanel({
    required this.method,
    required this.total,
    required this.wallet,
    required this.walletPhoneController,
    required this.cardNumberController,
    required this.cardNameController,
    required this.cardExpiryController,
    required this.cardCvvController,
    required this.errorMessage,
    required this.onWalletChanged,
    required this.onSubmit,
  });

  final PaymentMethod method;
  final int total;
  final String wallet;
  final TextEditingController walletPhoneController;
  final TextEditingController cardNumberController;
  final TextEditingController cardNameController;
  final TextEditingController cardExpiryController;
  final TextEditingController cardCvvController;
  final String? errorMessage;
  final ValueChanged<String> onWalletChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      accent: AppTheme.slateSoft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (method) {
          PaymentMethod.qris => _QrisPaymentPanel(
              key: const ValueKey('qris-panel'),
              total: total,
              onSubmit: onSubmit,
            ),
          PaymentMethod.ewallet => _WalletPaymentPanel(
              key: const ValueKey('wallet-panel'),
              wallet: wallet,
              phoneController: walletPhoneController,
              errorMessage: errorMessage,
              onWalletChanged: onWalletChanged,
              onSubmit: onSubmit,
            ),
          PaymentMethod.cash => _CashPaymentPanel(
              key: const ValueKey('cash-panel'),
              onSubmit: onSubmit,
            ),
          PaymentMethod.card => _CardPaymentPanel(
              key: const ValueKey('card-panel'),
              numberController: cardNumberController,
              nameController: cardNameController,
              expiryController: cardExpiryController,
              cvvController: cardCvvController,
              errorMessage: errorMessage,
              onSubmit: onSubmit,
            ),
        },
      ),
    );
  }
}

class _QrisPaymentPanel extends StatelessWidget {
  const _QrisPaymentPanel({
    super.key,
    required this.total,
    required this.onSubmit,
  });

  final int total;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pembayaran QRIS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        const StatusBadge(
          label: 'Menunggu Pembayaran',
          color: AppTheme.blue,
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: QrImageView(
              data: 'PARKIR-CEPAT-QRIS-${formatCurrency(total)}',
              size: 184,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppTheme.blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Scan QRIS untuk membayar',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          formatCurrency(total),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.blue,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Saya Sudah Bayar',
          icon: Icons.check_circle_rounded,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _WalletPaymentPanel extends StatelessWidget {
  const _WalletPaymentPanel({
    super.key,
    required this.wallet,
    required this.phoneController,
    required this.errorMessage,
    required this.onWalletChanged,
    required this.onSubmit,
  });

  final String wallet;
  final TextEditingController phoneController;
  final String? errorMessage;
  final ValueChanged<String> onWalletChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pembayaran E-Wallet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: wallet,
          decoration: const InputDecoration(
            labelText: 'Pilih wallet',
            prefixIcon: Icon(Icons.account_balance_wallet_rounded),
          ),
          items: const [
            DropdownMenuItem(value: 'GoPay', child: Text('GoPay')),
            DropdownMenuItem(value: 'OVO', child: Text('OVO')),
            DropdownMenuItem(value: 'DANA', child: Text('DANA')),
            DropdownMenuItem(value: 'ShopeePay', child: Text('ShopeePay')),
          ],
          onChanged: (value) => onWalletChanged(value ?? wallet),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor HP E-Wallet',
            prefixIcon: Icon(Icons.phone_iphone_rounded),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Bayar dengan E-Wallet',
          icon: Icons.account_balance_wallet_rounded,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _CardPaymentPanel extends StatelessWidget {
  const _CardPaymentPanel({
    super.key,
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
    required this.errorMessage,
    required this.onSubmit,
  });

  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pembayaran Debit/Kredit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nomor kartu',
            prefixIcon: Icon(Icons.credit_card_rounded),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama pemilik kartu',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Masa berlaku',
                  hintText: 'MM/YY',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Bayar dengan Kartu',
          icon: Icons.lock_rounded,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _CashPaymentPanel extends StatelessWidget {
  const _CashPaymentPanel({
    super.key,
    required this.onSubmit,
  });

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pembayaran Tunai',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        const InlineNotice(
          icon: Icons.payments_rounded,
          accent: AppTheme.emerald,
          message: 'Silakan bayar di loket parkir saat masuk/keluar.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Konfirmasi Bayar Tunai',
          icon: Icons.check_rounded,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.blue : AppTheme.slate;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.blueSoft : AppTheme.slateSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppTheme.blue : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_paymentMethodIcon(method), color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              _paymentMethodLabel(method),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? AppTheme.ink : AppTheme.slate,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  const _PaymentSuccessDialog({
    required this.ticketNumber,
    required this.total,
    required this.method,
  });

  final String ticketNumber;
  final int total;
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppTheme.emeraldSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.emerald,
              size: 46,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Pembayaran Berhasil',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          SummaryRow(label: 'Nomor tiket', value: ticketNumber),
          SummaryRow(label: 'Total bayar', value: formatCurrency(total)),
          SummaryRow(label: 'Metode', value: _paymentMethodLabel(method)),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/customer/tickets');
            },
            icon: const Icon(Icons.qr_code_2_rounded),
            label: const Text(
              'Lihat Tiket QR',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

String _paymentMethodLabel(PaymentMethod method) {
  return switch (method) {
    PaymentMethod.qris => 'QRIS',
    PaymentMethod.ewallet => 'E-Wallet',
    PaymentMethod.cash => 'Tunai',
    PaymentMethod.card => 'Debit/Kredit',
  };
}

String _bookingStatusLabel(BookingStatus status) {
  return switch (status) {
    BookingStatus.pendingPayment => 'Menunggu Pembayaran',
    BookingStatus.paid => 'Lunas',
    BookingStatus.active => 'Aktif',
    BookingStatus.completed => 'Selesai',
  };
}

IconData _paymentMethodIcon(PaymentMethod method) {
  return switch (method) {
    PaymentMethod.qris => Icons.qr_code_rounded,
    PaymentMethod.ewallet => Icons.account_balance_wallet_rounded,
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.card => Icons.credit_card_rounded,
  };
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.blueSoft,
                  backgroundImage: state.customerAvatarBytes == null
                      ? null
                      : MemoryImage(state.customerAvatarBytes!),
                  child: state.customerAvatarBytes == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppTheme.blue,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  state.customerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.customerEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.customerPhone,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            onTap: () => context.push('/customer/edit-profile'),
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
            onTap: () => context.push('/customer/account-settings'),
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

class CustomerEditProfileScreen extends ConsumerStatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  ConsumerState<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState
    extends ConsumerState<CustomerEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _avatarPath;
  Uint8List? _avatarBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _nameController = TextEditingController(text: state.customerName);
    _emailController = TextEditingController(text: state.customerEmail);
    _phoneController = TextEditingController(text: state.customerPhone);
    _avatarPath = state.customerAvatarPath;
    _avatarBytes = state.customerAvatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    Uint8List? bytes;
    String? avatarPath = picked.path;

    if (kIsWeb) {
      bytes = await _showAvatarPreviewFallback(picked);
      if (bytes == null) {
        return;
      }
      ref.read(appControllerProvider.notifier).updateCustomerAvatar(bytes);
      setState(() {
        _avatarPath = avatarPath;
        _avatarBytes = bytes;
      });
      return;
    }

    final mediaSize = MediaQuery.sizeOf(context);
    final cropperHeightLimit = mediaSize.width >= 700 ? 360.0 : 260.0;
    final cropperHeight = math
        .min(cropperHeightLimit, (mediaSize.height * 0.80) - 156)
        .clamp(220.0, cropperHeightLimit)
        .round();
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Foto Profil',
            toolbarColor: AppTheme.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            cropStyle: CropStyle.rectangle,
          ),
          IOSUiSettings(
            title: 'Crop Foto Profil',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: CropperSize(width: 420, height: cropperHeight),
            customDialogBuilder: (cropper, initCropper, crop, rotate, scale) {
              return _ProfileCropperDialog(
                cropper: cropper,
                initCropper: initCropper,
                crop: crop,
                rotate: rotate,
                scale: scale,
              );
            },
            viewwMode: WebViewMode.mode_1,
            dragMode: WebDragMode.move,
            initialAspectRatio: 1,
            movable: true,
            scalable: true,
            zoomable: true,
            cropBoxMovable: true,
            cropBoxResizable: false,
            translations: const WebTranslations(
              title: 'Crop Foto Profil',
              rotateLeftTooltip: 'Putar kiri',
              rotateRightTooltip: 'Putar kanan',
              cropButton: 'Gunakan Foto Ini',
              cancelButton: 'Batal',
            ),
          ),
        ],
      );
      if (cropped == null) {
        return;
      }
      bytes = await cropped.readAsBytes();
      avatarPath = cropped.path;
    } catch (_) {
      bytes = await _showAvatarPreviewFallback(picked);
      if (bytes == null) {
        return;
      }
    }

    ref.read(appControllerProvider.notifier).updateCustomerAvatar(bytes);
    setState(() {
      _avatarPath = avatarPath;
      _avatarBytes = bytes;
    });
  }

  Future<Uint8List?> _showAvatarPreviewFallback(XFile picked) async {
    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return null;
    }
    return showDialog<Uint8List>(
      context: context,
      builder: (context) => _AvatarPreviewDialog(bytes: bytes),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama lengkap tidak boleh kosong.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Email tidak valid.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Nomor HP tidak boleh kosong.');
      return;
    }

    ref.read(appControllerProvider.notifier).updateCustomerProfile(
          name: name,
          email: email,
          phone: phone,
          avatarPath: _avatarPath,
          avatarBytes: _avatarBytes,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
    context.go('/customer/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.blueSoft,
                  backgroundImage:
                      _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
                  child: _avatarBytes == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: AppTheme.blue,
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
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.photo_camera_rounded, size: 18),
                        label: const Text('Ganti Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.blue,
                          side: BorderSide(
                            color: AppTheme.blue.withValues(alpha: 0.24),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                      if (_avatarBytes != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(appControllerProvider.notifier)
                                .clearCustomerAvatar();
                            setState(() {
                              _avatarPath = null;
                              _avatarBytes = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text('Hapus Foto'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: BorderSide(
                              color: const Color(0xFFDC2626)
                                  .withValues(alpha: 0.24),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
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
                    labelText: 'Nama lengkap',
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
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  InlineNotice(
                    icon: Icons.error_outline_rounded,
                    accent: const Color(0xFFDC2626),
                    message: _errorMessage!,
                  ),
                ],
                const SizedBox(height: 18),
                _CompactActionButton(
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

class _ProfileCropperDialog extends StatefulWidget {
  const _ProfileCropperDialog({
    required this.cropper,
    required this.initCropper,
    required this.crop,
    required this.rotate,
    required this.scale,
  });

  final Widget cropper;
  final VoidCallback initCropper;
  final Future<String?> Function() crop;
  final void Function(RotationAngle) rotate;
  final void Function(num) scale;

  @override
  State<_ProfileCropperDialog> createState() => _ProfileCropperDialogState();
}

class _ProfileCropperDialogState extends State<_ProfileCropperDialog> {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.initCropper();
      }
    });
  }

  Future<void> _usePhoto() async {
    if (_processing) {
      return;
    }
    setState(() => _processing = true);
    try {
      final result = await widget.crop();
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxHeight = mediaSize.height * 0.80;
    final previewLimit = mediaSize.width >= 700 ? 360.0 : 260.0;
    final previewHeight =
        math.min(previewLimit, math.max(220.0, maxHeight - 176));

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                'Atur Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: double.infinity,
                        height: previewHeight,
                        child: ColoredBox(
                          color: AppTheme.blueSoft,
                          child: widget.cropper,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Putar kiri',
                          onPressed: () =>
                              widget.rotate(RotationAngle.counterClockwise90),
                          icon: const Icon(Icons.rotate_left_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Zoom keluar',
                          onPressed: () => widget.scale(0.1),
                          icon: const Icon(Icons.zoom_out_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Zoom masuk',
                          onPressed: () => widget.scale(-0.1),
                          icon: const Icon(Icons.zoom_in_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Putar kanan',
                          onPressed: () =>
                              widget.rotate(RotationAngle.clockwise90),
                          icon: const Icon(Icons.rotate_right_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _processing ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _processing ? null : _usePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _processing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Gunakan Foto Ini'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPreviewDialog extends StatefulWidget {
  const _AvatarPreviewDialog({required this.bytes});

  final Uint8List bytes;

  @override
  State<_AvatarPreviewDialog> createState() => _AvatarPreviewDialogState();
}

class _AvatarPreviewDialogState extends State<_AvatarPreviewDialog> {
  double _zoom = 1;
  int _rotationQuarterTurns = 0;
  final GlobalKey _previewKey = GlobalKey();

  Future<Uint8List?> _capturePreviewBytes() async {
    final boundary = _previewKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      return widget.bytes;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List() ?? widget.bytes;
  }

  Future<void> _usePhoto() async {
    debugPrint('Atur Foto Profil: tombol Gunakan Foto Ini diklik');
    final bytes = await _capturePreviewBytes();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxHeight = mediaSize.height * 0.80;
    final previewLimit = mediaSize.width >= 700 ? 360.0 : 260.0;
    final previewSize = math.min(previewLimit, math.max(170.0, maxHeight - 214));

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                'Atur Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Center(
                child: RepaintBoundary(
                  key: _previewKey,
                  child: ClipOval(
                    child: ColoredBox(
                      color: AppTheme.blueSoft,
                      child: SizedBox(
                        width: previewSize,
                        height: previewSize,
                        child: Transform.rotate(
                          angle: _rotationQuarterTurns * math.pi / 2,
                          child: Transform.scale(
                            scale: _zoom,
                            child: Image.memory(
                              widget.bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Putar kiri',
                    onPressed: () {
                      debugPrint('Atur Foto Profil: tombol Putar kiri diklik');
                      setState(() => _rotationQuarterTurns--);
                    },
                    icon: const Icon(Icons.rotate_left_rounded),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Zoom keluar',
                    onPressed: () {
                      debugPrint('Atur Foto Profil: tombol Zoom keluar diklik');
                      setState(() {
                        _zoom = math.max(1, _zoom - 0.1);
                      });
                    },
                    icon: const Icon(Icons.zoom_out_rounded),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Zoom masuk',
                    onPressed: () {
                      debugPrint('Atur Foto Profil: tombol Zoom masuk diklik');
                      setState(() {
                        _zoom = math.min(2.5, _zoom + 0.1);
                      });
                    },
                    icon: const Icon(Icons.zoom_in_rounded),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Putar kanan',
                    onPressed: () {
                      debugPrint('Atur Foto Profil: tombol Putar kanan diklik');
                      setState(() => _rotationQuarterTurns++);
                    },
                    icon: const Icon(Icons.rotate_right_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        debugPrint('Atur Foto Profil: tombol Batal diklik');
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _usePhoto,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Gunakan Foto Ini'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerAccountSettingsScreen extends ConsumerStatefulWidget {
  const CustomerAccountSettingsScreen({super.key});

  @override
  ConsumerState<CustomerAccountSettingsScreen> createState() =>
      _CustomerAccountSettingsScreenState();
}

class _CustomerAccountSettingsScreenState
    extends ConsumerState<CustomerAccountSettingsScreen> {
  late final TextEditingController _passwordController;
  late bool _bookingNotificationEnabled;
  late bool _paymentNotificationEnabled;
  late bool _promoNotificationEnabled;
  late bool _accountSecurityEnabled;
  late String _selectedLanguage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _passwordController = TextEditingController();
    _bookingNotificationEnabled = state.bookingNotificationEnabled;
    _paymentNotificationEnabled = state.paymentNotificationEnabled;
    _promoNotificationEnabled = state.promoNotificationEnabled;
    _accountSecurityEnabled = state.accountSecurityEnabled;
    _selectedLanguage = state.selectedLanguage;
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

    ref.read(appControllerProvider.notifier).updateCustomerSettings(
          bookingNotificationEnabled: _bookingNotificationEnabled,
          paymentNotificationEnabled: _paymentNotificationEnabled,
          promoNotificationEnabled: _promoNotificationEnabled,
          selectedLanguage: _selectedLanguage,
          accountSecurityEnabled: _accountSecurityEnabled,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan akun berhasil disimpan')),
    );
    context.go('/customer/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Akun')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Ubah password',
                    hintText: 'Kosongkan jika tidak ingin mengubah',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _accountSecurityEnabled,
                  onChanged: (value) =>
                      setState(() => _accountSecurityEnabled = value),
                  title: const Text('Mode keamanan akun'),
                  subtitle: const Text('Aktifkan perlindungan tambahan akun.'),
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
                  'Notifikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _bookingNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _bookingNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi booking'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.blue,
                ),
                SwitchListTile(
                  value: _paymentNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _paymentNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi pembayaran'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.emerald,
                ),
                SwitchListTile(
                  value: _promoNotificationEnabled,
                  onChanged: (value) => setState(
                    () => _promoNotificationEnabled = value,
                  ),
                  title: const Text('Notifikasi promo'),
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
                  'Bahasa aplikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Pilih bahasa',
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
                    () => _selectedLanguage = value ?? 'Indonesia',
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
          _CompactActionButton(
            label: 'Simpan Pengaturan',
            icon: Icons.save_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
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
