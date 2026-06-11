import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'models/app_models.dart';
import 'utils/parking_lot_photo_picker.dart';
import 'widgets/provider_map_embed_view.dart';

const plazaSudirmanMapEmbedUrl =
    'https://www.google.com/maps?q=-6.2087145,106.8224854&z=17&output=embed';
const plazaSudirmanLocationName = 'Plaza Sudirman';
const plazaSudirmanLatitude = -6.2087145;
const plazaSudirmanLongitude = 106.8224854;

final appControllerProvider = StateNotifierProvider<AppController, AppState>(
  (ref) => AppController(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
        path: '/provider-verification',
        builder: (context, state) => const ProviderVerificationScreen(),
      ),
      GoRoute(
        path: '/super-admin/dashboard',
        builder: (context, state) => const SuperAdminDashboardScreen(),
      ),
      GoRoute(
        path: '/super-admin/users',
        builder: (context, state) => const SuperAdminUsersScreen(),
      ),
      GoRoute(
        path: '/super-admin/reports',
        builder: (context, state) => const SuperAdminReportsScreen(),
      ),
      GoRoute(
        path: '/super-admin/complaints',
        builder: (context, state) => const SuperAdminComplaintsScreen(),
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
        path: '/provider/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/provider/map',
        builder: (context, state) => const AdminMapScreen(),
      ),
      GoRoute(
        path: '/provider/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/provider/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
      GoRoute(
        path: '/provider/add-lot',
        builder: (context, state) =>
            AddParkingLotScreen(lot: state.extra as ParkingLot?),
      ),
      GoRoute(
        path: '/provider/guards',
        builder: (context, state) => const ParkingGuardManagementScreen(),
      ),
      GoRoute(
        path: '/provider/transaction-detail',
        builder: (context, state) => const TransactionDetailScreen(),
      ),
      GoRoute(
        path: '/provider/receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '/provider/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/provider/feedback',
        builder: (context, state) => const ProviderFeedbackScreen(),
      ),
      GoRoute(
        path: '/provider/manage-slots',
        builder: (context, state) => const ManageSlotsScreen(),
      ),
      GoRoute(
        path: '/guard/dashboard',
        builder: (context, state) => const ParkingGuardDashboardScreen(),
      ),
      GoRoute(
        path: '/guard/scan-qr',
        builder: (context, state) => const ScanQrScreen(),
      ),
      GoRoute(
        path: '/guard/vehicles',
        builder: (context, state) => const GuardVehiclesScreen(),
      ),
      GoRoute(
        path: '/guard/slots',
        builder: (context, state) => const ManageSlotsScreen(),
      ),
      GoRoute(
        path: '/guard/profile',
        builder: (context, state) => const GuardProfileScreen(),
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
        builder: (context, state) =>
            AddParkingLotScreen(lot: state.extra as ParkingLot?),
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
    required this.parkingGuards,
    required this.activeGuardId,
    required this.history,
    required this.customerNotifications,
    required this.adminNotifications,
    required this.providerFeedback,
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
  final List<ParkingGuardAccount> parkingGuards;
  final String? activeGuardId;
  final List<TransactionRecord> history;
  final List<NoticeItem> customerNotifications;
  final List<NoticeItem> adminNotifications;
  final List<ProviderFeedback> providerFeedback;

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
    List<ParkingGuardAccount>? parkingGuards,
    String? activeGuardId,
    bool clearActiveGuard = false,
    List<TransactionRecord>? history,
    List<NoticeItem>? customerNotifications,
    List<NoticeItem>? adminNotifications,
    List<ProviderFeedback>? providerFeedback,
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
      activeBooking: clearBooking
          ? null
          : (activeBooking ?? this.activeBooking),
      reservationLockedUntil:
          reservationLockedUntil ?? this.reservationLockedUntil,
      favoriteLotIds: favoriteLotIds ?? this.favoriteLotIds,
      providerApplication: clearProviderApplication
          ? null
          : (providerApplication ?? this.providerApplication),
      parkingGuards: parkingGuards ?? this.parkingGuards,
      activeGuardId: clearActiveGuard
          ? null
          : (activeGuardId ?? this.activeGuardId),
      history: history ?? this.history,
      customerNotifications:
          customerNotifications ?? this.customerNotifications,
      adminNotifications: adminNotifications ?? this.adminNotifications,
      providerFeedback: providerFeedback ?? this.providerFeedback,
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

    const guards = [
      ParkingGuardAccount(
        id: 'guard-1',
        name: 'Raka Penjaga',
        email: 'raka.guard@parkircepat.app',
        phoneNumber: '+62 812 2222 3344',
        providerId: 'provider-main',
        assignedLotIds: ['lot-1', 'lot-2'],
        canScanQr: true,
        canConfirmCash: true,
        canManageSlots: true,
      ),
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

    const providerFeedback = [
      ProviderFeedback(
        id: 'fb-1',
        lotId: 'lot-1',
        lotName: 'Parkir Plaza Sudirman',
        customerName: 'Nadia Putri',
        rating: 5,
        review:
            'Lokasi mudah ditemukan, penjaga responsif, dan slot sesuai tiket.',
        timeLabel: 'Hari ini, 10:20',
        isComplaint: false,
        status: 'Puas',
      ),
      ProviderFeedback(
        id: 'fb-2',
        lotId: 'lot-2',
        lotName: 'Emerald Smart Parking',
        customerName: 'Bima Arya',
        rating: 4,
        review:
            'Pembayaran lancar, tapi marka slot dekat pintu masuk perlu diperjelas.',
        timeLabel: 'Kemarin, 18:40',
        isComplaint: false,
        status: 'Perlu tindak lanjut ringan',
        providerReply:
            'Terima kasih, tim sudah menjadwalkan pengecatan ulang marka.',
      ),
      ProviderFeedback(
        id: 'fb-3',
        lotId: 'lot-1',
        lotName: 'Parkir Plaza Sudirman',
        customerName: 'Rafi Mahendra',
        rating: 2,
        review:
            'Saya sudah booking, tetapi sempat diarahkan ke slot yang penuh.',
        timeLabel: '2 hari lalu',
        isComplaint: true,
        status: 'Menunggu balasan',
      ),
      ProviderFeedback(
        id: 'fb-4',
        lotId: 'lot-3',
        lotName: 'Citra Mall Parking Hub',
        customerName: 'Salsa Amira',
        rating: 3,
        review: 'Antrean keluar cukup lama saat jam pulang kantor.',
        timeLabel: '3 hari lalu',
        isComplaint: true,
        status: 'Dibalas',
        providerReply:
            'Kami sudah menambah penjaga di pintu keluar saat jam sibuk.',
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
      parkingGuards: guards,
      activeGuardId: null,
      history: history,
      customerNotifications: customerNotifications,
      adminNotifications: adminNotifications,
      providerFeedback: providerFeedback,
    );
  }
}

String roleLabel(AccountMode mode) => switch (mode) {
  AccountMode.superAdmin => 'Super Admin',
  AccountMode.provider => 'Penyedia Parkir',
  AccountMode.parkingGuard => 'Penjaga Parkir',
  AccountMode.customer => 'Pelanggan',
};

IconData roleIcon(AccountMode mode) => switch (mode) {
  AccountMode.superAdmin => Icons.admin_panel_settings_rounded,
  AccountMode.provider => Icons.apartment_rounded,
  AccountMode.parkingGuard => Icons.security_rounded,
  AccountMode.customer => Icons.map_rounded,
};

ParkingGuardAccount? activeGuard(AppState state) {
  for (final guard in state.parkingGuards) {
    if (guard.id == state.activeGuardId) {
      return guard;
    }
  }
  return null;
}

List<ParkingLot> visibleLotsFor(AppState state) {
  final guard = activeGuard(state);
  return switch (state.currentMode) {
    AccountMode.parkingGuard when guard != null =>
      state.lots.where((lot) => guard.assignedLotIds.contains(lot.id)).toList(),
    AccountMode.provider =>
      state.lots.where((lot) => lot.providerId == 'provider-main').toList(),
    _ => state.lots,
  };
}

List<ProviderFeedback> providerFeedbackFor(AppState state) {
  final providerLotIds = state.lots
      .where((lot) => lot.providerId == 'provider-main')
      .map((lot) => lot.id)
      .toSet();
  return state.providerFeedback
      .where((item) => providerLotIds.contains(item.lotId))
      .toList();
}

double averageFeedbackRating(List<ProviderFeedback> feedback) {
  if (feedback.isEmpty) return 0;
  final total = feedback.fold<double>(0, (sum, item) => sum + item.rating);
  return total / feedback.length;
}

int satisfactionScore(List<ProviderFeedback> feedback) {
  if (feedback.isEmpty) return 0;
  final satisfied = feedback.where((item) => item.rating >= 4).length;
  return ((satisfied / feedback.length) * 100).round();
}

int tariffRateForVehicle(ParkingLot lot, VehicleKind kind) {
  return switch (kind) {
    VehicleKind.motor => lot.motorRate ?? lot.pricePerHour,
    VehicleKind.mobil => lot.carRate ?? lot.pricePerHour,
    VehicleKind.truk => lot.truckRate ?? lot.pricePerHour,
  };
}

int calculateParkingCost(ParkingLot lot, Vehicle vehicle) {
  final rate = tariffRateForVehicle(lot, vehicle.kind);
  final duration = math.max(1, vehicle.durationHours);
  return switch (lot.tariffType) {
    ParkingTariffType.hourly => rate * duration,
    ParkingTariffType.flat => rate,
    ParkingTariffType.daily => rate * math.max(1, (duration / 24).ceil()),
    ParkingTariffType.progressive =>
      rate + ((duration - 1) * (rate * 0.5)).round(),
  };
}

String tariffTypeLabel(ParkingTariffType type) => switch (type) {
  ParkingTariffType.hourly => 'Per jam',
  ParkingTariffType.flat => 'Flat',
  ParkingTariffType.daily => 'Harian',
  ParkingTariffType.progressive => 'Progresif',
};

String parkingLotTariffSummary(ParkingLot lot) {
  final suffix = switch (lot.tariffType) {
    ParkingTariffType.hourly => '/jam',
    ParkingTariffType.flat => ' flat',
    ParkingTariffType.daily => '/hari',
    ParkingTariffType.progressive => ' progresif',
  };
  return 'Motor ${formatCurrency(lot.motorRate ?? lot.pricePerHour)}$suffix';
}

class AppController extends StateNotifier<AppState> {
  AppController() : super(AppState.seeded());

  String landingRouteFor(AppState value) {
    if (value.currentMode == AccountMode.provider &&
        value.accountStatus == AccountStatus.pending) {
      return '/provider-verification';
    }
    return switch (value.currentMode) {
      AccountMode.superAdmin => '/super-admin/dashboard',
      AccountMode.provider => '/provider/dashboard',
      AccountMode.parkingGuard => '/guard/dashboard',
      AccountMode.customer => '/customer/home',
    };
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
    final guardId = mode == AccountMode.parkingGuard
        ? (state.activeGuardId ?? state.parkingGuards.first.id)
        : null;
    state = state.copyWith(
      currentMode: mode,
      accountStatus: accountStatus,
      email: email.isEmpty ? state.email : email,
      phoneNumber: phoneNumber.isEmpty ? state.phoneNumber : phoneNumber,
      isAuthenticated: true,
      rememberMe: rememberMe,
      activeGuardId: guardId,
      clearActiveGuard: mode != AccountMode.parkingGuard,
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
      accountStatus: mode == AccountMode.provider
          ? AccountStatus.pending
          : AccountStatus.verified,
      activeGuardId: mode == AccountMode.parkingGuard
          ? state.parkingGuards.first.id
          : null,
      clearActiveGuard: mode != AccountMode.parkingGuard,
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
    state = state.copyWith(
      currentMode: mode,
      activeGuardId: mode == AccountMode.parkingGuard
          ? (state.activeGuardId ?? state.parkingGuards.first.id)
          : null,
      clearActiveGuard: mode != AccountMode.parkingGuard,
    );
  }

  void createParkingGuard({
    required String name,
    required String email,
    required String phoneNumber,
    required List<String> assignedLotIds,
    required bool canScanQr,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) {
    final guard = ParkingGuardAccount(
      id: 'guard-${state.parkingGuards.length + 1}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      providerId: 'provider-main',
      assignedLotIds: assignedLotIds,
      canScanQr: canScanQr,
      canConfirmCash: canConfirmCash,
      canManageSlots: canManageSlots,
    );
    state = state.copyWith(parkingGuards: [guard, ...state.parkingGuards]);
  }

  void updateParkingGuard({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required List<String> assignedLotIds,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) {
    ParkingGuardAccount? updatedGuard;
    final updatedGuards = [
      for (final guard in state.parkingGuards)
        if (guard.id == id)
          updatedGuard = ParkingGuardAccount(
            id: guard.id,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            providerId: guard.providerId,
            assignedLotIds: assignedLotIds,
            canScanQr: guard.canScanQr,
            canConfirmCash: canConfirmCash,
            canManageSlots: canManageSlots,
          )
        else
          guard,
    ];
    if (updatedGuard == null) return;

    state = state.copyWith(
      parkingGuards: updatedGuards,
      adminNotifications: [
        NoticeItem(
          title: 'Akun penjaga diperbarui',
          message: 'Data dan akses ${updatedGuard.name} berhasil diperbarui.',
          timeLabel: 'Baru saja',
          icon: Icons.manage_accounts_rounded,
          accent: AppTheme.blue,
        ),
        ...state.adminNotifications,
      ],
    );
  }

  void deleteParkingGuard(String id) {
    final updatedGuards = state.parkingGuards
        .where((guard) => guard.id != id)
        .toList();
    if (updatedGuards.length == state.parkingGuards.length) return;

    final activeWasDeleted = state.activeGuardId == id;
    state = state.copyWith(
      parkingGuards: updatedGuards,
      activeGuardId: activeWasDeleted && updatedGuards.isNotEmpty
          ? updatedGuards.first.id
          : state.activeGuardId,
      clearActiveGuard: activeWasDeleted && updatedGuards.isEmpty,
      adminNotifications: [
        const NoticeItem(
          title: 'Akun penjaga dihapus',
          message: 'Akun penjaga berhasil dihapus dari penyedia.',
          timeLabel: 'Baru saja',
          icon: Icons.person_remove_rounded,
          accent: Color(0xFFDC2626),
        ),
        ...state.adminNotifications,
      ],
    );
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
    required String mapEmbedUrl,
    required double latitude,
    required double longitude,
    required ParkingTariffType tariffType,
    required int motorRate,
    required int carRate,
    required int truckRate,
    String? photoLabel,
    Uint8List? photoBytes,
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
      mapEmbedUrl: mapEmbedUrl,
      latitude: latitude,
      longitude: longitude,
      tariffType: tariffType,
      motorRate: motorRate,
      carRate: carRate,
      truckRate: truckRate,
      photoLabel: photoLabel,
      photoBytes: photoBytes,
    );
    state = state.copyWith(lots: [lot, ...state.lots], selectedLot: lot);
  }

  void updateLot({
    required String id,
    required String name,
    required String address,
    required int capacity,
    required int price,
    required String mapEmbedUrl,
    required double latitude,
    required double longitude,
    required ParkingTariffType tariffType,
    required int motorRate,
    required int carRate,
    required int truckRate,
    String? photoLabel,
    Uint8List? photoBytes,
  }) {
    ParkingLot? updatedLot;
    ParkingLot? previousLot;
    final updatedLots = [
      for (final lot in state.lots)
        if (lot.id == id)
          updatedLot = (previousLot = lot).copyWith(
            name: name,
            address: address,
            pricePerHour: price,
            availableSlots: math.min(lot.availableSlots, capacity),
            totalSlots: capacity,
            mapEmbedUrl: mapEmbedUrl,
            latitude: latitude,
            longitude: longitude,
            tariffType: tariffType,
            motorRate: motorRate,
            carRate: carRate,
            truckRate: truckRate,
            photoLabel: photoLabel,
            photoBytes: photoBytes,
          )
        else
          lot,
    ];
    if (updatedLot == null) return;
    final oldLot = previousLot;
    final tariffChanged =
        oldLot != null &&
        (oldLot.tariffType != tariffType ||
            (oldLot.motorRate ?? oldLot.pricePerHour) != motorRate ||
            (oldLot.carRate ?? oldLot.pricePerHour) != carRate ||
            (oldLot.truckRate ?? oldLot.pricePerHour) != truckRate);

    state = state.copyWith(
      lots: updatedLots,
      selectedLot: state.selectedLot?.id == id ? updatedLot : state.selectedLot,
      adminNotifications: [
        if (tariffChanged)
          NoticeItem(
            title: 'Tarif berubah',
            message:
                'Tarif ${updatedLot.name} diperbarui: motor ${formatCurrency(motorRate)}, mobil ${formatCurrency(carRate)}, truk ${formatCurrency(truckRate)}.',
            timeLabel: 'Baru saja',
            icon: Icons.price_change_rounded,
            accent: AppTheme.blue,
          ),
        NoticeItem(
          title: 'Lahan berhasil diedit',
          message: '${updatedLot.name} berhasil diperbarui oleh penyedia.',
          timeLabel: 'Baru saja',
          icon: Icons.edit_location_alt_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.adminNotifications,
      ],
    );
  }

  void deleteLot(String id) {
    if (state.lots.length <= 1) return;
    final updatedLots = state.lots.where((lot) => lot.id != id).toList();
    if (updatedLots.length == state.lots.length) return;

    final updatedFavorites = state.favoriteLotIds
        .where((lotId) => lotId != id)
        .toList();
    final updatedGuards = [
      for (final guard in state.parkingGuards)
        ParkingGuardAccount(
          id: guard.id,
          name: guard.name,
          email: guard.email,
          phoneNumber: guard.phoneNumber,
          providerId: guard.providerId,
          assignedLotIds: guard.assignedLotIds
              .where((lotId) => lotId != id)
              .toList(),
          canScanQr: guard.canScanQr,
          canConfirmCash: guard.canConfirmCash,
          canManageSlots: guard.canManageSlots,
        ),
    ];
    final selectedLot = state.selectedLot?.id == id
        ? updatedLots.first
        : state.selectedLot;

    state = state.copyWith(
      lots: updatedLots,
      selectedLot: selectedLot,
      favoriteLotIds: updatedFavorites,
      parkingGuards: updatedGuards,
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

  void createBooking({required String slotCode, required DateTime entryTime}) {
    final lot = state.selectedLot ?? state.lots.first;
    final vehicle = state.selectedVehicle ?? state.vehicles.first;
    final total = calculateParkingCost(lot, vehicle);
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
        if (slot.label == slotCode) slot.copyWith(isAvailable: false) else slot,
    ];
    final remainingSlots = updatedSlots
        .where((slot) => slot.isAvailable)
        .length;
    final almostFullThreshold = math.max(1, (updatedSlots.length * 0.2).ceil());

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
          title: 'Booking baru',
          message:
              '${vehicle.plateNumber} booking slot $slotCode di ${lot.name}.',
          timeLabel: 'Baru saja',
          icon: Icons.book_online_rounded,
          accent: AppTheme.blue,
        ),
        if (remainingSlots <= almostFullThreshold)
          NoticeItem(
            title: 'Slot hampir penuh',
            message:
                'Sisa $remainingSlots dari ${updatedSlots.length} slot aktif setelah booking terbaru.',
            timeLabel: 'Baru saja',
            icon: Icons.warning_amber_rounded,
            accent: const Color(0xFFD97706),
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
          title: 'Pembayaran masuk',
          message:
              '${booking.plateNumber} membayar ${formatCurrency(booking.estimatedCost)} untuk tiket ${booking.ticketNumber}.',
          timeLabel: 'Baru saja',
          icon: Icons.account_balance_wallet_rounded,
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

  void replyToProviderFeedback({
    required String feedbackId,
    required String reply,
  }) {
    final cleanReply = reply.trim();
    if (cleanReply.isEmpty) return;

    state = state.copyWith(
      providerFeedback: [
        for (final item in state.providerFeedback)
          if (item.id == feedbackId)
            item.copyWith(providerReply: cleanReply, status: 'Dibalas')
          else
            item,
      ],
      adminNotifications: [
        const NoticeItem(
          title: 'Komplain dibalas',
          message: 'Balasan penyedia sudah tersimpan di pusat ulasan.',
          timeLabel: 'Baru saja',
          icon: Icons.forum_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.adminNotifications,
      ],
    );
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
        estimatedCost: calculateParkingCost(lot, updatedVehicle),
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
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme,
      ).apply(bodyColor: ink, displayColor: ink),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final safe = minutes < 0 ? 0 : minutes;
  final hours = safe ~/ 60;
  final remainMinutes = safe % 60;
  if (hours > 0) {
    return '${hours}j ${remainMinutes.toString().padLeft(2, '0')}m';
  }
  return '${remainMinutes}m';
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
      final controller = ref.read(appControllerProvider.notifier);
      if (!state.onboardingDone) {
        context.go('/onboarding');
      } else if (!state.isAuthenticated) {
        context.go('/login');
      } else {
        context.go(controller.landingRouteFor(state));
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
                    boxShadow: [
                      softShadow(AppTheme.blue.withValues(alpha: 0.2)),
                    ],
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
                  onPageChanged: ref
                      .read(appControllerProvider.notifier)
                      .setOnboardingPage,
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
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.slate, height: 1.5),
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

  void _submitLogin() {
    final controller = ref.read(appControllerProvider.notifier);
    controller.login(
      mode: _mode,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      rememberMe: _rememberMe,
    );
    context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
  }

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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masuk sebagai',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          RoleSelectionCards(
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
            onPressed: _submitLogin,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Masuk dengan Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: _submitLogin,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Login nomor HP',
            icon: Icons.sms_rounded,
            onPressed: _submitLogin,
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
  late final TextEditingController _parkingNameController;
  late final TextEditingController _parkingAddressController;
  late final TextEditingController _parkingPhotoController;
  late final TextEditingController _locationPointController;
  late final TextEditingController _identityController;
  AccountMode _mode = AccountMode.customer;
  double _providerCapacity = 80;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Dio Pratama');
    _emailController = TextEditingController(text: 'dio@parkircepat.app');
    _phoneController = TextEditingController(text: '+62 812 7788 9911');
    _parkingNameController = TextEditingController(
      text: 'Parkir Cepat Sudirman Hub',
    );
    _parkingAddressController = TextEditingController(
      text: 'Jl. Sudirman Smart Gate Kav. 18',
    );
    _parkingPhotoController = TextEditingController(
      text: 'lahan_parkir_sudirman.jpg',
    );
    _locationPointController = TextEditingController(
      text: 'Lat -6.2088, Lng 106.8456',
    );
    _identityController = TextEditingController(text: 'ktp_provider_dio.png');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _parkingNameController.dispose();
    _parkingAddressController.dispose();
    _parkingPhotoController.dispose();
    _locationPointController.dispose();
    _identityController.dispose();
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar sebagai',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          RoleSelectionCards(
            value: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          if (_mode == AccountMode.provider) ...[
            const SizedBox(height: 22),
            PremiumCard(
              accent: AppTheme.emeraldSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data verifikasi penyedia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akun penyedia akan masuk status pending verification sampai admin meninjau data lahan dan identitas.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.slate,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama tempat parkir',
                      prefixIcon: Icon(Icons.local_parking_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat lahan',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingPhotoController,
                    decoration: const InputDecoration(
                      labelText: 'Upload foto lahan',
                      prefixIcon: Icon(Icons.add_photo_alternate_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ParkingMapPlaceholder(
                    title: 'Pilih titik lokasi pada map',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationPointController,
                    decoration: const InputDecoration(
                      labelText: 'Titik lokasi',
                      prefixIcon: Icon(Icons.pin_drop_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LabeledSlider(
                    label: 'Kapasitas kendaraan',
                    value: _providerCapacity,
                    min: 20,
                    max: 300,
                    divisions: 28,
                    display: '${_providerCapacity.toInt()} slot',
                    onChanged: (value) =>
                        setState(() => _providerCapacity = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _identityController,
                    decoration: const InputDecoration(
                      labelText: 'Upload KTP / verifikasi identitas',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const InlineNotice(
                    icon: Icons.hourglass_top_rounded,
                    accent: Color(0xFFD97706),
                    message: 'Akun penyedia sedang menunggu verifikasi admin.',
                  ),
                ],
              ),
            ),
          ],
          if (_mode == AccountMode.parkingGuard) ...[
            const SizedBox(height: 18),
            const InlineNotice(
              icon: Icons.security_rounded,
              accent: Color(0xFFD97706),
              message:
                  'Akun penjaga dibuat oleh penyedia parkir dan hanya melihat lokasi yang ditugaskan.',
            ),
          ],
          if (_mode == AccountMode.superAdmin) ...[
            const SizedBox(height: 18),
            const InlineNotice(
              icon: Icons.admin_panel_settings_rounded,
              accent: AppTheme.ink,
              message:
                  'Super Admin memverifikasi pengguna, melihat laporan lintas lokasi, dan menangani komplain.',
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Daftar',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () {
              final providerApplication = _mode == AccountMode.provider
                  ? ProviderApplication(
                      parkingName: _parkingNameController.text,
                      address: _parkingAddressController.text,
                      photoLabel: _parkingPhotoController.text,
                      locationLabel: _locationPointController.text,
                      capacity: _providerCapacity.toInt(),
                      identityLabel: _identityController.text,
                    )
                  : null;
              ref
                  .read(appControllerProvider.notifier)
                  .register(
                    fullName: _nameController.text,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    mode: _mode,
                    providerApplication: providerApplication,
                  );
              if (_mode == AccountMode.provider) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Akun penyedia sedang menunggu verifikasi admin.',
                    ),
                  ),
                );
              }
              final controller = ref.read(appControllerProvider.notifier);
              context.go(
                controller.landingRouteFor(ref.read(appControllerProvider)),
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
      subtitle:
          'Verifikasi akun dengan email atau nomor HP lalu atur ulang password.',
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                          ref
                              .read(appControllerProvider.notifier)
                              .deleteAccount();
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

class ProviderVerificationScreen extends ConsumerWidget {
  const ProviderVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final application = state.providerApplication;
    final status = state.accountStatus;
    final statusColor = switch (status) {
      AccountStatus.pending => const Color(0xFFD97706),
      AccountStatus.verified => AppTheme.emerald,
      AccountStatus.rejected => const Color(0xFFDC2626),
    };
    final statusLabel = switch (status) {
      AccountStatus.pending => 'Pending Verification',
      AccountStatus.verified => 'Verified',
      AccountStatus.rejected => 'Rejected',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Status verifikasi provider')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(label: statusLabel, color: statusColor),
                const SizedBox(height: 16),
                Text(
                  'Akun penyedia ${state.userName}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  status == AccountStatus.pending
                      ? 'Akun penyedia sedang menunggu verifikasi admin.'
                      : status == AccountStatus.verified
                      ? 'Akun sudah diverifikasi dan siap mengelola dashboard admin.'
                      : 'Pengajuan provider perlu diperbarui sebelum diverifikasi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                    height: 1.5,
                  ),
                ),
                if (application != null) ...[
                  const SizedBox(height: 18),
                  SummaryRow(
                    label: 'Tempat parkir',
                    value: application.parkingName,
                  ),
                  SummaryRow(label: 'Alamat lahan', value: application.address),
                  SummaryRow(
                    label: 'Titik lokasi',
                    value: application.locationLabel,
                  ),
                  SummaryRow(
                    label: 'Kapasitas kendaraan',
                    value: '${application.capacity} slot',
                  ),
                  SummaryRow(
                    label: 'Foto lahan',
                    value: application.photoLabel,
                  ),
                  SummaryRow(
                    label: 'Verifikasi identitas',
                    value: application.identityLabel,
                  ),
                ],
                const SizedBox(height: 22),
                if (status == AccountStatus.pending)
                  SecondaryButton(
                    label: 'Masih menunggu verifikasi',
                    icon: Icons.hourglass_top_rounded,
                    onPressed: null,
                  ),
                if (status == AccountStatus.verified)
                  PrimaryButton(
                    label: 'Masuk ke dashboard admin',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/provider/dashboard'),
                  ),
                if (status == AccountStatus.rejected)
                  PrimaryButton(
                    label: 'Perbarui data pengajuan',
                    icon: Icons.edit_rounded,
                    onPressed: () => context.go('/register'),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Simulasi verified',
                        icon: Icons.verified_rounded,
                        onPressed: () {
                          ref
                              .read(appControllerProvider.notifier)
                              .setProviderStatus(AccountStatus.verified);
                          context.go('/provider/dashboard');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Simulasi rejected',
                        icon: Icons.close_rounded,
                        onPressed: () {
                          ref
                              .read(appControllerProvider.notifier)
                              .setProviderStatus(AccountStatus.rejected);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pendingProviders = state.providerApplication == null
        ? 0
        : state.accountStatus == AccountStatus.pending
        ? 1
        : 0;
    return SuperAdminShell(
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Super Admin',
            subtitle:
                'Pantau pengguna, verifikasi akun, laporan lintas lokasi, transaksi, dan komplain.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatCard(
                label: 'Pelanggan',
                value: '${state.vehicles.length + 124}',
                accent: AppTheme.blue,
                icon: Icons.groups_rounded,
              ),
              StatCard(
                label: 'Penyedia',
                value:
                    '${state.lots.map((lot) => lot.providerId).toSet().length}',
                accent: AppTheme.emerald,
                icon: Icons.apartment_rounded,
              ),
              StatCard(
                label: 'Penjaga',
                value: '${state.parkingGuards.length}',
                accent: const Color(0xFFD97706),
                icon: Icons.security_rounded,
              ),
              StatCard(
                label: 'Pending verifikasi',
                value: '$pendingProviders',
                accent: AppTheme.ink,
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Data penting ekosistem',
            action: 'Laporan',
            onTap: () => context.push('/super-admin/reports'),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            child: Column(
              children: [
                SummaryRow(
                  label: 'Total transaksi',
                  value: '${state.history.length}',
                ),
                SummaryRow(
                  label: 'Lokasi parkir aktif',
                  value: '${state.lots.length}',
                ),
                SummaryRow(
                  label: 'Kendaraan aktif',
                  value: state.activeBooking == null ? '0' : '1',
                ),
                SummaryRow(
                  label: 'Pendapatan tercatat',
                  value: formatCurrency(
                    state.history.fold(0, (total, item) => total + item.total),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Aksi cepat'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionCard(
                label: 'Kelola pengguna',
                icon: Icons.manage_accounts_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/super-admin/users'),
              ),
              ActionCard(
                label: 'Komplain',
                icon: Icons.support_agent_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/super-admin/complaints'),
              ),
              ActionCard(
                label: 'Nonaktifkan akun',
                icon: Icons.block_rounded,
                accent: AppTheme.blueSoft,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun bermasalah ditandai untuk review.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SuperAdminUsersScreen extends ConsumerWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return SuperAdminShell(
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Pengguna aplikasi',
            subtitle:
                'Verifikasi penyedia, pelanggan, penjaga, dan akun bermasalah.',
          ),
          const SizedBox(height: 18),
          MiniInfoTile(
            icon: Icons.apartment_rounded,
            iconColor: AppTheme.emerald,
            title: 'Penyedia Parkir',
            subtitle:
                '${state.lots.length} lokasi, status ${roleLabel(AccountMode.provider)} aktif',
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'Penjaga Parkir',
            subtitle:
                '${state.parkingGuards.length} akun terdaftar dari penyedia',
          ),
          const SizedBox(height: 12),
          const MiniInfoTile(
            icon: Icons.person_rounded,
            iconColor: AppTheme.blue,
            title: 'Pelanggan',
            subtitle:
                'Register, login, kendaraan, tiket, dan rating/review terpantau.',
          ),
        ],
      ),
    );
  }
}

class SuperAdminReportsScreen extends ConsumerWidget {
  const SuperAdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return SuperAdminShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Laporan semua lokasi',
            subtitle: 'Transaksi dan performa seluruh lokasi parkir.',
          ),
          const SizedBox(height: 18),
          PremiumCard(child: SizedBox(height: 220, child: RevenueChart())),
          const SizedBox(height: 18),
          ...state.history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MiniInfoTile(
                icon: Icons.receipt_long_rounded,
                iconColor: AppTheme.emerald,
                title: item.id,
                subtitle:
                    '${item.locationName} - ${formatCurrency(item.total)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuperAdminComplaintsScreen extends StatelessWidget {
  const SuperAdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SuperAdminShell(
      currentIndex: 3,
      child: NotificationsList(
        title: 'Komplain pengguna',
        subtitle:
            'Antrian komplain pelanggan, penyedia, dan penjaga untuk ditangani.',
        items: [
          NoticeItem(
            title: 'Pembayaran tunai belum dikonfirmasi',
            message:
                'Pelanggan meminta verifikasi manual dari lokasi Sudirman.',
            timeLabel: '8 menit lalu',
            icon: Icons.support_agent_rounded,
            accent: AppTheme.blue,
          ),
          NoticeItem(
            title: 'Penyedia butuh approval tarif',
            message: 'Perubahan aturan tarif menunggu keputusan super admin.',
            timeLabel: '32 menit lalu',
            icon: Icons.rule_rounded,
            accent: AppTheme.emerald,
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
            body:
                'Akses rekomendasi slot terbaik dengan status realtime dan navigasi instan.',
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
                detail:
                    '${nearestLot.distanceKm} km • ${nearestLot.etaMinutes} menit',
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                  child: SmartCityIllustration(
                    height: 130,
                    accent: AppTheme.emerald,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto entry lane',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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
            onSelect: (lot) =>
                ref.read(appControllerProvider.notifier).selectLot(lot),
          ),
          const SizedBox(height: 20),
          ...state.lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MiniInfoTile(
                icon: Icons.near_me_rounded,
                iconColor: lot.accent,
                title: '${lot.name} • ${lot.distanceKm} km',
                subtitle:
                    'ETA ${lot.etaMinutes} menit • ${lot.availableSlots}/${lot.totalSlots} slot',
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
                      colors: [
                        lot.accent.withValues(alpha: 0.9),
                        AppTheme.white,
                      ],
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          InfoChip(
                            icon: Icons.payments_rounded,
                            label: parkingLotTariffSummary(lot),
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
                    ref
                        .read(appControllerProvider.notifier)
                        .saveVehicle(
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
    final total = calculateParkingCost(lot, vehicle);
    final vehicleRate = tariffRateForVehicle(lot, vehicle.kind);
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  '${vehicle.plateNumber} • ${vehicle.label} • ${vehicle.durationHours} jam',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
                              style: Theme.of(context).textTheme.titleMedium
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
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
                    () => _entryTime = _entryTime.add(
                      const Duration(minutes: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  label: 'Estimasi biaya',
                  value: formatCurrency(total),
                ),
                const SizedBox(height: 8),
                SummaryRow(
                  label: 'Tarif ${vehicle.label.toLowerCase()}',
                  value:
                      '${formatCurrency(vehicleRate)} - ${tariffTypeLabel(lot.tariffType)}',
                ),
                const SizedBox(height: 8),
                SummaryRow(
                  label: 'Durasi',
                  value: '${vehicle.durationHours} jam',
                ),
                const SizedBox(height: 8),
                SummaryRow(
                  label: 'Ringkasan',
                  value: '${vehicle.label} • ${vehicle.plateNumber}',
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Konfirmasi booking',
                  icon: Icons.check_circle_rounded,
                  onPressed: _selectedSlot == null
                      ? null
                      : () {
                          ref
                              .read(appControllerProvider.notifier)
                              .createBooking(
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
    final reservationLeft = state.reservationLockedUntil?.difference(
      DateTime.now(),
    );
    return CustomerShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Tiket digital',
            subtitle:
                'Gunakan QR ini untuk masuk, bayar, dan verifikasi cepat.',
          ),
          const SizedBox(height: 18),
          if (booking == null)
            EmptyStateCard(
              title: 'Belum ada tiket aktif',
              body:
                  'Mulai booking dari dashboard atau peta untuk membuat karcis digital.',
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
                  SummaryRow(
                    label: 'Plat kendaraan',
                    value: booking.plateNumber,
                  ),
                  SummaryRow(
                    label: 'Jenis kendaraan',
                    value: booking.vehicleLabel,
                  ),
                  SummaryRow(
                    label: 'Lokasi parkir',
                    value: booking.locationName,
                  ),
                  SummaryRow(
                    label: 'Waktu masuk',
                    value: formatDateTime(booking.entryTime),
                  ),
                  if (reservationLeft != null)
                    SummaryRow(
                      label: 'Countdown reservasi',
                      value: formatDuration(reservationLeft),
                      valueColor: AppTheme.blue,
                    ),
                  SummaryRow(
                    label: 'Status pembayaran',
                    value: booking.isPaid ? 'Lunas' : 'Menunggu',
                    valueColor: booking.isPaid
                        ? AppTheme.emerald
                        : AppTheme.blue,
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
                    label: booking.isPaid
                        ? 'QR sudah aktif'
                        : 'Scan pembayaran',
                    icon: booking.isPaid
                        ? Icons.verified_rounded
                        : Icons.qr_code_scanner_rounded,
                    onPressed: booking.isPaid
                        ? null
                        : () => context.push('/customer/payment'),
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
                    ChoiceItem(
                      value: PaymentMethod.qris,
                      label: 'QRIS',
                      icon: Icons.qr_code_rounded,
                    ),
                    ChoiceItem(
                      value: PaymentMethod.ewallet,
                      label: 'E-wallet',
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                    ChoiceItem(
                      value: PaymentMethod.cash,
                      label: 'Tunai',
                      icon: Icons.payments_rounded,
                    ),
                    ChoiceItem(
                      value: PaymentMethod.card,
                      label: 'Debit/Kredit',
                      icon: Icons.credit_card_rounded,
                    ),
                  ],
                  value: _method,
                  onChanged: (value) => setState(() => _method = value),
                ),
                const SizedBox(height: 20),
                SummaryRow(
                  label: 'Ringkasan biaya',
                  value: booking.locationName,
                ),
                SummaryRow(label: 'Nomor tiket', value: booking.ticketNumber),
                SummaryRow(
                  label: 'Total pembayaran',
                  value: formatCurrency(booking.estimatedCost),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Bayar sekarang',
                  icon: Icons.lock_rounded,
                  onPressed: () {
                    ref
                        .read(appControllerProvider.notifier)
                        .payBooking(_method);
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
                      SummaryRow(
                        label: item.id,
                        value: item.status,
                        valueColor: AppTheme.emerald,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.locationName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.plateNumber} • ${item.timeLabel}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatCurrency(item.total),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
        subtitle:
            'Booking, pembayaran, verifikasi QR, dan status durasi parkir.',
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
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppTheme.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  state.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
    final isProvider =
        state.currentMode == AccountMode.provider ||
        GoRouterState.of(context).uri.path.startsWith('/provider');
    final occupiedSlots = state.slots.where((slot) => !slot.isAvailable).length;
    final feedback = providerFeedbackFor(state);
    final complaints = feedback.where((item) => item.isComplaint).length;
    return AdminShell(
      currentIndex: 0,
      floatingActionButton: isProvider
          ? null
          : FloatingActionButton.extended(
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
            title: 'Dashboard Penyedia',
            subtitle:
                'Kelola lahan, slot, tarif, penjaga, transaksi, dan pendapatan.',
            trailing: IconButton.filledTonal(
              onPressed: () => context.push('/provider/add-lot'),
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
                onTap: () => context.push('/provider/transaction-detail'),
              ),
              StatCard(
                label: 'Pendapatan hari ini',
                value: 'Rp 8,4 jt',
                accent: AppTheme.emerald,
                icon: Icons.trending_up_rounded,
                onTap: () => context.push('/provider/receipt'),
              ),
              StatCard(
                label: 'Slot tersedia',
                value:
                    '${state.slots.where((slot) => slot.isAvailable).length}',
                accent: AppTheme.slate,
                icon: Icons.local_parking_rounded,
                onTap: () => context.push('/provider/manage-slots'),
              ),
              StatCard(
                label: 'Slot aktif',
                value: '$occupiedSlots',
                accent: AppTheme.blue,
                icon: Icons.timelapse_rounded,
                onTap: () => context.push('/provider/manage-slots'),
              ),
              StatCard(
                label: 'Multi cabang',
                value: '${state.lots.length}',
                accent: AppTheme.emerald,
                icon: Icons.apartment_rounded,
                onTap: () => context.push('/provider/map'),
              ),
              if (isProvider)
                StatCard(
                  label: 'Kepuasan pelanggan',
                  value: '${satisfactionScore(feedback)}%',
                  accent: AppTheme.blue,
                  icon: Icons.favorite_rounded,
                  onTap: () => context.push('/provider/feedback'),
                ),
              if (isProvider)
                StatCard(
                  label: 'Komplain masuk',
                  value: '$complaints',
                  accent: AppTheme.emerald,
                  icon: Icons.forum_rounded,
                  onTap: () => context.push('/provider/feedback'),
                ),
            ],
          ),
          if (!isProvider) ...[
            const SizedBox(height: 20),
            SectionTitle(
              title: 'Monitoring kendaraan realtime',
              action: 'Lihat detail',
              onTap: () => context.push('/admin/monitoring'),
            ),
            const SizedBox(height: 12),
            PremiumCard(child: SizedBox(height: 220, child: RevenueChart())),
          ],
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Aksi cepat',
            action: 'Statistik',
            onTap: () => context.push('/provider/statistics'),
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
                onTap: () => context.push('/provider/add-lot'),
              ),
              ActionCard(
                label: 'Kelola slot parkir',
                icon: Icons.grid_view_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/provider/manage-slots'),
              ),
              ActionCard(
                label: 'Akun penjaga',
                icon: Icons.badge_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/provider/guards'),
              ),
              if (isProvider)
                ActionCard(
                  label: 'Komplain & rating',
                  icon: Icons.reviews_rounded,
                  accent: AppTheme.blueSoft,
                  onTap: () => context.push('/provider/feedback'),
                ),
              ActionCard(
                label: 'Detail transaksi',
                icon: Icons.receipt_long_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/provider/transaction-detail'),
              ),
              ActionCard(
                label: 'Laporan keuangan',
                icon: Icons.account_balance_wallet_rounded,
                accent: AppTheme.emeraldSoft,
                onTap: () => context.push('/provider/receipt'),
              ),
              ActionCard(
                label: 'Statistik pendapatan',
                icon: Icons.file_download_rounded,
                accent: AppTheme.blueSoft,
                onTap: () => context.push('/provider/statistics'),
              ),
            ],
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
    final lots = visibleLotsFor(state);
    final isProvider =
        state.currentMode == AccountMode.provider ||
        GoRouterState.of(context).uri.path.startsWith('/provider');
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
            lots: lots,
            selected: state.selectedLot,
            onSelect: (lot) =>
                ref.read(appControllerProvider.notifier).selectLot(lot),
          ),
          const SizedBox(height: 18),
          ...lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isProvider
                  ? ProviderLotManagementCard(
                      lot: lot,
                      canDelete: lots.length > 1,
                      onSelect: () => ref
                          .read(appControllerProvider.notifier)
                          .selectLot(lot),
                      onEdit: () {
                        ref.read(appControllerProvider.notifier).selectLot(lot);
                        context.push('/provider/add-lot', extra: lot);
                      },
                      onDelete: () => _confirmDeleteLot(context, ref, lot),
                    )
                  : MiniInfoTile(
                      icon: Icons.domain_add_rounded,
                      iconColor: lot.accent,
                      title: lot.name,
                      subtitle:
                          '${lot.availableSlots}/${lot.totalSlots} slot tersedia - ${lot.address}',
                      onTap: () => ref
                          .read(appControllerProvider.notifier)
                          .selectLot(lot),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteLot(
    BuildContext context,
    WidgetRef ref,
    ParkingLot lot,
  ) async {
    final state = ref.read(appControllerProvider);
    if (visibleLotsFor(state).length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada satu lahan parkir.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus lahan parkir?'),
        content: Text('${lot.name} akan dihapus dari data penyedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    ref.read(appControllerProvider.notifier).deleteLot(lot.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${lot.name} berhasil dihapus.')));
  }
}

class ProviderLotManagementCard extends StatelessWidget {
  const ProviderLotManagementCard({
    super.key,
    required this.lot,
    required this.canDelete,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final ParkingLot lot;
  final bool canDelete;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: lot.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.domain_add_rounded, color: lot.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.availableSlots}/${lot.totalSlots} slot tersedia - ${lot.address}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                icon: Icons.price_change_rounded,
                label: tariffTypeLabel(lot.tariffType),
              ),
              InfoChip(
                icon: Icons.two_wheeler_rounded,
                label: formatCurrency(lot.motorRate ?? lot.pricePerHour),
              ),
              InfoChip(
                icon: Icons.directions_car_rounded,
                label: formatCurrency(lot.carRate ?? lot.pricePerHour),
              ),
              InfoChip(
                icon: Icons.local_shipping_rounded,
                label: formatCurrency(lot.truckRate ?? lot.pricePerHour),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Pilih',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: onSelect,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit lahan',
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: canDelete ? onDelete : null,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Hapus lahan',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddParkingLotScreen extends ConsumerStatefulWidget {
  const AddParkingLotScreen({super.key, this.lot});

  final ParkingLot? lot;

  @override
  ConsumerState<AddParkingLotScreen> createState() =>
      _AddParkingLotScreenState();
}

class _AddParkingLotScreenState extends ConsumerState<AddParkingLotScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  double _capacity = 60;
  double _price = 12000;
  double _motorRate = 5000;
  double _carRate = 12000;
  double _truckRate = 20000;
  ParkingTariffType _tariffType = ParkingTariffType.hourly;
  bool _locationSelected = false;
  bool _isPickingPhoto = false;
  String? _photoName;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    final lot = widget.lot;
    _nameController = TextEditingController(
      text: lot?.name ?? 'Neo Smart Parking Hub',
    );
    _addressController = TextEditingController(
      text: lot?.address ?? 'Jl. Gatot Subroto Smart Gate 8',
    );
    if (lot != null) {
      _capacity = lot.totalSlots.toDouble();
      _price = lot.pricePerHour.toDouble();
      _motorRate = (lot.motorRate ?? lot.pricePerHour).toDouble();
      _carRate = (lot.carRate ?? lot.pricePerHour).toDouble();
      _truckRate = (lot.truckRate ?? lot.pricePerHour).toDouble();
      _tariffType = lot.tariffType;
      _locationSelected = lot.latitude != null && lot.longitude != null;
      _photoName = lot.photoLabel;
      _photoBytes = lot.photoBytes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLotPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final photo = await pickParkingLotPhoto();
      if (!mounted) return;
      if (photo == null) {
        setState(() => _isPickingPhoto = false);
        return;
      }

      setState(() {
        _photoName = photo.name;
        _photoBytes = photo.bytes;
        _isPickingPhoto = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPickingPhoto = false);
      final message = error is FormatException
          ? error.message
          : 'Foto lahan gagal dipilih.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _clearLotPhoto() {
    setState(() {
      _photoName = null;
      _photoBytes = null;
    });
  }

  String? _lotFormError() {
    if (_nameController.text.trim().isEmpty) {
      return 'Nama lokasi parkir wajib diisi.';
    }
    if (_addressController.text.trim().isEmpty) {
      return 'Alamat lahan parkir wajib diisi.';
    }
    if (_capacity.toInt() <= 0) {
      return 'Kapasitas kendaraan harus lebih dari 0.';
    }
    if (_motorRate.toInt() <= 0 ||
        _carRate.toInt() <= 0 ||
        _truckRate.toInt() <= 0) {
      return 'Tarif motor, mobil, dan truk harus lebih dari 0.';
    }
    if (_photoBytes == null) {
      return 'Foto lahan parkir wajib diupload.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editingLot = widget.lot;
    final isEditing = editingLot != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit lahan parkir' : 'Tambah lahan parkir'),
      ),
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
                ProviderMapEmbedView(
                  embedUrl: plazaSudirmanMapEmbedUrl,
                  locationName: plazaSudirmanLocationName,
                  latitude: plazaSudirmanLatitude,
                  longitude: plazaSudirmanLongitude,
                  isSelected: _locationSelected,
                  onSelected: () => setState(() => _locationSelected = true),
                ),
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
                const SizedBox(height: 18),
                ParkingTariffSettings(
                  tariffType: _tariffType,
                  motorRate: _motorRate,
                  carRate: _carRate,
                  truckRate: _truckRate,
                  onTariffTypeChanged: (value) =>
                      setState(() => _tariffType = value),
                  onMotorRateChanged: (value) =>
                      setState(() => _motorRate = value),
                  onCarRateChanged: (value) {
                    setState(() {
                      _carRate = value;
                      _price = value;
                    });
                  },
                  onTruckRateChanged: (value) =>
                      setState(() => _truckRate = value),
                ),
                const SizedBox(height: 18),
                ParkingLotPhotoPicker(
                  photoName: _photoName,
                  photoBytes: _photoBytes,
                  isPicking: _isPickingPhoto,
                  onPick: _pickLotPhoto,
                  onClear: _clearLotPhoto,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: isEditing ? 'Update lahan' : 'Simpan lahan',
                  icon: Icons.save_rounded,
                  onPressed: () {
                    final error = _lotFormError();
                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                    final controller = ref.read(appControllerProvider.notifier);
                    if (isEditing) {
                      controller.updateLot(
                        id: editingLot.id,
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        capacity: _capacity.toInt(),
                        price: _price.toInt(),
                        mapEmbedUrl: plazaSudirmanMapEmbedUrl,
                        latitude: plazaSudirmanLatitude,
                        longitude: plazaSudirmanLongitude,
                        tariffType: _tariffType,
                        motorRate: _motorRate.toInt(),
                        carRate: _carRate.toInt(),
                        truckRate: _truckRate.toInt(),
                        photoLabel: _photoName,
                        photoBytes: _photoBytes,
                      );
                    } else {
                      controller.addLot(
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        capacity: _capacity.toInt(),
                        price: _price.toInt(),
                        mapEmbedUrl: plazaSudirmanMapEmbedUrl,
                        latitude: plazaSudirmanLatitude,
                        longitude: plazaSudirmanLongitude,
                        tariffType: _tariffType,
                        motorRate: _motorRate.toInt(),
                        carRate: _carRate.toInt(),
                        truckRate: _truckRate.toInt(),
                        photoLabel: _photoName,
                        photoBytes: _photoBytes,
                      );
                    }
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

class ParkingTariffSettings extends StatelessWidget {
  const ParkingTariffSettings({
    super.key,
    required this.tariffType,
    required this.motorRate,
    required this.carRate,
    required this.truckRate,
    required this.onTariffTypeChanged,
    required this.onMotorRateChanged,
    required this.onCarRateChanged,
    required this.onTruckRateChanged,
  });

  final ParkingTariffType tariffType;
  final double motorRate;
  final double carRate;
  final double truckRate;
  final ValueChanged<ParkingTariffType> onTariffTypeChanged;
  final ValueChanged<double> onMotorRateChanged;
  final ValueChanged<double> onCarRateChanged;
  final ValueChanged<double> onTruckRateChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.price_change_rounded,
                  color: AppTheme.emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan tarif parkir',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tariffTypeLabel(tariffType)} untuk motor, mobil, dan truk.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedChoice<ParkingTariffType>(
            items: const [
              ChoiceItem(
                value: ParkingTariffType.hourly,
                label: 'Per jam',
                icon: Icons.schedule_rounded,
              ),
              ChoiceItem(
                value: ParkingTariffType.flat,
                label: 'Flat',
                icon: Icons.payments_rounded,
              ),
              ChoiceItem(
                value: ParkingTariffType.daily,
                label: 'Harian',
                icon: Icons.today_rounded,
              ),
              ChoiceItem(
                value: ParkingTariffType.progressive,
                label: 'Progresif',
                icon: Icons.trending_up_rounded,
              ),
            ],
            value: tariffType,
            onChanged: onTariffTypeChanged,
          ),
          const SizedBox(height: 14),
          LabeledSlider(
            label: 'Tarif motor',
            value: motorRate,
            min: 2000,
            max: 20000,
            divisions: 18,
            display: formatCurrency(motorRate.toInt()),
            onChanged: onMotorRateChanged,
          ),
          const SizedBox(height: 10),
          LabeledSlider(
            label: 'Tarif mobil',
            value: carRate,
            min: 5000,
            max: 50000,
            divisions: 45,
            display: formatCurrency(carRate.toInt()),
            onChanged: onCarRateChanged,
          ),
          const SizedBox(height: 10),
          LabeledSlider(
            label: 'Tarif truk',
            value: truckRate,
            min: 10000,
            max: 80000,
            divisions: 70,
            display: formatCurrency(truckRate.toInt()),
            onChanged: onTruckRateChanged,
          ),
        ],
      ),
    );
  }
}

class ParkingLotPhotoPicker extends StatelessWidget {
  const ParkingLotPhotoPicker({
    super.key,
    required this.photoName,
    required this.photoBytes,
    required this.isPicking,
    required this.onPick,
    required this.onClear,
  });

  final String? photoName;
  final Uint8List? photoBytes;
  final bool isPicking;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppTheme.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload foto lahan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPhoto
                          ? photoName ?? 'Foto lahan dipilih'
                          : 'Pilih foto area parkir dari galeri.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.white,
              child: hasPhoto
                  ? Image.memory(photoBytes!, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 42,
                        color: AppTheme.slate,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPicking ? null : onPick,
                  icon: isPicking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          hasPhoto
                              ? Icons.photo_library_rounded
                              : Icons.upload_file_rounded,
                        ),
                  label: Text(
                    isPicking
                        ? 'Memilih...'
                        : hasPhoto
                        ? 'Ganti foto'
                        : 'Pilih foto',
                  ),
                ),
              ),
              if (hasPhoto) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Hapus foto',
                ),
              ],
            ],
          ),
        ],
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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final Set<String> _selectedLotIds = {};
  bool _canConfirmCash = true;
  bool _canManageSlots = true;
  String? _editingGuardId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sinta Penjaga');
    _emailController = TextEditingController(
      text: 'sinta.guard@parkircepat.app',
    );
    _phoneController = TextEditingController(text: '+62 812 4455 6677');
    final lots = visibleLotsFor(ref.read(appControllerProvider));
    if (lots.isNotEmpty) {
      _selectedLotIds.add(lots.first.id);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _guardFormError(List<ParkingLot> lots) {
    if (_nameController.text.trim().isEmpty) {
      return 'Nama penjaga wajib diisi.';
    }
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      return 'Email login penjaga harus valid.';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Nomor HP penjaga wajib diisi.';
    }
    if (lots.isEmpty) {
      return 'Tambahkan lahan parkir terlebih dahulu.';
    }
    if (_selectedLotIds.isEmpty) {
      return 'Pilih minimal satu lokasi untuk penjaga.';
    }
    return null;
  }

  void _resetGuardForm(List<ParkingLot> lots) {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _editingGuardId = null;
      _selectedLotIds
        ..clear()
        ..addAll(lots.isEmpty ? const [] : [lots.first.id]);
      _canConfirmCash = true;
      _canManageSlots = true;
    });
  }

  String _assignedLotNames(ParkingGuardAccount guard, List<ParkingLot> lots) {
    final names = [
      for (final lot in lots)
        if (guard.assignedLotIds.contains(lot.id)) lot.name,
    ];
    if (names.isEmpty) return 'Belum ada lokasi aktif';
    return names.join(', ');
  }

  void _startEditGuard(ParkingGuardAccount guard) {
    _nameController.text = guard.name;
    _emailController.text = guard.email;
    _phoneController.text = guard.phoneNumber;
    setState(() {
      _editingGuardId = guard.id;
      _selectedLotIds
        ..clear()
        ..addAll(guard.assignedLotIds);
      _canConfirmCash = guard.canConfirmCash;
      _canManageSlots = guard.canManageSlots;
    });
  }

  void _saveGuard(List<ParkingLot> lots) {
    final error = _guardFormError(lots);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final controller = ref.read(appControllerProvider.notifier);
    final editingGuardId = _editingGuardId;
    if (editingGuardId == null) {
      controller.createParkingGuard(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        assignedLotIds: _selectedLotIds.toList(),
        canScanQr: false,
        canConfirmCash: _canConfirmCash,
        canManageSlots: _canManageSlots,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun penjaga berhasil dibuat.')),
      );
    } else {
      controller.updateParkingGuard(
        id: editingGuardId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        assignedLotIds: _selectedLotIds.toList(),
        canConfirmCash: _canConfirmCash,
        canManageSlots: _canManageSlots,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun penjaga berhasil diperbarui.')),
      );
    }
    _resetGuardForm(lots);
  }

  Future<void> _confirmDeleteGuard(ParkingGuardAccount guard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun penjaga?'),
        content: Text(
          '${guard.name} akan dihapus dari daftar akun penjaga penyedia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    ref.read(appControllerProvider.notifier).deleteParkingGuard(guard.id);
    if (_editingGuardId == guard.id) {
      _resetGuardForm(visibleLotsFor(ref.read(appControllerProvider)));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Akun ${guard.name} berhasil dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final lots = visibleLotsFor(state);
    return Scaffold(
      appBar: AppBar(title: const Text('Akun penjaga parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _editingGuardId == null
                        ? 'Tambah akun penjaga'
                        : 'Edit akun penjaga',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama penjaga',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email login penjaga',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lokasi yang boleh diakses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (lots.isEmpty)
                  const InlineNotice(
                    icon: Icons.info_outline_rounded,
                    accent: Color(0xFFD97706),
                    message:
                        'Belum ada lahan aktif. Tambahkan lahan parkir sebelum membuat akun penjaga.',
                  )
                else
                  for (final lot in lots)
                    CheckboxListTile(
                      value: _selectedLotIds.contains(lot.id),
                      title: Text(lot.name),
                      subtitle: Text(lot.address),
                      activeColor: AppTheme.emerald,
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedLotIds.add(lot.id);
                          } else {
                            _selectedLotIds.remove(lot.id);
                          }
                        });
                      },
                    ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _canConfirmCash,
                  title: const Text('Konfirmasi pembayaran tunai'),
                  onChanged: (value) => setState(() => _canConfirmCash = value),
                ),
                SwitchListTile(
                  value: _canManageSlots,
                  title: const Text('Update status slot parkir'),
                  onChanged: (value) => setState(() => _canManageSlots = value),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _editingGuardId == null
                      ? 'Buat akun penjaga'
                      : 'Simpan perubahan',
                  icon: _editingGuardId == null
                      ? Icons.person_add_alt_1_rounded
                      : Icons.save_rounded,
                  onPressed: () => _saveGuard(lots),
                ),
                if (_editingGuardId != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _resetGuardForm(lots),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Batal edit'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Penjaga aktif'),
          const SizedBox(height: 12),
          if (state.parkingGuards.isEmpty)
            const EmptyStateCard(
              title: 'Belum ada penjaga',
              body:
                  'Akun penjaga yang dibuat penyedia akan tampil di daftar ini.',
              actionLabel: 'Isi data penjaga',
              onPressed: _noop,
            )
          else
            ...state.parkingGuards.map(
              (guard) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ParkingGuardAccountCard(
                  guard: guard,
                  assignedLots: _assignedLotNames(guard, state.lots),
                  onEdit: () => _startEditGuard(guard),
                  onDelete: () => _confirmDeleteGuard(guard),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _noop() {}

class ParkingGuardAccountCard extends StatelessWidget {
  const ParkingGuardAccountCard({
    super.key,
    required this.guard,
    required this.assignedLots,
    required this.onEdit,
    required this.onDelete,
  });

  final ParkingGuardAccount guard;
  final String assignedLots;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guard.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${guard.email} - ${guard.phoneNumber}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InlineNotice(
            icon: Icons.location_on_rounded,
            accent: AppTheme.emerald,
            message: 'Lokasi ditugaskan: $assignedLots',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                icon: Icons.payments_rounded,
                label: guard.canConfirmCash ? 'Tunai aktif' : 'Tunai nonaktif',
              ),
              InfoChip(
                icon: Icons.grid_view_rounded,
                label: guard.canManageSlots
                    ? 'Kelola slot aktif'
                    : 'Kelola slot nonaktif',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
              ),
            ],
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
            subtitle:
                'Daftar kendaraan masuk, keluar, pembayaran, dan filter realtime.',
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
                    SummaryRow(
                      label: item.plateNumber,
                      value: item.status,
                      valueColor: AppTheme.emerald,
                    ),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
                              content: Text(
                                'Tiket valid dan pembayaran terkonfirmasi',
                              ),
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
                          ref
                              .read(appControllerProvider.notifier)
                              .markVehicleExit();
                          final mode = ref
                              .read(appControllerProvider)
                              .currentMode;
                          context.go(
                            mode == AccountMode.parkingGuard
                                ? '/guard/dashboard'
                                : '/provider/dashboard',
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
                SummaryRow(
                  label: 'Total biaya',
                  value: formatCurrency(transaction.total),
                ),
                SummaryRow(
                  label: 'Status',
                  value: transaction.status,
                  valueColor: AppTheme.emerald,
                ),
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
    final state = ref.watch(appControllerProvider);
    if (state.currentMode == AccountMode.provider) {
      return const ProviderFinancialReportScreen();
    }

    final transaction = state.history.first;
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
                SummaryRow(
                  label: 'Total',
                  value: formatCurrency(transaction.total),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Cetak nota',
                  icon: Icons.print_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preview nota siap dicetak'),
                      ),
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

class ProviderFinancialReportScreen extends ConsumerWidget {
  const ProviderFinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(appControllerProvider).history;
    final revenue = history.fold<int>(0, (total, item) => total + item.total);
    final estimatedExpense = (revenue * 0.3).round();
    final netIncome = revenue - estimatedExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan keuangan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan pendapatan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                SummaryRow(
                  label: 'Total pendapatan',
                  value: formatCurrency(revenue),
                  valueColor: AppTheme.emerald,
                ),
                SummaryRow(
                  label: 'Estimasi pengeluaran',
                  value: formatCurrency(estimatedExpense),
                  valueColor: const Color(0xFFDC2626),
                ),
                SummaryRow(
                  label: 'Laba bersih estimasi',
                  value: formatCurrency(netIncome),
                  valueColor: AppTheme.blue,
                ),
                SummaryRow(
                  label: 'Jumlah transaksi',
                  value: '${history.length} transaksi',
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Download laporan PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan PDF siap diunduh')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionTitle(title: 'Transaksi terbaru'),
          const SizedBox(height: 12),
          ...history
              .take(5)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.locationName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        SummaryRow(label: 'Transaksi', value: item.id),
                        SummaryRow(label: 'Kendaraan', value: item.plateNumber),
                        SummaryRow(
                          label: 'Pendapatan',
                          value: formatCurrency(item.total),
                          valueColor: AppTheme.emerald,
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

class ProviderFeedbackScreen extends ConsumerWidget {
  const ProviderFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final feedback = providerFeedbackFor(state);
    final complaints = feedback.where((item) => item.isComplaint).toList();
    final reviews = feedback.where((item) => !item.isComplaint).toList();
    final repliedComplaints = complaints
        .where((item) => item.providerReply != null)
        .length;
    final averageRating = averageFeedbackRating(feedback);
    final satisfaction = satisfactionScore(feedback);

    return AdminShell(
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Komplain dan rating',
            subtitle:
                'Pantau kepuasan pelanggan, baca review lokasi, dan balas komplain.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatCard(
                label: 'Rating rata-rata',
                value: averageRating.toStringAsFixed(1),
                accent: AppTheme.emerald,
                icon: Icons.star_rounded,
              ),
              StatCard(
                label: 'Kepuasan pelanggan',
                value: '$satisfaction%',
                accent: AppTheme.blue,
                icon: Icons.favorite_rounded,
              ),
              StatCard(
                label: 'Total review',
                value: '${feedback.length}',
                accent: AppTheme.slate,
                icon: Icons.rate_review_rounded,
              ),
              StatCard(
                label: 'Komplain dibalas',
                value: '$repliedComplaints/${complaints.length}',
                accent: AppTheme.emerald,
                icon: Icons.forum_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik kepuasan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: satisfaction / 100,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: AppTheme.slateSoft,
                  color: AppTheme.emerald,
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  label: 'Pelanggan puas',
                  value: '${feedback.where((item) => item.rating >= 4).length}',
                  valueColor: AppTheme.emerald,
                ),
                SummaryRow(
                  label: 'Perlu ditindaklanjuti',
                  value: '${feedback.where((item) => item.rating < 4).length}',
                  valueColor: AppTheme.blue,
                ),
                SummaryRow(
                  label: 'Komplain belum dibalas',
                  value:
                      '${complaints.where((item) => item.providerReply == null).length}',
                  valueColor: AppTheme.slate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Review pelanggan'),
          const SizedBox(height: 12),
          ...reviews.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProviderFeedbackCard(item: item),
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle(title: 'Komplain pelanggan'),
          const SizedBox(height: 12),
          ...complaints.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProviderFeedbackCard(
                item: item,
                onReply: () => _showProviderReplyDialog(context, ref, item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProviderReplyDialog(
    BuildContext context,
    WidgetRef ref,
    ProviderFeedback item,
  ) async {
    final controller = TextEditingController(text: item.providerReply ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Balas komplain'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Tulis balasan untuk pelanggan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              ref
                  .read(appControllerProvider.notifier)
                  .replyToProviderFeedback(
                    feedbackId: item.id,
                    reply: controller.text,
                  );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Balasan komplain tersimpan')),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Kirim'),
          ),
        ],
      ),
    );
    controller.dispose();
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
          PremiumCard(child: SizedBox(height: 220, child: RevenueChart())),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Export PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan PDF berhasil disiapkan'),
                      ),
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
                      const SnackBar(
                        content: Text('Laporan Excel berhasil disiapkan'),
                      ),
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
                  value:
                      '${state.slots.where((slot) => slot.isAvailable).length}',
                ),
                SummaryRow(
                  label: 'Slot penuh',
                  value:
                      '${state.slots.where((slot) => !slot.isAvailable).length}',
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
                const SnackBar(
                  content: Text('Slot baru ditambahkan ke prototipe'),
                ),
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slot.isAvailable ? 'Tersedia' : 'Penuh',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                      onChanged: (_) => ref
                          .read(appControllerProvider.notifier)
                          .toggleSlot(slot.id),
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
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 40,
                    color: AppTheme.emerald,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin ${state.userName}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                  'Kelola ${state.lots.length} lahan parkir',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
            onTap: () => context.push('/provider/add-lot'),
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

class ParkingGuardDashboardScreen extends ConsumerWidget {
  const ParkingGuardDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final guard = activeGuard(state);
    final lots = visibleLotsFor(state);
    final availableSlots = state.slots.where((slot) => slot.isAvailable).length;
    return GuardShell(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.emerald,
        foregroundColor: Colors.white,
        onPressed: guard?.canScanQr ?? false
            ? () => context.push('/guard/scan-qr')
            : null,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan QR'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          HeaderSection(
            title: 'Dashboard Penjaga',
            subtitle:
                '${guard?.name ?? 'Penjaga'} hanya dapat mengakses ${lots.length} lokasi dari penyedia.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatCard(
                label: 'Lokasi assigned',
                value: '${lots.length}',
                accent: AppTheme.emerald,
                icon: Icons.apartment_rounded,
              ),
              StatCard(
                label: 'Slot tersedia',
                value: '$availableSlots',
                accent: AppTheme.blue,
                icon: Icons.local_parking_rounded,
              ),
              StatCard(
                label: 'Slot penuh',
                value: '${state.slots.length - availableSlots}',
                accent: const Color(0xFFD97706),
                icon: Icons.block_rounded,
              ),
              StatCard(
                label: 'Pembayaran',
                value: state.activeBooking?.isPaid ?? false ? 'Lunas' : 'Cek',
                accent: AppTheme.ink,
                icon: Icons.payments_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(title: 'Lokasi kerja'),
          const SizedBox(height: 12),
          ...lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MiniInfoTile(
                icon: Icons.local_parking_rounded,
                iconColor: lot.accent,
                title: lot.name,
                subtitle:
                    '${lot.availableSlots}/${lot.totalSlots} slot tersedia',
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Lihat kendaraan aktif',
            icon: Icons.directions_car_rounded,
            onPressed: () => context.push('/guard/vehicles'),
          ),
        ],
      ),
    );
  }
}

class GuardVehiclesScreen extends ConsumerWidget {
  const GuardVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final booking = state.activeBooking;
    return GuardShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Kendaraan aktif',
            subtitle:
                'Verifikasi masuk, keluar, dan status pembayaran pelanggan.',
          ),
          const SizedBox(height: 18),
          if (booking == null)
            EmptyStateCard(
              title: 'Belum ada kendaraan aktif',
              body: 'Kendaraan akan tampil setelah pelanggan booking tiket.',
              actionLabel: 'Scan QR tiket',
              onPressed: () => context.push('/guard/scan-qr'),
            )
          else
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryRow(label: 'Tiket', value: booking.ticketNumber),
                  SummaryRow(label: 'Plat nomor', value: booking.plateNumber),
                  SummaryRow(label: 'Lokasi', value: booking.locationName),
                  SummaryRow(label: 'Slot', value: booking.slotCode),
                  SummaryRow(
                    label: 'Pembayaran',
                    value: booking.isPaid ? 'Lunas' : 'Belum lunas',
                    valueColor: booking.isPaid
                        ? AppTheme.emerald
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 18),
                  SecondaryButton(
                    label: 'Konfirmasi pembayaran tunai',
                    icon: Icons.payments_rounded,
                    onPressed: booking.isPaid
                        ? null
                        : () {
                            ref
                                .read(appControllerProvider.notifier)
                                .payBooking(PaymentMethod.cash);
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

class GuardProfileScreen extends ConsumerWidget {
  const GuardProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final guard = activeGuard(state);
    return GuardShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          PremiumCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.emeraldSoft,
                  child: Icon(
                    Icons.security_rounded,
                    size: 40,
                    color: AppTheme.emerald,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  guard?.name ?? state.userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Akses lokasi: ${visibleLotsFor(state).length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                ),
              ],
            ),
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
        ShellDestination(
          label: 'Home',
          icon: Icons.home_rounded,
          route: '/customer/home',
        ),
        ShellDestination(
          label: 'Map',
          icon: Icons.map_rounded,
          route: '/customer/map',
        ),
        ShellDestination(
          label: 'Tiket',
          icon: Icons.confirmation_num_rounded,
          route: '/customer/tickets',
        ),
        ShellDestination(
          label: 'Notifikasi',
          icon: Icons.notifications_rounded,
          route: '/customer/notifications',
        ),
        ShellDestination(
          label: 'Profil',
          icon: Icons.person_rounded,
          route: '/customer/profile',
        ),
      ],
      child: child,
    );
  }
}

class AdminShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isProvider =
        ref.watch(appControllerProvider).currentMode == AccountMode.provider ||
        GoRouterState.of(context).uri.path.startsWith('/provider');
    final destinations = isProvider
        ? const [
            ShellDestination(
              label: 'Home',
              icon: Icons.space_dashboard_rounded,
              route: '/provider/dashboard',
            ),
            ShellDestination(
              label: 'Map',
              icon: Icons.map_rounded,
              route: '/provider/map',
            ),
            ShellDestination(
              label: 'Notif',
              icon: Icons.notifications_rounded,
              route: '/provider/notifications',
            ),
            ShellDestination(
              label: 'Profil',
              icon: Icons.person_rounded,
              route: '/provider/profile',
            ),
          ]
        : const [
            ShellDestination(
              label: 'Home',
              icon: Icons.space_dashboard_rounded,
              route: '/provider/dashboard',
            ),
            ShellDestination(
              label: 'Map',
              icon: Icons.map_rounded,
              route: '/provider/map',
            ),
            ShellDestination(
              label: 'Monitor',
              icon: Icons.radar_rounded,
              route: '/admin/monitoring',
            ),
            ShellDestination(
              label: 'Notif',
              icon: Icons.notifications_rounded,
              route: '/provider/notifications',
            ),
            ShellDestination(
              label: 'Profil',
              icon: Icons.person_rounded,
              route: '/provider/profile',
            ),
          ];
    final resolvedIndex = isProvider && currentIndex > 2
        ? currentIndex - 1
        : currentIndex;

    return AppShell(
      currentIndex: resolvedIndex,
      floatingActionButton: floatingActionButton,
      destinations: destinations,
      child: child,
    );
  }
}

class SuperAdminShell extends StatelessWidget {
  const SuperAdminShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,
      destinations: const [
        ShellDestination(
          label: 'Home',
          icon: Icons.admin_panel_settings_rounded,
          route: '/super-admin/dashboard',
        ),
        ShellDestination(
          label: 'User',
          icon: Icons.manage_accounts_rounded,
          route: '/super-admin/users',
        ),
        ShellDestination(
          label: 'Laporan',
          icon: Icons.insights_rounded,
          route: '/super-admin/reports',
        ),
        ShellDestination(
          label: 'Komplain',
          icon: Icons.support_agent_rounded,
          route: '/super-admin/complaints',
        ),
      ],
      child: child,
    );
  }
}

class GuardShell extends StatelessWidget {
  const GuardShell({
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
        ShellDestination(
          label: 'Home',
          icon: Icons.space_dashboard_rounded,
          route: '/guard/dashboard',
        ),
        ShellDestination(
          label: 'Scan',
          icon: Icons.qr_code_scanner_rounded,
          route: '/guard/scan-qr',
        ),
        ShellDestination(
          label: 'Kendaraan',
          icon: Icons.directions_car_rounded,
          route: '/guard/vehicles',
        ),
        ShellDestination(
          label: 'Profil',
          icon: Icons.person_rounded,
          route: '/guard/profile',
        ),
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
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: selected
                                    ? AppTheme.blue
                                    : AppTheme.slate,
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
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
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
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
  const SectionTitle({super.key, required this.title, this.action, this.onTap});

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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class RoleSelectionCards extends StatelessWidget {
  const RoleSelectionCards({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AccountMode value;
  final ValueChanged<AccountMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const roles = [
      (
        mode: AccountMode.customer,
        title: 'Pelanggan',
        subtitle: 'Cari lokasi, booking, bayar, tiket QR, dan review.',
        accent: AppTheme.blue,
      ),
      (
        mode: AccountMode.provider,
        title: 'Penyedia Parkir',
        subtitle: 'Kelola lahan, slot, tarif, penjaga, dan pendapatan.',
        accent: AppTheme.emerald,
      ),
      (
        mode: AccountMode.parkingGuard,
        title: 'Penjaga Parkir',
        subtitle: 'Scan QR, verifikasi masuk/keluar, slot, dan tunai.',
        accent: Color(0xFFD97706),
      ),
      (
        mode: AccountMode.superAdmin,
        title: 'Super Admin',
        subtitle: 'Verifikasi akun, pantau pengguna, laporan, komplain.',
        accent: AppTheme.ink,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth > 620
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final role in roles)
              SizedBox(
                width: itemWidth,
                child: RoleSelectionCard(
                  title: role.title,
                  subtitle: role.subtitle,
                  icon: roleIcon(role.mode),
                  selected: value == role.mode,
                  accent: role.accent,
                  onTap: () => onChanged(role.mode),
                ),
              ),
          ],
        );
      },
    );
  }
}

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? accent : AppTheme.slate.withValues(alpha: 0.18),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
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
    );
  }
}

class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.icon,
    required this.accent,
    required this.message,
  });

  final IconData icon;
  final Color accent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class AiRecommendationCard extends StatelessWidget {
  const AiRecommendationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 52) / 2;
    return Container(
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
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.slate,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
          ),
        ],
      ),
    );
  }
}

class ParkingLotCard extends StatelessWidget {
  const ParkingLotCard({
    super.key,
    required this.lot,
    required this.onDetail,
    required this.onBooking,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final ParkingLot lot;
  final VoidCallback onDetail;
  final VoidCallback onBooking;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = lot.photoBytes != null;
    final hasCoordinates = lot.latitude != null && lot.longitude != null;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                lot.photoBytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFFDC2626) : AppTheme.slate,
                ),
              ),
              StatusBadge(
                label: lot.isFull ? 'Penuh' : 'Tersedia',
                color: lot.isFull ? AppTheme.slate : AppTheme.emerald,
              ),
            ],
          ),
          if (hasCoordinates) ...[
            const SizedBox(height: 12),
            InlineNotice(
              icon: Icons.map_rounded,
              accent: lot.accent,
              message:
                  'Titik lokasi: ${lot.latitude!.toStringAsFixed(6)}, ${lot.longitude!.toStringAsFixed(6)}',
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricColumn(
                  label: 'Harga',
                  value: parkingLotTariffSummary(lot),
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
                                  softShadow(
                                    lot.accent.withValues(alpha: 0.24),
                                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selected == null
                      ? 'Pilih marker'
                      : '${selected!.name} • ${selected!.etaMinutes} menit',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(26)),
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
                color: (foreground ?? AppTheme.emeraldSoft).withValues(
                  alpha: 0.24,
                ),
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
              color:
                  foreground?.withValues(alpha: 0.22) ?? AppTheme.emeraldSoft,
            ),
          ),
          Positioned(
            bottom: height * 0.12,
            child: Container(
              width: height * 0.46,
              height: height * 0.34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: foreground == null ? 1 : 0.18,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                      foreground?.withValues(alpha: 0.5) ??
                      accent.withValues(alpha: 0.16),
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
                    Icon(
                      item.icon,
                      color: selected ? AppTheme.blue : AppTheme.slate,
                    ),
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
  const InfoChip({super.key, required this.icon, required this.label});

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
  const MetricColumn({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.timeLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppTheme.slate),
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

class ProviderFeedbackCard extends StatelessWidget {
  const ProviderFeedbackCard({super.key, required this.item, this.onReply});

  final ProviderFeedback item;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final isComplaint = item.isComplaint;
    return PremiumCard(
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
                  color: (isComplaint ? AppTheme.blue : AppTheme.emerald)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isComplaint
                      ? Icons.report_problem_rounded
                      : Icons.star_rounded,
                  color: isComplaint ? AppTheme.blue : AppTheme.emerald,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.lotName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(
                label: item.rating.toStringAsFixed(0),
                color: item.rating >= 4 ? AppTheme.emerald : AppTheme.blue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.review,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.ink, height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(icon: Icons.schedule_rounded, label: item.timeLabel),
              InfoChip(icon: Icons.flag_rounded, label: item.status),
            ],
          ),
          if (item.providerReply != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.emeraldSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balasan penyedia',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.providerReply!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.slate,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onReply != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply_rounded),
                label: Text(item.providerReply == null ? 'Balas' : 'Ubah'),
              ),
            ),
          ],
        ],
      ),
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
    this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return Container(
      width: math.max(150, width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.12))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: onTap == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
          ),
        ),
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.slate),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = [
                  'Sen',
                  'Sel',
                  'Rab',
                  'Kam',
                  'Jum',
                  'Sab',
                  'Min',
                ];
                final text = value.toInt() >= 0 && value.toInt() < labels.length
                    ? labels[value.toInt()]
                    : '';
                return Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppTheme.slate),
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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

BoxShadow softShadow(Color color) =>
    BoxShadow(color: color, blurRadius: 24, offset: const Offset(0, 12));
