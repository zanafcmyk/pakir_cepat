part of 'package:parkir_cepat/app.dart';

enum AccountMode { customer, provider }

enum AccountStatus { pending, verified, rejected }

enum VehicleKind { motor, mobil, truk }

enum PaymentMethod { qris, ewallet, cash, card }

enum BookingStatus { pendingPayment, paid, active, completed }

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
    required this.mapEmbedUrl,
    required this.latitude,
    required this.longitude,
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
  final String mapEmbedUrl;
  final double latitude;
  final double longitude;

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
    String? mapEmbedUrl,
    double? latitude,
    double? longitude,
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
      mapEmbedUrl: mapEmbedUrl ?? this.mapEmbedUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
    required this.status,
  });

  final String ticketNumber;
  final String slotCode;
  final String locationName;
  final String plateNumber;
  final String vehicleLabel;
  final DateTime entryTime;
  final int estimatedCost;
  final PaymentMethod paymentMethod;
  final BookingStatus status;

  bool get isPaid =>
      status == BookingStatus.paid ||
      status == BookingStatus.active ||
      status == BookingStatus.completed;

  bool get canShowTicket =>
      status == BookingStatus.paid || status == BookingStatus.active;

  Booking copyWith({
    String? ticketNumber,
    String? slotCode,
    String? locationName,
    String? plateNumber,
    String? vehicleLabel,
    DateTime? entryTime,
    int? estimatedCost,
    PaymentMethod? paymentMethod,
    BookingStatus? status,
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
      status: status ?? this.status,
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
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.customerAvatarPath,
    this.customerAvatarBytes,
    required this.bookingNotificationEnabled,
    required this.paymentNotificationEnabled,
    required this.promoNotificationEnabled,
    required this.selectedLanguage,
    required this.accountSecurityEnabled,
    required this.providerName,
    required this.providerEmail,
    required this.providerPhone,
    required this.businessName,
    required this.businessAddress,
    this.providerAvatarBytes,
    required this.transactionNotificationEnabled,
    required this.fullSlotNotificationEnabled,
    required this.newBookingNotificationEnabled,
    required this.providerSelectedLanguage,
    required this.providerSecurityEnabled,
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
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? customerAvatarPath;
  final Uint8List? customerAvatarBytes;
  final bool bookingNotificationEnabled;
  final bool paymentNotificationEnabled;
  final bool promoNotificationEnabled;
  final String selectedLanguage;
  final bool accountSecurityEnabled;
  final String providerName;
  final String providerEmail;
  final String providerPhone;
  final String businessName;
  final String businessAddress;
  final Uint8List? providerAvatarBytes;
  final bool transactionNotificationEnabled;
  final bool fullSlotNotificationEnabled;
  final bool newBookingNotificationEnabled;
  final String providerSelectedLanguage;
  final bool providerSecurityEnabled;
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
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAvatarPath,
    Uint8List? customerAvatarBytes,
    bool? bookingNotificationEnabled,
    bool? paymentNotificationEnabled,
    bool? promoNotificationEnabled,
    String? selectedLanguage,
    bool? accountSecurityEnabled,
    String? providerName,
    String? providerEmail,
    String? providerPhone,
    String? businessName,
    String? businessAddress,
    Uint8List? providerAvatarBytes,
    bool clearProviderAvatar = false,
    bool? transactionNotificationEnabled,
    bool? fullSlotNotificationEnabled,
    bool? newBookingNotificationEnabled,
    String? providerSelectedLanguage,
    bool? providerSecurityEnabled,
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
    bool clearCustomerAvatar = false,
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
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAvatarPath:
          clearCustomerAvatar ? null : (customerAvatarPath ?? this.customerAvatarPath),
      customerAvatarBytes: clearCustomerAvatar
          ? null
          : (customerAvatarBytes ?? this.customerAvatarBytes),
      bookingNotificationEnabled:
          bookingNotificationEnabled ?? this.bookingNotificationEnabled,
      paymentNotificationEnabled:
          paymentNotificationEnabled ?? this.paymentNotificationEnabled,
      promoNotificationEnabled:
          promoNotificationEnabled ?? this.promoNotificationEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      accountSecurityEnabled:
          accountSecurityEnabled ?? this.accountSecurityEnabled,
      providerName: providerName ?? this.providerName,
      providerEmail: providerEmail ?? this.providerEmail,
      providerPhone: providerPhone ?? this.providerPhone,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      providerAvatarBytes: clearProviderAvatar
          ? null
          : (providerAvatarBytes ?? this.providerAvatarBytes),
      transactionNotificationEnabled:
          transactionNotificationEnabled ?? this.transactionNotificationEnabled,
      fullSlotNotificationEnabled:
          fullSlotNotificationEnabled ?? this.fullSlotNotificationEnabled,
      newBookingNotificationEnabled:
          newBookingNotificationEnabled ?? this.newBookingNotificationEnabled,
      providerSelectedLanguage:
          providerSelectedLanguage ?? this.providerSelectedLanguage,
      providerSecurityEnabled:
          providerSecurityEnabled ?? this.providerSecurityEnabled,
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
        mapEmbedUrl:
            'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3966.4161452224284!2d106.82248539999999!3d-6.208714500000001!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e69f51300fe5895%3A0xa89d22dd2b5922c9!2sSudirman%20Plaza%20Gedung%20Plaza%20Marein!5e0!3m2!1sen!2sid!4v1780720226941!5m2!1sen!2sid',
        latitude: -6.208714500000001,
        longitude: 106.82248539999999,
      ),
      ParkingLot(
        id: 'lot-2',
        name: 'Mal Ciputra Tangerang',
        address: 'Jl. Citra Raya Boulevard, Tangerang',
        pricePerHour: 15000,
        availableSlots: 12,
        totalSlots: 70,
        distanceKm: 2.4,
        etaMinutes: 7,
        openHours: '05.00 - 23.30',
        rating: 4.8,
        accent: AppTheme.emerald,
        mapEmbedUrl:
            'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3966.021363564612!2d106.5250774!3d-6.260916!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e42077a46320d39%3A0x426b60f7dfe14e13!2sMal%20Ciputra%20Tangerang!5e0!3m2!1sid!2sid!4v1780720738829!5m2!1sid!2sid',
        latitude: -6.260916,
        longitude: 106.5250774,
      ),
      ParkingLot(
        id: 'lot-3',
        name: 'Citra Mall Parking Hub',
        address: 'Pusat Bisnis Thamrin City, Jakarta',
        pricePerHour: 10000,
        availableSlots: 0,
        totalSlots: 96,
        distanceKm: 3.1,
        etaMinutes: 9,
        openHours: '08.00 - 22.00',
        rating: 4.7,
        accent: AppTheme.slate,
        mapEmbedUrl:
            'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d15866.089919400229!2d106.8179532500215!3d-6.194579097638339!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e69f69e2ca1776f%3A0x729d6549e71fa7e7!2sPusat%20Bisnis%20Thamrin%20City!5e0!3m2!1sen!2sid!4v1780720526115!5m2!1sen!2sid',
        latitude: -6.194579097638339,
        longitude: 106.8179532500215,
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
      customerName: 'Dio Pratama',
      customerEmail: 'dio@parkircepat.app',
      customerPhone: '+62 812 7788 9911',
      customerAvatarPath: null,
      customerAvatarBytes: null,
      bookingNotificationEnabled: true,
      paymentNotificationEnabled: true,
      promoNotificationEnabled: false,
      selectedLanguage: 'Indonesia',
      accountSecurityEnabled: true,
      providerName: 'Dio Pratama',
      providerEmail: 'admin@parkircepat.app',
      providerPhone: '+62 812 7788 9911',
      businessName: 'Parkir Cepat Operator',
      businessAddress: 'Jl. Jenderal Sudirman No. 18, Jakarta',
      providerAvatarBytes: null,
      transactionNotificationEnabled: true,
      fullSlotNotificationEnabled: true,
      newBookingNotificationEnabled: true,
      providerSelectedLanguage: 'Indonesia',
      providerSecurityEnabled: true,
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
      customerEmail: mode == AccountMode.customer && email.isNotEmpty
          ? email
          : state.customerEmail,
      customerPhone: mode == AccountMode.customer && phoneNumber.isNotEmpty
          ? phoneNumber
          : state.customerPhone,
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
      customerName: mode == AccountMode.customer ? fullName : state.customerName,
      customerEmail: mode == AccountMode.customer ? email : state.customerEmail,
      customerPhone:
          mode == AccountMode.customer ? phoneNumber : state.customerPhone,
      providerName: mode == AccountMode.provider ? fullName : state.providerName,
      providerEmail: mode == AccountMode.provider ? email : state.providerEmail,
      providerPhone:
          mode == AccountMode.provider ? phoneNumber : state.providerPhone,
      businessName: mode == AccountMode.provider &&
              providerApplication != null
          ? providerApplication.parkingName
          : state.businessName,
      businessAddress: mode == AccountMode.provider &&
              providerApplication != null
          ? providerApplication.address
          : state.businessAddress,
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

  void updateCustomerProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarPath,
    Uint8List? avatarBytes,
  }) {
    state = state.copyWith(
      userName: name,
      email: email,
      phoneNumber: phone,
      customerName: name,
      customerEmail: email,
      customerPhone: phone,
      customerAvatarPath: avatarPath,
      customerAvatarBytes: avatarBytes,
    );
  }

  void updateCustomerAvatar(Uint8List bytes) {
    state = state.copyWith(customerAvatarBytes: bytes);
  }

  void clearCustomerAvatar() {
    state = state.copyWith(clearCustomerAvatar: true);
  }

  void updateCustomerSettings({
    required bool bookingNotificationEnabled,
    required bool paymentNotificationEnabled,
    required bool promoNotificationEnabled,
    required String selectedLanguage,
    required bool accountSecurityEnabled,
  }) {
    state = state.copyWith(
      bookingNotificationEnabled: bookingNotificationEnabled,
      paymentNotificationEnabled: paymentNotificationEnabled,
      promoNotificationEnabled: promoNotificationEnabled,
      selectedLanguage: selectedLanguage,
      accountSecurityEnabled: accountSecurityEnabled,
    );
  }

  void updateProviderProfile({
    required String name,
    required String email,
    required String phone,
    required String businessName,
    required String businessAddress,
    Uint8List? avatarBytes,
  }) {
    state = state.copyWith(
      userName: state.currentMode == AccountMode.provider ? name : state.userName,
      email: state.currentMode == AccountMode.provider ? email : state.email,
      phoneNumber:
          state.currentMode == AccountMode.provider ? phone : state.phoneNumber,
      providerName: name,
      providerEmail: email,
      providerPhone: phone,
      businessName: businessName,
      businessAddress: businessAddress,
      providerAvatarBytes: avatarBytes,
    );
  }

  void updateProviderAvatar(Uint8List bytes) {
    state = state.copyWith(providerAvatarBytes: bytes);
  }

  void clearProviderAvatar() {
    state = state.copyWith(clearProviderAvatar: true);
  }

  void updateProviderSettings({
    required bool transactionNotificationEnabled,
    required bool fullSlotNotificationEnabled,
    required bool newBookingNotificationEnabled,
    required String providerSelectedLanguage,
    required bool providerSecurityEnabled,
  }) {
    state = state.copyWith(
      transactionNotificationEnabled: transactionNotificationEnabled,
      fullSlotNotificationEnabled: fullSlotNotificationEnabled,
      newBookingNotificationEnabled: newBookingNotificationEnabled,
      providerSelectedLanguage: providerSelectedLanguage,
      providerSecurityEnabled: providerSecurityEnabled,
    );
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
      mapEmbedUrl: '',
      latitude: -6.2,
      longitude: 106.8,
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
      status: BookingStatus.pendingPayment,
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
      status: BookingStatus.paid,
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

