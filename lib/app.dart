import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) => AppController());

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/customer/map',
        builder: (context, state) => const CustomerMapScreen(),
      ),
      GoRoute(
        path: '/customer/tickets',
        builder: (context, state) => const CustomerTicketScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/customer/parking-detail',
        builder: (context, state) => const ParkingDetailScreen(),
      ),
      GoRoute(
        path: '/customer/add-vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/customer/booking',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/customer/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/customer/history',
        builder: (context, state) => const ParkingHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/map',
        builder: (context, state) => const AdminMapScreen(),
      ),
      GoRoute(
        path: '/admin/monitoring',
        builder: (context, state) => const VehicleMonitoringScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
      GoRoute(
        path: '/admin/add-lot',
        builder: (context, state) => const AddParkingLotScreen(),
      ),
      GoRoute(
        path: '/admin/scan-qr',
        builder: (context, state) => const ScanQrScreen(),
      ),
      GoRoute(
        path: '/admin/transaction-detail',
        builder: (context, state) => const TransactionDetailScreen(),
      ),
      GoRoute(
        path: '/admin/receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '/admin/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/admin/manage-slots',
        builder: (context, state) => const ManageSlotsScreen(),
      ),
    ],
  );
});

class ParkirCepatApp extends ConsumerWidget {
  const ParkirCepatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Parkir Cepat',
      routerConfig: router,
      theme: AppTheme.theme,
    );
  }
}

enum AccountMode { customer, provider }

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

class AppState {
  const AppState({
    required this.onboardingIndex,
    required this.onboardingDone,
    required this.isAuthenticated,
    required this.currentMode,
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
    required this.history,
    required this.customerNotifications,
    required this.adminNotifications,
  });

  final int onboardingIndex;
  final bool onboardingDone;
  final bool isAuthenticated;
  final AccountMode currentMode;
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
  final List<TransactionRecord> history;
  final List<NoticeItem> customerNotifications;
  final List<NoticeItem> adminNotifications;

