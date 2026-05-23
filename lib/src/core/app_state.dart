part of 'package:parkir_cepat/app.dart';

enum AccountMode { customer, provider }

enum AccountStatus { pending, verified, rejected }

enum VehicleKind { motor, mobil, truk }

enum PaymentMethod { qris, ewallet, cash, card }

class ParkingLot {
  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.availableSlots,
    required this.totalSlots,
    required this.distanceKm,
    required this.etaMinutes,
    required this.openHours,
    required this.rating,
    required this.accent,
  });

  final String id;
  final String name;
  final String address;
  final int pricePerHour;
  final int availableSlots;
  final int totalSlots;
  final double distanceKm;
  final int etaMinutes;
  final String openHours;
  final double rating;
  final Color accent;

  bool get isFull => availableSlots <= 0;

  ParkingLot copyWith({
    String? id,
    String? name,
    String? address,
    int? pricePerHour,
    int? availableSlots,
    int? totalSlots,
    double? distanceKm,
    int? etaMinutes,
    String? openHours,
    double? rating,
    Color? accent,
  }) {
    return ParkingLot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      openHours: openHours ?? this.openHours,
      rating: rating ?? this.rating,
      accent: accent ?? this.accent,
    );
  }
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.kind,
    required this.quantity,
    required this.durationHours,
  });

  final String id;
  final String plateNumber;
  final VehicleKind kind;
  final int quantity;
  final int durationHours;

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    VehicleKind? kind,
    int? quantity,
    int? durationHours,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      durationHours: durationHours ?? this.durationHours,
    );
  }

  String get label => switch (kind) {
        VehicleKind.motor => 'Motor',
        VehicleKind.mobil => 'Mobil',
        VehicleKind.truk => 'Truk',
      };
}

class Booking {
  const Booking({
    required this.ticketNumber,
    required this.slotCode,
    required this.locationName,
    required this.plateNumber,
    required this.vehicleLabel,
    required this.entryTime,
    required this.estimatedCost,
    required this.paymentMethod,
    required this.isPaid,
  });

  final String ticketNumber;
  final String slotCode;
  final String locationName;
  final String plateNumber;
  final String vehicleLabel;
  final DateTime entryTime;
  final int estimatedCost;
  final PaymentMethod paymentMethod;
  final bool isPaid;

  Booking copyWith({
    String? ticketNumber,
    String? slotCode,
    String? locationName,
    String? plateNumber,
    String? vehicleLabel,
    DateTime? entryTime,
    int? estimatedCost,
    PaymentMethod? paymentMethod,
    bool? isPaid,
  }) {
    return Booking(
      ticketNumber: ticketNumber ?? this.ticketNumber,
      slotCode: slotCode ?? this.slotCode,
      locationName: locationName ?? this.locationName,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      entryTime: entryTime ?? this.entryTime,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.locationName,
    required this.plateNumber,
    required this.status,
    required this.total,
    required this.timeLabel,
  });

  final String id;
  final String locationName;
  final String plateNumber;
  final String status;
  final int total;
  final String timeLabel;
}

class NoticeItem {
  const NoticeItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color accent;
}

class ParkingSlot {
  const ParkingSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
  });

  final String id;
  final String label;
  final bool isAvailable;

  ParkingSlot copyWith({
    String? id,
    String? label,
    bool? isAvailable,
  }) {
    return ParkingSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class ProviderApplication {
  const ProviderApplication({
    required this.parkingName,
    required this.address,
    required this.photoLabel,
    required this.locationLabel,
    required this.capacity,
    required this.identityLabel,
  });

  final String parkingName;
  final String address;
  final String photoLabel;
  final String locationLabel;
  final int capacity;
  final String identityLabel;

  ProviderApplication copyWith({
    String? parkingName,
    String? address,
    String? photoLabel,
    String? locationLabel,
    int? capacity,
    String? identityLabel,
  }) {
    return ProviderApplication(
      parkingName: parkingName ?? this.parkingName,
      address: address ?? this.address,
      photoLabel: photoLabel ?? this.photoLabel,
      locationLabel: locationLabel ?? this.locationLabel,
      capacity: capacity ?? this.capacity,
      identityLabel: identityLabel ?? this.identityLabel,
    );
  }
}

class AppState {
  const AppState({
    required this.onboardingIndex,
    required this.onboardingDone,
    required this.isAuthenticated,
    required this.currentMode,
    required this.accountStatus,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.rememberMe,
    required this.passwordResetRequested,
    required this.lots,
    required this.selectedLot,
    required this.vehicles,
    required this.selectedVehicle,
    required this.slots,
    required this.activeBooking,
    required this.reservationLockedUntil,
    required this.favoriteLotIds,
    required this.providerApplication,
    required this.history,
    required this.customerNotifications,
    required this.adminNotifications,
  });

  final int onboardingIndex;
  final bool onboardingDone;
  final bool isAuthenticated;
  final AccountMode currentMode;
  final AccountStatus accountStatus;
  final String userName;
  final String email;
  final String phoneNumber;
  final bool rememberMe;
  final bool passwordResetRequested;
  final List<ParkingLot> lots;
  final ParkingLot? selectedLot;
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final List<ParkingSlot> slots;
  final Booking? activeBooking;
  final DateTime? reservationLockedUntil;
  final List<String> favoriteLotIds;
  final ProviderApplication? providerApplication;
  final List<TransactionRecord> history;
  final List<NoticeItem> customerNotifications;
  final List<NoticeItem> adminNotifications;

  AppState copyWith({
    int? onboardingIndex,
    bool? onboardingDone,
    bool? isAuthenticated,
    AccountMode? currentMode,
    AccountStatus? accountStatus,
    String? userName,
    String? email,
    String? phoneNumber,
    bool? rememberMe,
    bool? passwordResetRequested,
    List<ParkingLot>? lots,
    ParkingLot? selectedLot,
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    List<ParkingSlot>? slots,
    Booking? activeBooking,
    DateTime? reservationLockedUntil,
    bool clearBooking = false,
    List<String>? favoriteLotIds,
    ProviderApplication? providerApplication,
    bool clearProviderApplication = false,
    List<TransactionRecord>? history,
    List<NoticeItem>? customerNotifications,
    List<NoticeItem>? adminNotifications,
  }) {
    return AppState(
      onboardingIndex: onboardingIndex ?? this.onboardingIndex,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentMode: currentMode ?? this.currentMode,
      accountStatus: accountStatus ?? this.accountStatus,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rememberMe: rememberMe ?? this.rememberMe,
      passwordResetRequested:
          passwordResetRequested ?? this.passwordResetRequested,
      lots: lots ?? this.lots,
      selectedLot: selectedLot ?? this.selectedLot,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      slots: slots ?? this.slots,
      activeBooking: clearBooking ? null : (activeBooking ?? this.activeBooking),
      reservationLockedUntil:
          reservationLockedUntil ?? this.reservationLockedUntil,
      favoriteLotIds: favoriteLotIds ?? this.favoriteLotIds,
      providerApplication: clearProviderApplication
          ? null
          : (providerApplication ?? this.providerApplication),
      history: history ?? this.history,
      customerNotifications:
          customerNotifications ?? this.customerNotifications,
      adminNotifications: adminNotifications ?? this.adminNotifications,
    );
  }

  static AppState seeded() {
    const lots = [
      ParkingLot(
        id: 'lot-1',
        name: 'Parkir Plaza Sudirman',
        address: 'Jl. Jenderal Sudirman No. 18',
        pricePerHour: 12000,
        availableSlots: 36,
        totalSlots: 120,
        distanceKm: 1.2,
        etaMinutes: 4,
        openHours: '24 Jam',
        rating: 4.9,
        accent: AppTheme.blue,
      ),
      ParkingLot(
        id: 'lot-2',
        name: 'Emerald Smart Parking',
        address: 'Jl. Thamrin Smart City Blok A',
        pricePerHour: 15000,
        availableSlots: 12,
        totalSlots: 70,
        distanceKm: 2.4,
        etaMinutes: 7,
        openHours: '05.00 - 23.30',
        rating: 4.8,
        accent: AppTheme.emerald,
      ),
      ParkingLot(
        id: 'lot-3',
        name: 'Citra Mall Parking Hub',
        address: 'Jl. Gatot Subroto Timur No. 22',
        pricePerHour: 10000,
        availableSlots: 0,
        totalSlots: 96,
        distanceKm: 3.1,
        etaMinutes: 9,
        openHours: '08.00 - 22.00',
        rating: 4.7,
        accent: AppTheme.slate,
      ),
    ];

    const vehicles = [
      Vehicle(
        id: 'veh-1',
        plateNumber: 'B 1234 PCK',
        kind: VehicleKind.mobil,
        quantity: 1,
        durationHours: 2,
      ),
    ];

    const slots = [
      ParkingSlot(id: 'A1', label: 'A1', isAvailable: true),
      ParkingSlot(id: 'A2', label: 'A2', isAvailable: true),
      ParkingSlot(id: 'A3', label: 'A3', isAvailable: false),
      ParkingSlot(id: 'B1', label: 'B1', isAvailable: true),
      ParkingSlot(id: 'B2', label: 'B2', isAvailable: false),
      ParkingSlot(id: 'B3', label: 'B3', isAvailable: true),
    ];

    const customerNotifications = [
      NoticeItem(
        title: 'Booking berhasil',
        message: 'Slot A1 di Plaza Sudirman telah dikunci untuk Anda.',
        timeLabel: '2 menit lalu',
        icon: Icons.check_circle_rounded,
        accent: AppTheme.emerald,
      ),
      NoticeItem(
        title: 'Parkir hampir habis',
        message: 'Durasi parkir Anda akan selesai dalam 30 menit.',
        timeLabel: '12 menit lalu',
        icon: Icons.timelapse_rounded,
        accent: AppTheme.blue,
      ),
      NoticeItem(
        title: 'Pembayaran berhasil',
        message: 'Transaksi QRIS #INV-2048 sudah terkonfirmasi.',
        timeLabel: '1 jam lalu',
        icon: Icons.payments_rounded,
        accent: AppTheme.slate,
      ),
    ];

    const adminNotifications = [
      NoticeItem(
        title: 'Kendaraan masuk',
        message: 'B 1234 PCK masuk ke lot Sudirman pukul 08:21.',
        timeLabel: 'Baru saja',
        icon: Icons.directions_car_filled_rounded,
        accent: AppTheme.blue,
      ),
      NoticeItem(
        title: 'Slot hampir penuh',
        message: 'Emerald Smart Parking tersisa 12 slot aktif.',
        timeLabel: '10 menit lalu',
        icon: Icons.warning_amber_rounded,
        accent: AppTheme.emerald,
      ),
      NoticeItem(
        title: 'Pembayaran lunas',
        message: 'Transaksi harian bertambah Rp 32.000.',
        timeLabel: '45 menit lalu',
        icon: Icons.account_balance_wallet_rounded,
        accent: AppTheme.slate,
      ),
    ];

    const history = [
      TransactionRecord(
        id: 'INV-1940',
        locationName: 'Parkir Plaza Sudirman',
        plateNumber: 'B 1234 PCK',
        status: 'Lunas',
        total: 24000,
        timeLabel: 'Hari ini, 08:00 - 10:00',
      ),
      TransactionRecord(
        id: 'INV-1824',
        locationName: 'Emerald Smart Parking',
        plateNumber: 'B 1234 PCK',
        status: 'Lunas',
        total: 15000,
        timeLabel: 'Kemarin, 18:20 - 19:10',
      ),
    ];

    return AppState(
      onboardingIndex: 0,
      onboardingDone: false,
      isAuthenticated: false,
      currentMode: AccountMode.customer,
      accountStatus: AccountStatus.verified,
      userName: 'Dio Pratama',
      email: 'dio@parkircepat.app',
      phoneNumber: '+62 812 7788 9911',
      rememberMe: true,
      passwordResetRequested: false,
      lots: lots,
      selectedLot: lots.first,
      vehicles: vehicles,
      selectedVehicle: vehicles.first,
      slots: slots,
      activeBooking: null,
      reservationLockedUntil: null,
      favoriteLotIds: ['lot-1'],
      providerApplication: null,
      history: history,
      customerNotifications: customerNotifications,
      adminNotifications: adminNotifications,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  AppController() : super(AppState.seeded());

  String landingRouteFor(AppState value) {
    if (value.currentMode == AccountMode.provider &&
        value.accountStatus == AccountStatus.pending) {
      return '/provider-verification';
    }
    if (value.currentMode == AccountMode.provider) {
      return '/admin/dashboard';
    }
    return '/customer/home';
  }

  void setOnboardingPage(int index) {
    state = state.copyWith(onboardingIndex: index);
  }

  void finishOnboarding() {
    state = state.copyWith(onboardingDone: true);
  }

  void login({
    required AccountMode mode,
    required String email,
    required String phoneNumber,
    required bool rememberMe,
  }) {
    final accountStatus = mode == AccountMode.provider
        ? (state.providerApplication == null
            ? AccountStatus.verified
            : state.accountStatus)
        : AccountStatus.verified;
    state = state.copyWith(
      currentMode: mode,
      accountStatus: accountStatus,
      email: email.isEmpty ? state.email : email,
      phoneNumber: phoneNumber.isEmpty ? state.phoneNumber : phoneNumber,
      isAuthenticated: true,
      rememberMe: rememberMe,
    );
  }

  void register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required AccountMode mode,
    ProviderApplication? providerApplication,
  }) {
    state = state.copyWith(
      userName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      currentMode: mode,
      isAuthenticated: true,
      onboardingDone: true,
      accountStatus: mode == AccountMode.customer
          ? AccountStatus.verified
          : AccountStatus.pending,
      providerApplication: providerApplication,
    );
  }

  void requestPasswordReset() {
    state = state.copyWith(passwordResetRequested: true);
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }

  void deleteAccount() {
    final seeded = AppState.seeded();
    state = seeded;
  }

  void switchMode(AccountMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  void setProviderStatus(AccountStatus status) {
    state = state.copyWith(accountStatus: status);
  }

  void selectLot(ParkingLot lot) {
    state = state.copyWith(selectedLot: lot);
  }

  void addLot({
    required String name,
    required String address,
    required int capacity,
    required int price,
  }) {
    final lot = ParkingLot(
      id: 'lot-${state.lots.length + 1}',
      name: name,
      address: address,
      pricePerHour: price,
      availableSlots: capacity,
      totalSlots: capacity,
      distanceKm: 0.8,
      etaMinutes: 3,
      openHours: '24 Jam',
      rating: 4.8,
      accent: AppTheme.emerald,
    );
    state = state.copyWith(
      lots: [lot, ...state.lots],
      selectedLot: lot,
    );
  }

  void toggleFavoriteLot(String lotId) {
    final current = [...state.favoriteLotIds];
    if (current.contains(lotId)) {
      current.remove(lotId);
    } else {
      current.add(lotId);
    }
    state = state.copyWith(favoriteLotIds: current);
  }

  void saveVehicle({
    required String plateNumber,
    required VehicleKind kind,
    required int quantity,
    required int durationHours,
  }) {
    final vehicle = Vehicle(
      id: 'veh-${state.vehicles.length + 1}',
      plateNumber: plateNumber,
      kind: kind,
      quantity: quantity,
      durationHours: durationHours,
    );
    state = state.copyWith(
      vehicles: [vehicle, ...state.vehicles],
      selectedVehicle: vehicle,
    );
  }

  void createBooking({
    required String slotCode,
    required DateTime entryTime,
  }) {
    final lot = state.selectedLot ?? state.lots.first;
    final vehicle = state.selectedVehicle ?? state.vehicles.first;
    final total = lot.pricePerHour * vehicle.durationHours;
    final booking = Booking(
      ticketNumber: 'TKT-${1000 + state.history.length}',
      slotCode: slotCode,
      locationName: lot.name,
      plateNumber: vehicle.plateNumber,
      vehicleLabel: vehicle.label,
      entryTime: entryTime,
      estimatedCost: total,
      paymentMethod: PaymentMethod.qris,
      isPaid: false,
    );

    final updatedSlots = [
      for (final slot in state.slots)
        if (slot.label == slotCode)
          slot.copyWith(isAvailable: false)
        else
          slot,
    ];

    state = state.copyWith(
      activeBooking: booking,
      reservationLockedUntil: DateTime.now().add(const Duration(minutes: 15)),
      slots: updatedSlots,
      customerNotifications: [
        NoticeItem(
          title: 'Booking berhasil',
          message: 'Slot $slotCode di ${lot.name} siap digunakan.',
          timeLabel: 'Baru saja',
          icon: Icons.local_parking_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.customerNotifications,
      ],
      adminNotifications: [
        NoticeItem(
          title: 'Slot baru terpakai',
          message: 'Reservasi $slotCode dibuat oleh ${vehicle.plateNumber}.',
          timeLabel: 'Baru saja',
          icon: Icons.qr_code_scanner_rounded,
          accent: AppTheme.blue,
        ),
        ...state.adminNotifications,
      ],
    );
  }

  void payBooking(PaymentMethod method) {
    final booking = state.activeBooking;
    if (booking == null) {
      return;
    }
    final updatedBooking = booking.copyWith(
      paymentMethod: method,
      isPaid: true,
    );
    final transaction = TransactionRecord(
      id: booking.ticketNumber,
      locationName: booking.locationName,
      plateNumber: booking.plateNumber,
      status: 'Lunas',
      total: booking.estimatedCost,
      timeLabel: formatDateTime(booking.entryTime),
    );
    state = state.copyWith(
      activeBooking: updatedBooking,
      reservationLockedUntil: null,
      history: [transaction, ...state.history],
      customerNotifications: [
        NoticeItem(
          title: 'Pembayaran berhasil',
          message: 'Tiket ${booking.ticketNumber} telah dibayar.',
          timeLabel: 'Baru saja',
          icon: Icons.payments_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.customerNotifications,
      ],
      adminNotifications: [
        NoticeItem(
          title: 'Pembayaran berhasil',
          message: '${booking.plateNumber} menyelesaikan pembayaran parkir.',
          timeLabel: 'Baru saja',
          icon: Icons.verified_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.adminNotifications,
      ],
    );
  }

  void markVehicleExit() {
    final booking = state.activeBooking;
    if (booking == null) {
      return;
    }
    final updatedSlots = [
      for (final slot in state.slots)
        if (slot.label == booking.slotCode)
          slot.copyWith(isAvailable: true)
        else
          slot,
    ];
    state = state.copyWith(
      slots: updatedSlots,
      clearBooking: true,
      reservationLockedUntil: null,
      adminNotifications: [
        const NoticeItem(
          title: 'Kendaraan keluar',
          message: 'Tiket aktif berhasil ditutup dan slot dibuka kembali.',
          timeLabel: 'Baru saja',
          icon: Icons.exit_to_app_rounded,
          accent: AppTheme.blue,
        ),
        ...state.adminNotifications,
      ],
    );
  }

  void toggleSlot(String id) {
    final updated = [
      for (final slot in state.slots)
        if (slot.id == id)
          slot.copyWith(isAvailable: !slot.isAvailable)
        else
          slot,
    ];
    state = state.copyWith(slots: updated);
  }

  void extendParkingTime(int additionalHours) {
    final vehicle = state.selectedVehicle;
    final booking = state.activeBooking;
    if (vehicle == null || booking == null) {
      return;
    }

    final updatedVehicle = vehicle.copyWith(
      durationHours: vehicle.durationHours + additionalHours,
    );
    final updatedVehicles = [
      for (final item in state.vehicles)
        if (item.id == vehicle.id) updatedVehicle else item,
    ];
    final lot = state.selectedLot ?? state.lots.first;
    state = state.copyWith(
      vehicles: updatedVehicles,
      selectedVehicle: updatedVehicle,
      activeBooking: booking.copyWith(
        estimatedCost: booking.estimatedCost + (lot.pricePerHour * additionalHours),
      ),
      customerNotifications: [
        NoticeItem(
          title: 'Durasi parkir diperpanjang',
          message: 'Tambahan $additionalHours jam berhasil diterapkan.',
          timeLabel: 'Baru saja',
          icon: Icons.more_time_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.customerNotifications,
      ],
    );
  }
}