  AppState copyWith({
    int? onboardingIndex,
    bool? onboardingDone,
    bool? isAuthenticated,
    AccountMode? currentMode,
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
    bool clearBooking = false,
    List<TransactionRecord>? history,
    List<NoticeItem>? customerNotifications,
    List<NoticeItem>? adminNotifications,
  }) {
    return AppState(
      onboardingIndex: onboardingIndex ?? this.onboardingIndex,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentMode: currentMode ?? this.currentMode,
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
      history: history,
      customerNotifications: customerNotifications,
      adminNotifications: adminNotifications,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  AppController() : super(AppState.seeded());

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
    state = state.copyWith(
      currentMode: mode,
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
  }) {
    state = state.copyWith(
      userName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      currentMode: mode,
      isAuthenticated: true,
      onboardingDone: true,
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
}

class AppTheme {
  static const white = Color(0xFFFFFFFF);
  static const blue = Color(0xFF1F6BFF);
  static const blueSoft = Color(0xFFEAF2FF);
  static const emerald = Color(0xFF0F9D7A);
  static const emeraldSoft = Color(0xFFE8F8F2);
  static const slate = Color(0xFF94A3B8);
  static const slateSoft = Color(0xFFF4F7FB);
  static const ink = Color(0xFF0F172A);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: blue,
        secondary: emerald,
        surface: white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slateSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: blue, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

String formatCurrency(int amount) => 'Rp ${amount.toString()}';

String formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      final state = ref.read(appControllerProvider);
      if (!state.onboardingDone) {
        context.go('/onboarding');
      } else if (!state.isAuthenticated) {
        context.go('/login');
      } else if (state.currentMode == AccountMode.customer) {
        context.go('/customer/home');
      } else {
        context.go('/admin/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.white, AppTheme.blueSoft, AppTheme.emeraldSoft],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [AppTheme.blue, AppTheme.emerald],
                    ),
                    boxShadow: [softShadow(AppTheme.blue.withValues(alpha: 0.2))],
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Parkir Cepat',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Smart parking futuristik untuk kota modern.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 30),
                const SmartCityIllustration(height: 170),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    color: AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;

  final _items = const [
    (
      title: 'Cari tempat parkir terdekat',
      body:
          'Lihat area parkir real-time dengan radius, estimasi waktu, dan status slot.',
      accent: AppTheme.blue,
      icon: Icons.map_rounded,
    ),
    (
      title: 'Booking parkir online',
      body:
          'Kunci slot terbaik dalam beberapa detik sebelum Anda tiba di lokasi.',
      accent: AppTheme.emerald,
      icon: Icons.book_online_rounded,
    ),
    (
      title: 'Pembayaran digital dan QR',
      body:
          'Masuk dan keluar lebih cepat dengan tiket QR premium dan pembayaran cashless.',
      accent: AppTheme.blue,
      icon: Icons.qr_code_2_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).finishOnboarding();
                    context.go('/login');
                  },
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged:
                      ref.read(appControllerProvider.notifier).setOnboardingPage,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmartCityIllustration(
                          height: 240,
                          accent: item.accent,
                          icon: item.icon,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.body,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.slate,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: state.onboardingIndex == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: state.onboardingIndex == index
                          ? AppTheme.blue
                          : AppTheme.slate.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: state.onboardingIndex == _items.length - 1
                    ? 'Mulai Sekarang'
                    : 'Lanjut',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (state.onboardingIndex == _items.length - 1) {
                    ref.read(appControllerProvider.notifier).finishOnboarding();
                    context.go('/login');
                    return;
                  }
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _rememberMe = true;
  AccountMode _mode = AccountMode.customer;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController(text: state.phoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Masuk ke Parkir Cepat',
      subtitle: 'Akses parkir pintar dengan alur cepat, aman, dan premium.',
      child: Column(
        children: [
          SegmentedChoice<AccountMode>(
            items: const [
              ChoiceItem(
                value: AccountMode.customer,
                label: 'Pengguna',
                icon: Icons.person_rounded,
              ),
              ChoiceItem(
                value: AccountMode.provider,
                label: 'Penyedia',
                icon: Icons.admin_panel_settings_rounded,
              ),
            ],
            value: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Switch(
                value: _rememberMe,
                activeThumbColor: AppTheme.blue,
                onChanged: (value) => setState(() => _rememberMe = value),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Lupa password'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Masuk',
            icon: Icons.login_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).login(
                    mode: _mode,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    rememberMe: _rememberMe,
                  );
              context.go(
                _mode == AccountMode.customer
                    ? '/customer/home'
                    : '/admin/dashboard',
              );
            },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Masuk dengan Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).login(
                    mode: _mode,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    rememberMe: _rememberMe,
                  );
              context.go(
                _mode == AccountMode.customer
                    ? '/customer/home'
                    : '/admin/dashboard',
              );
            },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Login nomor HP',
            icon: Icons.sms_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).login(
                    mode: _mode,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    rememberMe: _rememberMe,
                  );
              context.go(
                _mode == AccountMode.customer
                    ? '/customer/home'
                    : '/admin/dashboard',
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun?'),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  AccountMode _mode = AccountMode.customer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Dio Pratama');
    _emailController = TextEditingController(text: 'dio@parkircepat.app');
    _phoneController = TextEditingController(text: '+62 812 7788 9911');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Buat akun baru',
      subtitle: 'Pilih mode akun sesuai peran Anda di ekosistem smart parking.',
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama lengkap',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Konfirmasi password',
              prefixIcon: Icon(Icons.lock_reset_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SegmentedChoice<AccountMode>(
            items: const [
              ChoiceItem(
                value: AccountMode.customer,
                label: 'Pengguna',
                icon: Icons.person_rounded,
              ),
              ChoiceItem(
                value: AccountMode.provider,
                label: 'Penyedia parkir',
                icon: Icons.storefront_rounded,
              ),
            ],
            value: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Daftar',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).register(
                    fullName: _nameController.text,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    mode: _mode,
                  );
              context.go(
                _mode == AccountMode.customer
                    ? '/customer/home'
                    : '/admin/dashboard',
              );
            },
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Verifikasi akun dengan email atau nomor HP lalu atur ulang password.',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email / nomor HP',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (_otpSent) ...[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Kode OTP',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password baru',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            label: _otpSent ? 'Simpan password baru' : 'Kirim OTP',
            icon: _otpSent ? Icons.check_rounded : Icons.sms_rounded,
            onPressed: () {
              if (_otpSent) {
                ref.read(appControllerProvider.notifier).requestPasswordReset();
                context.pop();
              } else {
                setState(() => _otpSent = true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hapus akun')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFEA580C),
                  size: 34,
                ),
                const SizedBox(height: 18),
                Text(
                  'Konfirmasi hapus akun permanen',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tindakan ini akan menghapus data profil, kendaraan, tiket aktif, dan riwayat transaksi yang terhubung dengan akun Anda.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 18),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password verifikasi',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _agree,
                  onChanged: (value) => setState(() => _agree = value ?? false),
                  title: const Text('Saya memahami semua data akan hilang.'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Hapus akun permanen',
                  icon: Icons.delete_forever_rounded,
                  color: const Color(0xFFDC2626),
                  onPressed: _agree
                      ? () {
                          ref.read(appControllerProvider.notifier).deleteAccount();
                          context.go('/login');
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
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
    final lot = ref.watch(appControllerProvider).selectedLot ??
        ref.watch(appControllerProvider).lots.first;
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
                  SummaryRow(
                    label: 'Status pembayaran',
                    value: booking.isPaid ? 'Lunas' : 'Menunggu',
                    valueColor: booking.isPaid ? AppTheme.emerald : AppTheme.blue,
                  ),
                  const SizedBox(height: 22),
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
            ],
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
          ParkingMapCard(
            lots: state.lots,
            selected: state.selectedLot,
            onSelect: (lot) => ref.read(appControllerProvider.notifier).selectLot(lot),
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
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.emeraldSoft,
                  child: Icon(Icons.admin_panel_settings_rounded,
                      size: 40, color: AppTheme.emerald),
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin ${state.userName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola ${state.lots.length} lahan parkir',
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
            onTap: () {},
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.store_mall_directory_rounded,
            iconColor: AppTheme.emerald,
            title: 'Data lahan parkir',
            subtitle: '${state.lots.length} lokasi aktif',
            onTap: () => context.push('/admin/add-lot'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.settings_rounded,
            iconColor: AppTheme.slate,
            title: 'Pengaturan akun',
            subtitle: 'Atur preferensi operasional dan notifikasi.',
            onTap: () {},
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

class CustomerShell extends StatelessWidget {
  const CustomerShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,
      floatingActionButton: floatingActionButton,
      destinations: const [
        ShellDestination(label: 'Home', icon: Icons.home_rounded, route: '/customer/home'),
        ShellDestination(label: 'Map', icon: Icons.map_rounded, route: '/customer/map'),
        ShellDestination(label: 'Tiket', icon: Icons.confirmation_num_rounded, route: '/customer/tickets'),
        ShellDestination(label: 'Notifikasi', icon: Icons.notifications_rounded, route: '/customer/notifications'),
        ShellDestination(label: 'Profil', icon: Icons.person_rounded, route: '/customer/profile'),
      ],
      child: child,
    );
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,
      floatingActionButton: floatingActionButton,
      destinations: const [
        ShellDestination(label: 'Home', icon: Icons.space_dashboard_rounded, route: '/admin/dashboard'),
        ShellDestination(label: 'Map', icon: Icons.map_rounded, route: '/admin/map'),
        ShellDestination(label: 'Monitor', icon: Icons.radar_rounded, route: '/admin/monitoring'),
        ShellDestination(label: 'Notif', icon: Icons.notifications_rounded, route: '/admin/notifications'),
        ShellDestination(label: 'Profil', icon: Icons.person_rounded, route: '/admin/profile'),
      ],
      child: child,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.destinations,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final List<ShellDestination> destinations;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.16))],
          ),
          child: Row(
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
              final selected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(item.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.blueSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: selected ? AppTheme.blue : AppTheme.slate,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: selected ? AppTheme.blue : AppTheme.slate,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SmartCityIllustration(height: 180),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.slate,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 26),
            PremiumCard(child: child),
          ],
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.12))],
      ),
      child: child,
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.slate,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.title,
    required this.body,
    required this.accent,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final Color accent;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [softShadow(accent.withValues(alpha: 0.25))],
      ),
      child: Row(
        children: [
          const Expanded(
            child: SmartCityIllustration(height: 130, foreground: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: accent,
                  ),
                  onPressed: onPressed,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class ParkingLotCard extends StatelessWidget {
  const ParkingLotCard({
    super.key,
    required this.lot,
    required this.onDetail,
    required this.onBooking,
  });

  final ParkingLot lot;
  final VoidCallback onDetail;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lot.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.local_parking_rounded, color: lot.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.slate,
                          ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: lot.isFull ? 'Penuh' : 'Tersedia',
                color: lot.isFull ? AppTheme.slate : AppTheme.emerald,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricColumn(
                  label: 'Harga',
                  value: '${formatCurrency(lot.pricePerHour)}/jam',
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Slot',
                  value: '${lot.availableSlots}/${lot.totalSlots}',
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Jarak',
                  value: '${lot.distanceKm} km',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Detail',
                  icon: Icons.chevron_right_rounded,
                  onPressed: onDetail,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Booking',
                  icon: Icons.flash_on_rounded,
                  onPressed: lot.isFull ? null : onBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ParkingMapCard extends StatelessWidget {
  const ParkingMapCard({
    super.key,
    required this.lots,
    required this.selected,
    required this.onSelect,
  });

  final List<ParkingLot> lots;
  final ParkingLot? selected;
  final ValueChanged<ParkingLot> onSelect;

  @override
  Widget build(BuildContext context) {
    final positions = <Offset>[
      const Offset(0.22, 0.28),
      const Offset(0.68, 0.42),
      const Offset(0.42, 0.74),
      const Offset(0.8, 0.2),
    ];
    return PremiumCard(
      accent: AppTheme.slateSoft,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            const Positioned.fill(child: ParkingMapBackground()),
            for (var index = 0; index < lots.length; index++)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final lot = lots[index];
                    final point = positions[index % positions.length];
                    final isSelected = selected?.id == lot.id;
                    return Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * point.dx - 30,
                          top: constraints.maxHeight * point.dy - 30,
                          child: GestureDetector(
                            onTap: () => onSelect(lot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: isSelected ? 78 : 64,
                              height: isSelected ? 78 : 64,
                              decoration: BoxDecoration(
                                color: isSelected ? lot.accent : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  softShadow(lot.accent.withValues(alpha: 0.24)),
                                ],
                              ),
                              child: Icon(
                                Icons.local_parking_rounded,
                                color: isSelected ? Colors.white : lot.accent,
                                size: isSelected ? 34 : 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selected == null
                      ? 'Pilih marker'
                      : '${selected!.name} • ${selected!.etaMinutes} menit',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingMapBackground extends StatelessWidget {
  const ParkingMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter());
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = AppTheme.white
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final guide = Paint()
      ..color = AppTheme.blue.withValues(alpha: 0.15)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final green = Paint()
      ..color = AppTheme.emeraldSoft
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(26),
      ),
      Paint()..color = AppTheme.blueSoft,
    );

    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.2), 44, green);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.16), 34, green);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.8), 52, green);

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.35,
        size.width * 0.54,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.22,
        size.width * 0.88,
        size.height * 0.52,
      );
    final path2 = Path()
      ..moveTo(size.width * 0.18, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.48,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.72,
        size.width * 0.84,
        size.height * 0.58,
      );
    canvas.drawPath(path1, guide);
    canvas.drawPath(path1, road);
    canvas.drawPath(path2, guide);
    canvas.drawPath(path2, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmartCityIllustration extends StatelessWidget {
  const SmartCityIllustration({
    super.key,
    required this.height,
    this.accent = AppTheme.blue,
    this.icon = Icons.local_parking_rounded,
    this.foreground,
  });

  final double height;
  final Color accent;
  final IconData icon;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final iconColor = foreground ?? accent;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: height * 0.9,
              height: height * 0.18,
              decoration: BoxDecoration(
                color: (foreground ?? AppTheme.emeraldSoft).withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: height * 0.08,
            left: height * 0.12,
            child: _BuildingBlock(
              width: height * 0.17,
              height: height * 0.46,
              color: foreground?.withValues(alpha: 0.22) ?? AppTheme.blueSoft,
            ),
          ),
          Positioned(
            top: height * 0.02,
            right: height * 0.14,
            child: _BuildingBlock(
              width: height * 0.2,
              height: height * 0.58,
              color: foreground?.withValues(alpha: 0.22) ?? AppTheme.emeraldSoft,
            ),
          ),
          Positioned(
            bottom: height * 0.12,
            child: Container(
              width: height * 0.46,
              height: height * 0.34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: foreground == null ? 1 : 0.18),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: foreground?.withValues(alpha: 0.5) ?? accent.withValues(alpha: 0.16),
                ),
                boxShadow: foreground == null
                    ? [softShadow(accent.withValues(alpha: 0.16))]
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: height * 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingBlock extends StatelessWidget {
  const _BuildingBlock({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class MiniInfoTile extends StatelessWidget {
  const MiniInfoTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = AppTheme.blue,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.ink,
          side: BorderSide(color: AppTheme.blue.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class ChoiceItem<T> {
  const ChoiceItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<ChoiceItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? [softShadow(AppTheme.slate.withValues(alpha: 0.08))]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: selected ? AppTheme.blue : AppTheme.slate),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected ? AppTheme.blue : AppTheme.slate,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.blue),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class MetricColumn extends StatelessWidget {
  const MetricColumn({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.slate,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppTheme.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          const SmartCityIllustration(height: 140, accent: AppTheme.emerald),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.slate,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: actionLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<NoticeItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        HeaderSection(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.slate,
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.slate,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return Container(
      width: math.max(150, width),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.slate,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: math.max(150, width),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.ink),
            const SizedBox(height: 24),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 12,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.slate.withValues(alpha: 0.14),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.slate,
                    ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final text = value.toInt() >= 0 && value.toInt() < labels.length
                    ? labels[value.toInt()]
                    : '';
                return Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.slate,
                      ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3.5),
              FlSpot(1, 5.2),
              FlSpot(2, 4.6),
              FlSpot(3, 8.4),
              FlSpot(4, 7.8),
              FlSpot(5, 9.6),
              FlSpot(6, 11),
            ],
            isCurved: true,
            color: AppTheme.blue,
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, point, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.emerald,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.blue.withValues(alpha: 0.24),
                  AppTheme.blue.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingMapPlaceholder extends StatelessWidget {
  const ParkingMapPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 40, color: AppTheme.blue),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              display,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.blue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

BoxShadow softShadow(Color color) => BoxShadow(
      color: color,
      blurRadius: 24,
      offset: const Offset(0, 12),
    );
