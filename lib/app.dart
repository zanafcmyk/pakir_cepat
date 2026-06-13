// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/app_models.dart';
import 'services/supabase_booking_service.dart';
import 'services/supabase_chat_service.dart';
import 'services/supabase_complaint_service.dart';
import 'services/supabase_customer_settings_service.dart';
import 'services/supabase_favorite_service.dart';
import 'services/supabase_guard_service.dart';
import 'services/supabase_notification_service.dart';
import 'services/supabase_parking_service.dart';
import 'services/supabase_payment_service.dart';
import 'services/supabase_profile_service.dart';
import 'services/supabase_profile_settings_service.dart';
import 'services/supabase_provider_document_service.dart';
import 'services/supabase_review_service.dart';
import 'services/supabase_super_admin_service.dart';
import 'services/supabase_vehicle_service.dart';
import 'widgets/map_embed_view.dart';

final appControllerProvider = StateNotifierProvider<AppController, AppState>(
  (ref) => AppController(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, routeState) {
      return guardedRedirect(
        routeState.uri.path,
        () => ref.read(appControllerProvider),
      );
    },
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
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) =>
            const ChangePasswordScreen(isRecovery: true),
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
        path: '/super-admin/chat',
        builder: (context, state) => const RoleChatListScreen(
          mode: AccountMode.superAdmin,
          title: 'Chat Super Admin',
          subtitle: 'Hubungi customer, penyedia, dan penjaga dari satu inbox.',
        ),
      ),
      GoRoute(
        path: '/super-admin/chat-room',
        builder: (context, state) => RoleChatRoomScreen(
          mode: AccountMode.superAdmin,
          roomId: state.uri.queryParameters['roomId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/super-admin/profile',
        builder: (context, state) => const SuperAdminProfileScreen(),
      ),
      GoRoute(
        path: '/super-admin/edit-profile',
        builder: (context, state) =>
            const RoleEditProfileScreen(mode: AccountMode.superAdmin),
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
        path: '/customer/chat',
        builder: (context, state) => const CustomerChatListScreen(),
      ),
      GoRoute(
        path: '/customer/chat-room',
        builder: (context, state) => CustomerChatRoomScreen(
          roomId: state.uri.queryParameters['roomId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/customer/complaint',
        builder: (context, state) => const CustomerComplaintScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: '/customer/favorites',
        builder: (context, state) => const CustomerFavoriteLotsScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/customer/edit-profile',
        builder: (context, state) => const CustomerEditProfileScreen(),
      ),
      GoRoute(
        path: '/customer/account-settings',
        builder: (context, state) => const CustomerAccountSettingsScreen(),
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
        path: '/provider/monitoring',
        builder: (context, state) => const VehicleMonitoringScreen(),
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
        path: '/provider/edit-profile',
        builder: (context, state) =>
            const RoleEditProfileScreen(mode: AccountMode.provider),
      ),
      GoRoute(
        path: '/provider/account-settings',
        builder: (context, state) =>
            const RoleAccountSettingsScreen(mode: AccountMode.provider),
      ),
      GoRoute(
        path: '/provider/chat',
        builder: (context, state) => const RoleChatListScreen(
          mode: AccountMode.provider,
          title: 'Chat Penyedia',
          subtitle: 'Balas customer, penjaga, dan super admin.',
        ),
      ),
      GoRoute(
        path: '/provider/chat-room',
        builder: (context, state) => RoleChatRoomScreen(
          mode: AccountMode.provider,
          roomId: state.uri.queryParameters['roomId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/provider/add-lot',
        builder: (context, state) => const AddParkingLotScreen(),
      ),
      GoRoute(
        path: '/provider/guards',
        builder: (context, state) => const ParkingGuardManagementScreen(),
      ),
      GoRoute(
        path: '/provider/scan-qr',
        builder: (context, state) => const ScanQrScreen(),
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
        path: '/provider/daily-revenue',
        builder: (context, state) => const ProviderDailyRevenueScreen(),
      ),
      GoRoute(
        path: '/provider/statistics',
        builder: (context, state) => const StatisticsScreen(),
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
        path: '/guard/home',
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
        path: '/guard/chat',
        builder: (context, state) => const GuardChatListScreen(),
      ),
      GoRoute(
        path: '/guard/chat-room',
        builder: (context, state) => GuardChatRoomScreen(
          roomId: state.uri.queryParameters['roomId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/guard/complaint',
        builder: (context, state) => const GuardComplaintScreen(),
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
        path: '/guard/edit-profile',
        builder: (context, state) =>
            const RoleEditProfileScreen(mode: AccountMode.parkingGuard),
      ),
      GoRoute(
        path: '/guard/account-settings',
        builder: (context, state) =>
            const RoleAccountSettingsScreen(mode: AccountMode.parkingGuard),
      ),
      GoRoute(
        path: '/guard/assigned-locations',
        builder: (context, state) => const GuardAssignedLocationsScreen(),
      ),
      GoRoute(
        path: '/guard/available-slots',
        builder: (context, state) => const GuardAvailableSlotsScreen(),
      ),
      GoRoute(
        path: '/guard/occupied-slots',
        builder: (context, state) => const GuardOccupiedSlotsScreen(),
      ),
      GoRoute(
        path: '/guard/check-payment',
        builder: (context, state) => const GuardCheckPaymentScreen(),
      ),
      GoRoute(
        path: '/guard/location-detail',
        builder: (context, state) => const GuardLocationDetailScreen(),
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

String? guardedRedirect(String location, AppState Function() readState) {
  const publicRoutes = {
    '/',
    '/onboarding',
    '/forgot-password',
    '/reset-password',
  };

  if (publicRoutes.contains(location)) {
    return null;
  }

  final state = readState();

  if (location == '/login' || location == '/register') {
    return state.isAuthenticated ? landingRouteForState(state) : null;
  }

  if (!state.isAuthenticated) {
    return '/login';
  }

  if (location == '/provider-verification') {
    return state.currentMode == AccountMode.provider &&
            state.accountStatus == AccountStatus.pending
        ? null
        : landingRouteForState(state);
  }

  if (state.currentMode == AccountMode.provider &&
      state.accountStatus == AccountStatus.pending) {
    return '/provider-verification';
  }

  final allowed = switch (state.currentMode) {
    AccountMode.customer =>
      isRouteInSection(location, '/customer') || isSharedAccountRoute(location),
    AccountMode.provider =>
      isRouteInSection(location, '/provider') ||
          isRouteInSection(location, '/admin') ||
          isSharedAccountRoute(location),
    AccountMode.parkingGuard =>
      isRouteInSection(location, '/guard') || isSharedAccountRoute(location),
    AccountMode.superAdmin =>
      isRouteInSection(location, '/super-admin') ||
          isSharedAccountRoute(location),
  };

  return allowed ? null : landingRouteForState(state);
}

bool isRouteInSection(String location, String section) {
  return location == section || location.startsWith('$section/');
}

bool isSharedAccountRoute(String location) {
  return location == '/change-password' || location == '/delete-account';
}

String landingRouteForState(AppState value) {
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
    required this.isUsingDemoData,
    required this.currentMode,
    required this.accountStatus,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.customerAvatarBytes,
    this.roleAvatarBytes,
    required this.bookingNotificationEnabled,
    required this.paymentNotificationEnabled,
    required this.promoNotificationEnabled,
    required this.selectedLanguage,
    required this.accountSecurityEnabled,
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
    required this.customerChatRooms,
    required this.customerChatMessages,
    required this.customerComplaints,
    required this.guardChatRooms,
    required this.guardChatMessages,
    required this.guardComplaints,
    required this.providerChatRooms,
    required this.providerChatMessages,
    required this.superAdminChatRooms,
    required this.superAdminChatMessages,
    required this.superAdminNotifications,
    required this.complaints,
    required this.registrationRequests,
    required this.managedUsers,
  });

  final int onboardingIndex;
  final bool onboardingDone;
  final bool isAuthenticated;
  final bool isUsingDemoData;
  final AccountMode currentMode;
  final AccountStatus accountStatus;
  final String userName;
  final String email;
  final String phoneNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Uint8List? customerAvatarBytes;
  final Uint8List? roleAvatarBytes;
  final bool bookingNotificationEnabled;
  final bool paymentNotificationEnabled;
  final bool promoNotificationEnabled;
  final String selectedLanguage;
  final bool accountSecurityEnabled;
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
  final List<ChatRoom> customerChatRooms;
  final List<ChatMessage> customerChatMessages;
  final List<Complaint> customerComplaints;
  final List<ChatRoom> guardChatRooms;
  final List<ChatMessage> guardChatMessages;
  final List<Complaint> guardComplaints;
  final List<ChatRoom> providerChatRooms;
  final List<ChatMessage> providerChatMessages;
  final List<ChatRoom> superAdminChatRooms;
  final List<ChatMessage> superAdminChatMessages;
  final List<NoticeItem> superAdminNotifications;
  final List<ComplaintItem> complaints;
  final List<RegistrationRequest> registrationRequests;
  final List<ManagedUserAccount> managedUsers;

  AppState copyWith({
    int? onboardingIndex,
    bool? onboardingDone,
    bool? isAuthenticated,
    bool? isUsingDemoData,
    AccountMode? currentMode,
    AccountStatus? accountStatus,
    String? userName,
    String? email,
    String? phoneNumber,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    Uint8List? customerAvatarBytes,
    bool removeCustomerAvatar = false,
    Uint8List? roleAvatarBytes,
    bool removeRoleAvatar = false,
    bool? bookingNotificationEnabled,
    bool? paymentNotificationEnabled,
    bool? promoNotificationEnabled,
    String? selectedLanguage,
    bool? accountSecurityEnabled,
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
    List<ChatRoom>? customerChatRooms,
    List<ChatMessage>? customerChatMessages,
    List<Complaint>? customerComplaints,
    List<ChatRoom>? guardChatRooms,
    List<ChatMessage>? guardChatMessages,
    List<Complaint>? guardComplaints,
    List<ChatRoom>? providerChatRooms,
    List<ChatMessage>? providerChatMessages,
    List<ChatRoom>? superAdminChatRooms,
    List<ChatMessage>? superAdminChatMessages,
    List<NoticeItem>? superAdminNotifications,
    List<ComplaintItem>? complaints,
    List<RegistrationRequest>? registrationRequests,
    List<ManagedUserAccount>? managedUsers,
  }) {
    return AppState(
      onboardingIndex: onboardingIndex ?? this.onboardingIndex,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isUsingDemoData: isUsingDemoData ?? this.isUsingDemoData,
      currentMode: currentMode ?? this.currentMode,
      accountStatus: accountStatus ?? this.accountStatus,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAvatarBytes: removeCustomerAvatar
          ? null
          : (customerAvatarBytes ?? this.customerAvatarBytes),
      roleAvatarBytes: removeRoleAvatar
          ? null
          : (roleAvatarBytes ?? this.roleAvatarBytes),
      bookingNotificationEnabled:
          bookingNotificationEnabled ?? this.bookingNotificationEnabled,
      paymentNotificationEnabled:
          paymentNotificationEnabled ?? this.paymentNotificationEnabled,
      promoNotificationEnabled:
          promoNotificationEnabled ?? this.promoNotificationEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      accountSecurityEnabled:
          accountSecurityEnabled ?? this.accountSecurityEnabled,
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
      customerChatRooms: customerChatRooms ?? this.customerChatRooms,
      customerChatMessages: customerChatMessages ?? this.customerChatMessages,
      customerComplaints: customerComplaints ?? this.customerComplaints,
      guardChatRooms: guardChatRooms ?? this.guardChatRooms,
      guardChatMessages: guardChatMessages ?? this.guardChatMessages,
      guardComplaints: guardComplaints ?? this.guardComplaints,
      providerChatRooms: providerChatRooms ?? this.providerChatRooms,
      providerChatMessages: providerChatMessages ?? this.providerChatMessages,
      superAdminChatRooms: superAdminChatRooms ?? this.superAdminChatRooms,
      superAdminChatMessages:
          superAdminChatMessages ?? this.superAdminChatMessages,
      superAdminNotifications:
          superAdminNotifications ?? this.superAdminNotifications,
      complaints: complaints ?? this.complaints,
      registrationRequests: registrationRequests ?? this.registrationRequests,
      managedUsers: managedUsers ?? this.managedUsers,
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
        tariffType: ParkingTariffType.hourly,
        motorRate: 5000,
        carRate: 12000,
        truckRate: 20000,
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
        tariffType: ParkingTariffType.flat,
        motorRate: 6000,
        carRate: 15000,
        truckRate: 25000,
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
        tariffType: ParkingTariffType.progressive,
        motorRate: 4000,
        carRate: 10000,
        truckRate: 18000,
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

    const superAdminNotifications = [
      NoticeItem(
        title: 'Komplain baru',
        message: 'Pelanggan melaporkan pembayaran tunai belum dikonfirmasi.',
        timeLabel: '8 menit lalu',
        icon: Icons.mark_chat_unread_rounded,
        accent: AppTheme.blue,
      ),
      NoticeItem(
        title: 'Verifikasi pendaftaran',
        message: 'Penyedia Parkir Senayan menunggu konfirmasi super admin.',
        timeLabel: '25 menit lalu',
        icon: Icons.how_to_reg_rounded,
        accent: AppTheme.emerald,
      ),
    ];

    const complaints = [
      ComplaintItem(
        id: 'cmp-1',
        senderName: 'Dio Pratama',
        senderRole: AccountMode.customer,
        subject: 'Pembayaran tunai belum dikonfirmasi',
        message:
            'Saya sudah bayar tunai ke penjaga, tetapi status tiket masih belum lunas.',
        timeLabel: '8 menit lalu',
        status: ComplaintStatus.waiting,
      ),
      ComplaintItem(
        id: 'cmp-2',
        senderName: 'Admin Plaza Sudirman',
        senderRole: AccountMode.provider,
        subject: 'Approval perubahan tarif',
        message:
            'Mohon tinjau perubahan tarif jam sibuk agar bisa diterapkan minggu ini.',
        timeLabel: '32 menit lalu',
        status: ComplaintStatus.waiting,
      ),
      ComplaintItem(
        id: 'cmp-3',
        senderName: 'Raka Penjaga',
        senderRole: AccountMode.parkingGuard,
        subject: 'Akses scan QR tidak tampil',
        message:
            'Menu scan QR sempat tidak aktif saat saya bertugas di lot Emerald.',
        timeLabel: '1 jam lalu',
        status: ComplaintStatus.answered,
        reply:
            'Akses penjaga sudah dicek. Silakan login ulang, lalu hubungi penyedia bila lokasi tugas belum muncul.',
      ),
    ];

    const registrationRequests = [
      RegistrationRequest(
        id: 'reg-1',
        fullName: 'Parkir Senayan Center',
        email: 'admin@senayanparkir.app',
        phoneNumber: '+62 811 9090 7722',
        role: AccountMode.provider,
        timeLabel: '25 menit lalu',
        status: AccountStatus.pending,
        providerApplication: ProviderApplication(
          parkingName: 'Parkir Senayan Center',
          address: 'Jl. Asia Afrika Pintu 4',
          photoLabel: 'foto_lahan_senayan.jpg',
          locationLabel: '-6.227, 106.801',
          capacity: 180,
          identityLabel: 'KTP dan NIB terunggah',
        ),
      ),
    ];

    const managedUsers = [
      ManagedUserAccount(
        id: 'usr-customer-1',
        name: 'Dio Pratama',
        email: 'dio@parkircepat.app',
        role: AccountMode.customer,
        status: UserAccessStatus.active,
        note: 'Pelanggan aktif dengan tiket dan kendaraan tersimpan.',
      ),
      ManagedUserAccount(
        id: 'usr-provider-1',
        name: 'Admin Plaza Sudirman',
        email: 'admin@sudirmanparkir.app',
        role: AccountMode.provider,
        status: UserAccessStatus.active,
        note: 'Penyedia utama dengan beberapa lokasi aktif.',
      ),
      ManagedUserAccount(
        id: 'usr-guard-1',
        name: 'Raka Penjaga',
        email: 'raka.guard@parkircepat.app',
        role: AccountMode.parkingGuard,
        status: UserAccessStatus.active,
        note: 'Penjaga untuk Plaza Sudirman dan Emerald.',
      ),
      ManagedUserAccount(
        id: 'usr-review-1',
        name: 'Akun Pembayaran Bermasalah',
        email: 'review@parkircepat.app',
        role: AccountMode.customer,
        status: UserAccessStatus.suspended,
        note: 'Ditahan karena laporan pembayaran manual belum cocok.',
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

    final seededChatTime = DateTime(2026, 6, 8, 9, 15);
    final guardChatRooms = [
      ChatRoom(
        id: 'guard-customer-tkt-1002',
        title: 'Chat Customer - TKT-1002',
        participantRole: 'Customer',
        participantName: 'Customer TKT-1002',
        lastMessage: 'Baik Pak, saya cek tiketnya.',
        lastMessageAt: seededChatTime.subtract(const Duration(minutes: 12)),
        unreadCount: 1,
      ),
      ChatRoom(
        id: 'guard-provider-main',
        title: 'Penyedia Parkir',
        participantRole: 'Penyedia Parkir',
        participantName: 'Penyedia Parkir',
        lastMessage: 'Laporkan kondisi operasional jika ada kendala.',
        lastMessageAt: seededChatTime.subtract(const Duration(minutes: 30)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'guard-admin-app',
        title: 'Admin Aplikasi',
        participantRole: 'Admin Aplikasi',
        participantName: 'Admin Aplikasi',
        lastMessage: 'Gunakan form komplain untuk masalah aplikasi.',
        lastMessageAt: seededChatTime.subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
    ];

    final guardChatMessages = [
      ChatMessage(
        id: 'msg-guard-customer-1',
        roomId: 'guard-customer-tkt-1002',
        senderRole: 'Customer',
        senderName: 'Customer TKT-1002',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Raka Penjaga',
        message: 'Pak, tiket saya TKT-1002 belum terbaca di gerbang.',
        createdAt: seededChatTime.subtract(const Duration(minutes: 18)),
        isRead: false,
      ),
      ChatMessage(
        id: 'msg-guard-customer-2',
        roomId: 'guard-customer-tkt-1002',
        senderRole: 'Penjaga Parkir',
        senderName: 'Raka Penjaga',
        receiverRole: 'Customer',
        receiverName: 'Customer TKT-1002',
        message: 'Baik Pak, saya cek tiketnya.',
        createdAt: seededChatTime.subtract(const Duration(minutes: 12)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-guard-provider-1',
        roomId: 'guard-provider-main',
        senderRole: 'Penyedia Parkir',
        senderName: 'Penyedia Parkir',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Raka Penjaga',
        message: 'Laporkan kondisi operasional jika ada kendala.',
        createdAt: seededChatTime.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-guard-admin-1',
        roomId: 'guard-admin-app',
        senderRole: 'Admin Aplikasi',
        senderName: 'Admin Aplikasi',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Raka Penjaga',
        message: 'Gunakan form komplain untuk masalah aplikasi.',
        createdAt: seededChatTime.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ];

    final customerChatTime = DateTime(2026, 6, 8, 10, 5);
    final customerChatRooms = [
      ChatRoom(
        id: 'customer-guard-tkt-1002',
        title: 'Chat Penjaga - TKT-1002',
        participantRole: 'Penjaga Parkir',
        participantName: 'Penjaga Parkir - Parkir Plaza Sudirman',
        lastMessage: 'Silakan tunjukkan QR tiket di gerbang masuk.',
        lastMessageAt: customerChatTime.subtract(const Duration(minutes: 10)),
        unreadCount: 1,
      ),
      ChatRoom(
        id: 'customer-provider-lot-1',
        title: 'Chat Penyedia - Parkir Plaza Sudirman',
        participantRole: 'Penyedia Parkir',
        participantName: 'Penyedia - Parkir Plaza Sudirman',
        lastMessage: 'Tarif mengikuti jam masuk dan jenis kendaraan.',
        lastMessageAt: customerChatTime.subtract(const Duration(minutes: 28)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'customer-admin-app',
        title: 'Admin Aplikasi',
        participantRole: 'Admin Aplikasi',
        participantName: 'Admin Aplikasi',
        lastMessage: 'Laporkan kendala aplikasi lewat form komplain.',
        lastMessageAt: customerChatTime.subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
    ];

    final customerChatMessages = [
      ChatMessage(
        id: 'msg-customer-guard-1',
        roomId: 'customer-guard-tkt-1002',
        senderRole: 'Customer',
        senderName: 'Dio Pratama',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Penjaga Parkir - Parkir Plaza Sudirman',
        message: 'Pak, slot saya ada di area mana?',
        createdAt: customerChatTime.subtract(const Duration(minutes: 16)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-customer-guard-2',
        roomId: 'customer-guard-tkt-1002',
        senderRole: 'Penjaga Parkir',
        senderName: 'Penjaga Parkir - Parkir Plaza Sudirman',
        receiverRole: 'Customer',
        receiverName: 'Dio Pratama',
        message: 'Silakan tunjukkan QR tiket di gerbang masuk.',
        createdAt: customerChatTime.subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
      ChatMessage(
        id: 'msg-customer-provider-1',
        roomId: 'customer-provider-lot-1',
        senderRole: 'Customer',
        senderName: 'Dio Pratama',
        receiverRole: 'Penyedia Parkir',
        receiverName: 'Penyedia - Parkir Plaza Sudirman',
        message: 'Apakah tarif malam sama dengan siang?',
        createdAt: customerChatTime.subtract(const Duration(minutes: 35)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-customer-provider-2',
        roomId: 'customer-provider-lot-1',
        senderRole: 'Penyedia Parkir',
        senderName: 'Penyedia - Parkir Plaza Sudirman',
        receiverRole: 'Customer',
        receiverName: 'Dio Pratama',
        message: 'Tarif mengikuti jam masuk dan jenis kendaraan.',
        createdAt: customerChatTime.subtract(const Duration(minutes: 28)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-customer-admin-1',
        roomId: 'customer-admin-app',
        senderRole: 'Admin Aplikasi',
        senderName: 'Admin Aplikasi',
        receiverRole: 'Customer',
        receiverName: 'Dio Pratama',
        message: 'Laporkan kendala aplikasi lewat form komplain.',
        createdAt: customerChatTime.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];

    final providerChatRooms = [
      ChatRoom(
        id: 'provider-customer-lot-1',
        title: 'Chat Customer - Parkir Plaza Sudirman',
        participantRole: 'Customer',
        participantName: 'Dio Pratama',
        lastMessage: 'Apakah tarif malam sama dengan siang?',
        lastMessageAt: customerChatTime.subtract(const Duration(minutes: 35)),
        unreadCount: 1,
      ),
      ChatRoom(
        id: 'provider-guard-main',
        title: 'Chat Penjaga - Raka Penjaga',
        participantRole: 'Penjaga Parkir',
        participantName: 'Raka Penjaga',
        lastMessage: 'Laporkan kondisi operasional jika ada kendala.',
        lastMessageAt: seededChatTime.subtract(const Duration(minutes: 30)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'provider-superadmin-main',
        title: 'Chat Super Admin',
        participantRole: 'Super Admin',
        participantName: 'Admin Super Parkir Cepat',
        lastMessage: 'Koordinasikan kendala penyedia di sini.',
        lastMessageAt: seededChatTime.subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
    ];

    final providerChatMessages = [
      ChatMessage(
        id: 'msg-provider-customer-1',
        roomId: 'provider-customer-lot-1',
        senderRole: 'Customer',
        senderName: 'Dio Pratama',
        receiverRole: 'Penyedia Parkir',
        receiverName: 'Penyedia - Parkir Plaza Sudirman',
        message: 'Apakah tarif malam sama dengan siang?',
        createdAt: customerChatTime.subtract(const Duration(minutes: 35)),
        isRead: false,
      ),
      ChatMessage(
        id: 'msg-provider-customer-2',
        roomId: 'provider-customer-lot-1',
        senderRole: 'Penyedia Parkir',
        senderName: 'Penyedia - Parkir Plaza Sudirman',
        receiverRole: 'Customer',
        receiverName: 'Dio Pratama',
        message: 'Tarif mengikuti jam masuk dan jenis kendaraan.',
        createdAt: customerChatTime.subtract(const Duration(minutes: 28)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-provider-guard-1',
        roomId: 'provider-guard-main',
        senderRole: 'Penyedia Parkir',
        senderName: 'Penyedia Parkir',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Raka Penjaga',
        message: 'Laporkan kondisi operasional jika ada kendala.',
        createdAt: seededChatTime.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-provider-superadmin-1',
        roomId: 'provider-superadmin-main',
        senderRole: 'Super Admin',
        senderName: 'Admin Super Parkir Cepat',
        receiverRole: 'Penyedia Parkir',
        receiverName: 'Penyedia - Parkir Plaza Sudirman',
        message: 'Koordinasikan kendala penyedia di sini.',
        createdAt: seededChatTime.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];

    final superAdminChatRooms = [
      ChatRoom(
        id: 'superadmin-customer-app',
        title: 'Chat Customer - Dio Pratama',
        participantRole: 'Customer',
        participantName: 'Dio Pratama',
        lastMessage: 'Laporkan kendala aplikasi lewat form komplain.',
        lastMessageAt: customerChatTime.subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'superadmin-provider-main',
        title: 'Chat Penyedia - Plaza Sudirman',
        participantRole: 'Penyedia Parkir',
        participantName: 'Penyedia - Parkir Plaza Sudirman',
        lastMessage: 'Koordinasikan kendala penyedia di sini.',
        lastMessageAt: seededChatTime.subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'superadmin-guard-app',
        title: 'Chat Penjaga - Raka Penjaga',
        participantRole: 'Penjaga Parkir',
        participantName: 'Raka Penjaga',
        lastMessage: 'Gunakan form komplain untuk masalah aplikasi.',
        lastMessageAt: seededChatTime.subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
    ];

    final superAdminChatMessages = [
      ChatMessage(
        id: 'msg-superadmin-customer-1',
        roomId: 'superadmin-customer-app',
        senderRole: 'Super Admin',
        senderName: 'Admin Super Parkir Cepat',
        receiverRole: 'Customer',
        receiverName: 'Dio Pratama',
        message: 'Laporkan kendala aplikasi lewat form komplain.',
        createdAt: customerChatTime.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-superadmin-provider-1',
        roomId: 'superadmin-provider-main',
        senderRole: 'Super Admin',
        senderName: 'Admin Super Parkir Cepat',
        receiverRole: 'Penyedia Parkir',
        receiverName: 'Penyedia - Parkir Plaza Sudirman',
        message: 'Koordinasikan kendala penyedia di sini.',
        createdAt: seededChatTime.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-superadmin-guard-1',
        roomId: 'superadmin-guard-app',
        senderRole: 'Admin Aplikasi',
        senderName: 'Admin Aplikasi',
        receiverRole: 'Penjaga Parkir',
        receiverName: 'Raka Penjaga',
        message: 'Gunakan form komplain untuk masalah aplikasi.',
        createdAt: seededChatTime.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ];

    return AppState(
      onboardingIndex: 0,
      onboardingDone: false,
      isAuthenticated: false,
      isUsingDemoData: true,
      currentMode: AccountMode.customer,
      accountStatus: AccountStatus.verified,
      userName: 'Dio Pratama',
      email: 'dio@parkircepat.app',
      phoneNumber: '+62 812 7788 9911',
      customerName: 'Dio Pratama',
      customerEmail: 'dio@parkircepat.app',
      customerPhone: '+62 812 7788 9911',
      customerAvatarBytes: null,
      roleAvatarBytes: null,
      bookingNotificationEnabled: true,
      paymentNotificationEnabled: true,
      promoNotificationEnabled: false,
      selectedLanguage: 'Indonesia',
      accountSecurityEnabled: true,
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
      customerChatRooms: customerChatRooms,
      customerChatMessages: customerChatMessages,
      customerComplaints: const [],
      guardChatRooms: guardChatRooms,
      guardChatMessages: guardChatMessages,
      guardComplaints: const [],
      providerChatRooms: providerChatRooms,
      providerChatMessages: providerChatMessages,
      superAdminChatRooms: superAdminChatRooms,
      superAdminChatMessages: superAdminChatMessages,
      superAdminNotifications: superAdminNotifications,
      complaints: complaints,
      registrationRequests: registrationRequests,
      managedUsers: managedUsers,
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

Color roleAccent(AccountMode mode) => switch (mode) {
  AccountMode.superAdmin => AppTheme.ink,
  AccountMode.provider => AppTheme.emerald,
  AccountMode.parkingGuard => const Color(0xFFD97706),
  AccountMode.customer => AppTheme.blue,
};

AccountStatus accountStatusFromDb(String? value) => switch (value) {
  'verified' => AccountStatus.verified,
  'rejected' => AccountStatus.rejected,
  _ => AccountStatus.pending,
};

String complaintStatusLabel(ComplaintStatus status) => switch (status) {
  ComplaintStatus.waiting => 'Menunggu jawaban',
  ComplaintStatus.answered => 'Terjawab',
  ComplaintStatus.closed => 'Selesai',
};

Color complaintStatusColor(ComplaintStatus status) => switch (status) {
  ComplaintStatus.waiting => const Color(0xFFD97706),
  ComplaintStatus.answered => AppTheme.emerald,
  ComplaintStatus.closed => AppTheme.slate,
};

String userAccessStatusLabel(UserAccessStatus status) => switch (status) {
  UserAccessStatus.active => 'Aktif',
  UserAccessStatus.suspended => 'Nonaktif',
};

Color userAccessStatusColor(UserAccessStatus status) => switch (status) {
  UserAccessStatus.active => AppTheme.emerald,
  UserAccessStatus.suspended => const Color(0xFFDC2626),
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

class AppController extends StateNotifier<AppState> {
  AppController() : super(AppState.seeded()) {
    _loadOnboardingPreference();
  }

  static const _onboardingDoneKey = 'parkir_cepat_onboarding_done';

  final SupabaseChatService _chatService = SupabaseChatService();
  final SupabaseComplaintService _complaintService = SupabaseComplaintService();
  final SupabaseCustomerSettingsService _customerSettingsService =
      SupabaseCustomerSettingsService();
  final SupabaseProfileSettingsService _profileSettingsService =
      SupabaseProfileSettingsService();
  final SupabaseParkingService _parkingService = SupabaseParkingService();
  final SupabaseVehicleService _vehicleService = SupabaseVehicleService();
  final SupabaseBookingService _bookingService = SupabaseBookingService();
  final SupabasePaymentService _paymentService = SupabasePaymentService();
  final SupabaseNotificationService _notificationService =
      SupabaseNotificationService();
  final SupabaseGuardService _guardService = SupabaseGuardService();
  final SupabaseFavoriteService _favoriteService = SupabaseFavoriteService();
  final SupabaseProfileService _profileService = SupabaseProfileService();
  final SupabaseReviewService _reviewService = SupabaseReviewService();
  final SupabaseSuperAdminService _superAdminService =
      SupabaseSuperAdminService();
  RealtimeChannel? _parkingSlotRealtimeChannel;
  RealtimeChannel? _parkingLotRealtimeChannel;
  RealtimeChannel? _notificationRealtimeChannel;
  Timer? _parkingSlotRealtimeDebounce;
  Timer? _notificationRealtimeDebounce;
  String? _notificationRealtimeProfileId;

  ChatMessage _outgoingMessage({
    required String roomId,
    required String senderRole,
    required String senderName,
    required String receiverRole,
    required String receiverName,
    required String message,
    required DateTime createdAt,
  }) {
    return ChatMessage(
      id: 'msg-${createdAt.microsecondsSinceEpoch}-$roomId',
      roomId: roomId,
      senderRole: senderRole,
      senderName: senderName,
      receiverRole: receiverRole,
      receiverName: receiverName,
      message: message,
      createdAt: createdAt,
      isRead: true,
    );
  }

  ChatMessage _mirrorMessage(ChatMessage message, String roomId) {
    return message.copyWith(roomId: roomId, isRead: false);
  }

  void _syncChatMessage({
    required String localRoomId,
    required String title,
    required AccountMode senderMode,
    required String senderName,
    required String participantRole,
    required String participantName,
    required String message,
  }) {
    unawaited(
      _chatService
          .sendMessage(
            localRoomId: localRoomId,
            title: title,
            senderMode: senderMode,
            senderName: senderName,
            participantRole: participantRole,
            participantName: participantName,
            message: message,
          )
          .catchError((_) {}),
    );
  }

  void _syncCurrentUserNotification(NoticeItem notice, {String type = 'info'}) {
    unawaited(
      _notificationService
          .saveCurrentUserNotification(
            title: notice.title,
            message: notice.message,
            type: type,
          )
          .catchError((_) {}),
    );
  }

  Future<void> loadChatMessagesFromSupabase({
    required AccountMode mode,
    required String roomId,
  }) async {
    final messages = await _chatService.fetchMessages(localRoomId: roomId);
    _replaceChatMessages(mode: mode, roomId: roomId, messages: messages);
  }

  void replaceChatMessagesFromSupabase({
    required AccountMode mode,
    required String roomId,
    required List<ChatMessage> messages,
  }) {
    _replaceChatMessages(mode: mode, roomId: roomId, messages: messages);
  }

  Future<Stream<List<ChatMessage>>> watchChatMessagesFromSupabase({
    required String roomId,
  }) {
    return _chatService.watchMessages(localRoomId: roomId);
  }

  void _replaceChatMessages({
    required AccountMode mode,
    required String roomId,
    required List<ChatMessage> messages,
  }) {
    if (messages.isEmpty) {
      return;
    }

    List<ChatMessage> merge(List<ChatMessage> current) {
      return [
        for (final message in current)
          if (message.roomId != roomId) message,
        ...messages,
      ];
    }

    switch (mode) {
      case AccountMode.customer:
        state = state.copyWith(
          customerChatMessages: merge(state.customerChatMessages),
        );
      case AccountMode.provider:
        state = state.copyWith(
          providerChatMessages: merge(state.providerChatMessages),
        );
      case AccountMode.parkingGuard:
        state = state.copyWith(
          guardChatMessages: merge(state.guardChatMessages),
        );
      case AccountMode.superAdmin:
        state = state.copyWith(
          superAdminChatMessages: merge(state.superAdminChatMessages),
        );
    }
  }

  List<ChatRoom> _touchRoom(
    List<ChatRoom> rooms,
    String roomId,
    String message,
    DateTime at, {
    bool unread = false,
  }) {
    return [
      for (final room in rooms)
        if (room.id == roomId)
          room.copyWith(
            lastMessage: message,
            lastMessageAt: at,
            unreadCount: unread ? room.unreadCount + 1 : 0,
          )
        else
          room,
    ];
  }

  String? _mirrorRoomId(AccountMode from, String roomId) {
    return switch ((from, roomId)) {
      (AccountMode.customer, 'customer-guard-tkt-1002') =>
        'guard-customer-tkt-1002',
      (AccountMode.customer, 'customer-provider-lot-1') =>
        'provider-customer-lot-1',
      (AccountMode.customer, 'customer-admin-app') => 'superadmin-customer-app',
      (AccountMode.parkingGuard, 'guard-customer-tkt-1002') =>
        'customer-guard-tkt-1002',
      (AccountMode.parkingGuard, 'guard-provider-main') =>
        'provider-guard-main',
      (AccountMode.parkingGuard, 'guard-admin-app') => 'superadmin-guard-app',
      (AccountMode.provider, 'provider-customer-lot-1') =>
        'customer-provider-lot-1',
      (AccountMode.provider, 'provider-guard-main') => 'guard-provider-main',
      (AccountMode.provider, 'provider-superadmin-main') =>
        'superadmin-provider-main',
      (AccountMode.superAdmin, 'superadmin-customer-app') =>
        'customer-admin-app',
      (AccountMode.superAdmin, 'superadmin-provider-main') =>
        'provider-superadmin-main',
      (AccountMode.superAdmin, 'superadmin-guard-app') => 'guard-admin-app',
      _ => null,
    };
  }

  String landingRouteFor(AppState value) {
    return landingRouteForState(value);
  }

  void setOnboardingPage(int index) {
    state = state.copyWith(onboardingIndex: index);
  }

  Future<void> _loadOnboardingPreference() async {
    final preferences = await SharedPreferences.getInstance();
    final onboardingDone = preferences.getBool(_onboardingDoneKey) ?? false;
    if (onboardingDone) {
      state = state.copyWith(onboardingDone: true);
    }
  }

  Future<void> finishOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingDoneKey, true);
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> loadParkingDataFromSupabase() async {
    final data = await _parkingService.fetchParkingData();
    if (data.lots.isEmpty) {
      return;
    }

    final selectedLot = data.lots.firstWhere(
      (lot) => lot.id == state.selectedLot?.id,
      orElse: () => data.lots.first,
    );

    state = state.copyWith(
      lots: data.lots,
      selectedLot: selectedLot,
      slots: data.slots.isEmpty ? state.slots : data.slots,
      isUsingDemoData: false,
    );
    startParkingSlotRealtime();
    startParkingLocationRealtime();
  }

  void startParkingSlotRealtime() {
    if (_parkingSlotRealtimeChannel != null) {
      return;
    }

    _parkingSlotRealtimeChannel = Supabase.instance.client
        .channel('public:parking_slots:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_slots',
          callback: (_) => _scheduleParkingDataRealtimeRefresh(),
        )
        .subscribe();
  }

  void startParkingLocationRealtime() {
    if (_parkingLotRealtimeChannel != null) {
      return;
    }

    _parkingLotRealtimeChannel = Supabase.instance.client
        .channel('public:parking_lots:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_lots',
          callback: (_) => _scheduleParkingDataRealtimeRefresh(),
        )
        .subscribe();
  }

  void _scheduleParkingDataRealtimeRefresh() {
    _parkingSlotRealtimeDebounce?.cancel();
    _parkingSlotRealtimeDebounce = Timer(const Duration(milliseconds: 450), () {
      unawaited(_refreshParkingDataFromRealtime());
    });
  }

  Future<void> _refreshParkingDataFromRealtime() async {
    try {
      final data = await _parkingService.fetchParkingData();
      if (!mounted || data.lots.isEmpty) {
        return;
      }

      final selectedLot = data.lots.firstWhere(
        (lot) => lot.id == state.selectedLot?.id,
        orElse: () => data.lots.first,
      );

      state = state.copyWith(
        lots: data.lots,
        selectedLot: selectedLot,
        slots: data.slots.isEmpty ? state.slots : data.slots,
        isUsingDemoData: false,
      );
    } catch (_) {
      // Realtime refresh is best-effort; manual reload still works.
    }
  }

  Future<void> searchParkingLotsFromSupabase(String query) async {
    final data = await _parkingService.fetchParkingData(searchQuery: query);
    state = state.copyWith(
      lots: data.lots,
      selectedLot: data.lots.isEmpty ? state.selectedLot : data.lots.first,
      slots: data.slots.isEmpty ? state.slots : data.slots,
      isUsingDemoData: data.lots.isEmpty ? state.isUsingDemoData : false,
    );
  }

  Future<void> loadCustomerVehiclesFromSupabase() async {
    final vehicles = await _vehicleService.fetchCurrentCustomerVehicles();
    if (vehicles.isEmpty) {
      return;
    }

    final selectedVehicle = vehicles.firstWhere(
      (vehicle) => vehicle.id == state.selectedVehicle?.id,
      orElse: () => vehicles.first,
    );

    state = state.copyWith(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }

  Future<void> loadActiveBookingFromSupabase() async {
    final activeBooking = await _bookingService
        .fetchCurrentCustomerActiveBooking();
    if (activeBooking == null) {
      state = state.copyWith(clearBooking: true);
      return;
    }

    state = state.copyWith(activeBooking: activeBooking.booking);
  }

  Future<void> loadCustomerHistoryFromSupabase() async {
    final history = await _bookingService.fetchCurrentCustomerHistory();
    state = state.copyWith(history: history);
  }

  Future<void> loadCustomerFavoritesFromSupabase() async {
    final favoriteLotIds = await _favoriteService
        .fetchCurrentCustomerFavoriteLotIds();
    state = state.copyWith(favoriteLotIds: favoriteLotIds);
  }

  Future<void> loadCustomerSettingsFromSupabase() async {
    final settings = await _customerSettingsService
        .fetchCurrentCustomerSettings();
    if (settings == null) {
      return;
    }

    state = state.copyWith(
      bookingNotificationEnabled: settings.bookingNotificationEnabled,
      paymentNotificationEnabled: settings.paymentNotificationEnabled,
      promoNotificationEnabled: settings.promoNotificationEnabled,
      selectedLanguage: settings.selectedLanguage,
      accountSecurityEnabled: settings.accountSecurityEnabled,
    );
  }

  Future<void> submitParkingReview({
    required String ticketNumber,
    required int rating,
    required String comment,
  }) {
    return _reviewService.submitReviewForTicket(
      ticketNumber: ticketNumber,
      rating: rating,
      comment: comment,
    );
  }

  Future<void> loadComplaintsFromSupabase() async {
    final complaints = await _complaintService.fetchComplaintsForAdmin();
    state = state.copyWith(complaints: complaints);
  }

  Future<void> loadCurrentUserNotificationsFromSupabase() async {
    final notices = await _notificationService.fetchCurrentUserNotifications();

    switch (state.currentMode) {
      case AccountMode.customer:
        state = state.copyWith(customerNotifications: notices);
      case AccountMode.provider:
      case AccountMode.parkingGuard:
        state = state.copyWith(adminNotifications: notices);
      case AccountMode.superAdmin:
        state = state.copyWith(superAdminNotifications: notices);
    }
    startCurrentUserNotificationsRealtime();
  }

  void startCurrentUserNotificationsRealtime() {
    final profileId = Supabase.instance.client.auth.currentUser?.id;
    if (profileId == null) {
      return;
    }
    if (_notificationRealtimeChannel != null &&
        _notificationRealtimeProfileId == profileId) {
      return;
    }

    final oldChannel = _notificationRealtimeChannel;
    if (oldChannel != null) {
      unawaited(Supabase.instance.client.removeChannel(oldChannel));
    }

    _notificationRealtimeProfileId = profileId;
    _notificationRealtimeChannel = Supabase.instance.client
        .channel('public:notifications:$profileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          callback: (_) => _scheduleNotificationRealtimeRefresh(),
        )
        .subscribe();
  }

  void _scheduleNotificationRealtimeRefresh() {
    _notificationRealtimeDebounce?.cancel();
    _notificationRealtimeDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_refreshCurrentUserNotificationsFromRealtime()),
    );
  }

  Future<void> _refreshCurrentUserNotificationsFromRealtime() async {
    try {
      await loadCurrentUserNotificationsFromSupabase();
    } catch (_) {
      // Realtime refresh is best-effort; opening the notification page reloads.
    }
  }

  Future<void> loadProviderGuardsFromSupabase() async {
    final guards = await _guardService.fetchCurrentProviderGuards();
    state = state.copyWith(parkingGuards: guards);
  }

  Future<void> loadCurrentGuardFromSupabase() async {
    final guard = await _guardService.fetchCurrentGuardAccount();
    if (guard == null) {
      state = state.copyWith(parkingGuards: const [], clearActiveGuard: true);
      return;
    }

    state = state.copyWith(parkingGuards: [guard], activeGuardId: guard.id);
  }

  Future<SupabaseReceiptRecord?> fetchLatestReceiptFromSupabase() {
    return _paymentService.fetchLatestReceipt();
  }

  Future<SupabaseProviderDashboardSummary>
  fetchProviderDashboardSummaryFromSupabase() {
    return _parkingService.fetchCurrentProviderDashboardSummary();
  }

  Future<SupabaseProviderDailyRevenue> fetchProviderDailyRevenueFromSupabase() {
    return _parkingService.fetchCurrentProviderDailyRevenue();
  }

  Future<SupabaseProviderFinancialReport>
  fetchProviderFinancialReportFromSupabase() {
    return _parkingService.fetchCurrentProviderFinancialReport();
  }

  Future<void> loadProviderMonitoringFromSupabase() async {
    final report = await _parkingService.fetchCurrentProviderFinancialReport();
    state = state.copyWith(history: report.transactions);
  }

  Future<SupabaseSuperAdminOverview> fetchSuperAdminOverviewFromSupabase() {
    return _superAdminService.fetchOverview();
  }

  Future<SupabaseSuperAdminReport> fetchSuperAdminReportFromSupabase() {
    return _superAdminService.fetchReport();
  }

  Future<void> loadManagedUsersFromSupabase() async {
    final users = await _superAdminService.fetchManagedUsers();
    if (users.isEmpty) {
      return;
    }
    state = state.copyWith(managedUsers: users);
  }

  void login({
    required AccountMode mode,
    required String email,
    required String phoneNumber,
    required bool rememberMe,
    AccountStatus? accountStatusOverride,
    ProviderApplication? providerApplication,
    bool clearProviderApplication = false,
  }) {
    final accountStatus =
        accountStatusOverride ??
        (mode == AccountMode.provider
            ? (state.providerApplication == null
                  ? AccountStatus.verified
                  : state.accountStatus)
            : AccountStatus.verified);
    final guardId = mode == AccountMode.parkingGuard
        ? (state.activeGuardId ??
              (state.parkingGuards.isEmpty
                  ? null
                  : state.parkingGuards.first.id))
        : null;
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
      activeGuardId: guardId,
      clearActiveGuard: mode != AccountMode.parkingGuard,
      providerApplication: providerApplication,
      clearProviderApplication: clearProviderApplication,
    );
  }

  void register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required AccountMode mode,
    ProviderApplication? providerApplication,
  }) {
    final verificationRequest = RegistrationRequest(
      id: 'reg-${state.registrationRequests.length + 1}',
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: mode,
      timeLabel: 'Baru saja',
      status: AccountStatus.pending,
      providerApplication: providerApplication,
    );
    state = state.copyWith(
      userName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      customerName: mode == AccountMode.customer
          ? fullName
          : state.customerName,
      customerEmail: mode == AccountMode.customer ? email : state.customerEmail,
      customerPhone: mode == AccountMode.customer
          ? phoneNumber
          : state.customerPhone,
      currentMode: mode,
      isAuthenticated: true,
      onboardingDone: true,
      accountStatus: mode == AccountMode.provider
          ? AccountStatus.pending
          : AccountStatus.verified,
      activeGuardId: mode == AccountMode.parkingGuard
          ? (state.parkingGuards.isEmpty ? null : state.parkingGuards.first.id)
          : null,
      clearActiveGuard: mode != AccountMode.parkingGuard,
      providerApplication: providerApplication,
      registrationRequests: mode == AccountMode.superAdmin
          ? state.registrationRequests
          : [verificationRequest, ...state.registrationRequests],
      superAdminNotifications: mode == AccountMode.superAdmin
          ? state.superAdminNotifications
          : [
              NoticeItem(
                title: 'Verifikasi pendaftaran',
                message: '$fullName mendaftar sebagai ${roleLabel(mode)}.',
                timeLabel: 'Baru saja',
                icon: Icons.how_to_reg_rounded,
                accent: AppTheme.emerald,
              ),
              ...state.superAdminNotifications,
            ],
    );
  }

  void requestPasswordReset() {
    state = state.copyWith(passwordResetRequested: true);
  }

  void logout() {
    _stopRealtimeSubscriptions();
    state = state.copyWith(isAuthenticated: false);
  }

  Future<void> deleteAccount() async {
    await Supabase.instance.client.functions.invoke('delete-account');
    await Supabase.instance.client.auth.signOut();
    _stopRealtimeSubscriptions();
    final seeded = AppState.seeded();
    state = seeded;
  }

  void switchMode(AccountMode mode) {
    state = state.copyWith(
      currentMode: mode,
      activeGuardId: mode == AccountMode.parkingGuard
          ? (state.activeGuardId ??
                (state.parkingGuards.isEmpty
                    ? null
                    : state.parkingGuards.first.id))
          : null,
      clearActiveGuard: mode != AccountMode.parkingGuard,
    );
  }

  Future<void> createParkingGuard({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required List<String> assignedLotIds,
    required bool canScanQr,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) async {
    final guard = await _guardService.createGuardAccount(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      assignedLotIds: assignedLotIds,
      canScanQr: canScanQr,
      canConfirmCash: canConfirmCash,
      canManageSlots: canManageSlots,
    );
    state = state.copyWith(
      parkingGuards: [
        guard,
        for (final item in state.parkingGuards)
          if (item.id != guard.id) item,
      ],
    );
  }

  Future<void> updateParkingGuard({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required List<String> assignedLotIds,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) async {
    final currentGuard = state.parkingGuards.firstWhere(
      (guard) => guard.id == id,
      orElse: () => ParkingGuardAccount(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        providerId: 'provider-main',
        assignedLotIds: assignedLotIds,
        canScanQr: true,
        canConfirmCash: canConfirmCash,
        canManageSlots: canManageSlots,
      ),
    );
    final updatedGuard = await _guardService.linkExistingGuard(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      assignedLotIds: assignedLotIds,
      canScanQr: currentGuard.canScanQr,
      canConfirmCash: canConfirmCash,
      canManageSlots: canManageSlots,
    );

    state = state.copyWith(
      parkingGuards: [
        for (final guard in state.parkingGuards)
          if (guard.id == id) updatedGuard else guard,
      ],
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

  Future<void> deleteParkingGuard(String id) async {
    await _guardService.unlinkGuard(id);
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

  Future<void> updateRegistrationStatus(String id, AccountStatus status) async {
    RegistrationRequest? selected;
    final requests = [
      for (final request in state.registrationRequests)
        if (request.id == id)
          selected = request.copyWith(status: status)
        else
          request,
    ];

    if (selected != null) {
      await _syncRegistrationStatus(selected, status);
    }

    final notices = [
      NoticeItem(
        title: status == AccountStatus.verified
            ? 'Pendaftaran disetujui'
            : 'Pendaftaran ditolak',
        message: selected == null
            ? 'Permintaan pendaftaran sudah diperbarui.'
            : '${selected.fullName} (${roleLabel(selected.role)}) telah ${status == AccountStatus.verified ? 'disetujui' : 'ditolak'}.',
        timeLabel: 'Baru saja',
        icon: status == AccountStatus.verified
            ? Icons.verified_user_rounded
            : Icons.cancel_rounded,
        accent: status == AccountStatus.verified
            ? AppTheme.emerald
            : const Color(0xFFDC2626),
      ),
      ...state.superAdminNotifications,
    ];

    state = state.copyWith(
      registrationRequests: requests,
      accountStatus: selected?.providerApplication == null
          ? state.accountStatus
          : status,
      managedUsers: selected == null || status != AccountStatus.verified
          ? state.managedUsers
          : [
              ManagedUserAccount(
                id: 'usr-${state.managedUsers.length + 1}',
                name: selected.fullName,
                email: selected.email,
                role: selected.role,
                status: UserAccessStatus.active,
                note: 'Akun disetujui melalui verifikasi Super Admin.',
              ),
              ...state.managedUsers,
            ],
      superAdminNotifications: notices,
    );
  }

  Future<void> _syncRegistrationStatus(
    RegistrationRequest selected,
    AccountStatus status,
  ) async {
    final dbStatus = switch (status) {
      AccountStatus.verified => 'verified',
      AccountStatus.rejected => 'rejected',
      AccountStatus.pending => 'pending',
    };

    final rows = await Supabase.instance.client
        .from('profiles')
        .select('id, role')
        .eq('email', selected.email)
        .limit(1);

    if (rows.isEmpty) {
      return;
    }

    final profile = rows.first;
    final profileId = profile['id'] as String;

    await Supabase.instance.client
        .from('profiles')
        .update({
          'account_status': dbStatus,
          'verified_at': status == AccountStatus.verified
              ? DateTime.now().toIso8601String()
              : null,
        })
        .eq('id', profileId);

    if (profile['role'] == 'provider') {
      await Supabase.instance.client
          .from('providers')
          .update({
            'status': dbStatus,
            'approved_by': Supabase.instance.client.auth.currentUser?.id,
            'approved_at': status == AccountStatus.verified
                ? DateTime.now().toIso8601String()
                : null,
            'rejection_reason': status == AccountStatus.rejected
                ? 'Ditolak oleh Super Admin.'
                : null,
          })
          .eq('profile_id', profileId);

      await Supabase.instance.client
          .from('provider_applications')
          .update({
            'status': dbStatus,
            'reviewed_by': Supabase.instance.client.auth.currentUser?.id,
            'reviewed_at': DateTime.now().toIso8601String(),
            'review_note': status == AccountStatus.verified
                ? 'Disetujui oleh Super Admin.'
                : status == AccountStatus.rejected
                ? 'Ditolak oleh Super Admin.'
                : null,
          })
          .eq('profile_id', profileId)
          .eq('status', 'pending');
    }
  }

  Future<void> toggleManagedUserAccess(String id) async {
    ManagedUserAccount? updatedUser;
    final users = [
      for (final user in state.managedUsers)
        if (user.id == id)
          updatedUser = user.copyWith(
            status: user.status == UserAccessStatus.active
                ? UserAccessStatus.suspended
                : UserAccessStatus.active,
            note: user.status == UserAccessStatus.active
                ? 'Dinonaktifkan oleh Super Admin untuk pemeriksaan.'
                : 'Diaktifkan kembali oleh Super Admin.',
          )
        else
          user,
    ];
    if (updatedUser == null) {
      return;
    }

    await _superAdminService.updateUserAccessStatus(
      profileId: updatedUser.id,
      status: updatedUser.status,
    );

    state = state.copyWith(
      managedUsers: users,
      superAdminNotifications: [
        NoticeItem(
          title: updatedUser.status == UserAccessStatus.suspended
              ? 'Akun dinonaktifkan'
              : 'Akun diaktifkan',
          message:
              '${updatedUser.name} (${roleLabel(updatedUser.role)}) sekarang ${userAccessStatusLabel(updatedUser.status).toLowerCase()}.',
          timeLabel: 'Baru saja',
          icon: updatedUser.status == UserAccessStatus.suspended
              ? Icons.block_rounded
              : Icons.check_circle_rounded,
          accent: userAccessStatusColor(updatedUser.status),
        ),
        ...state.superAdminNotifications,
      ],
    );
  }

  Future<void> deleteManagedUserAccount(String id) async {
    ManagedUserAccount? target;
    for (final user in state.managedUsers) {
      if (user.id == id) {
        target = user;
        break;
      }
    }
    if (target == null) {
      return;
    }

    await _superAdminService.deleteManagedUser(id);

    state = state.copyWith(
      managedUsers: [
        for (final user in state.managedUsers)
          if (user.id != id) user,
      ],
      superAdminNotifications: [
        NoticeItem(
          title: 'Akun dihapus',
          message:
              '${target.name} (${roleLabel(target.role)}) sudah dihapus dari Supabase Auth.',
          timeLabel: 'Baru saja',
          icon: Icons.delete_forever_rounded,
          accent: const Color(0xFFDC2626),
        ),
        ...state.superAdminNotifications,
      ],
    );
  }

  Future<void> suspendFirstActiveManagedUser() async {
    final activeUsers = state.managedUsers.where(
      (user) => user.status == UserAccessStatus.active,
    );
    if (activeUsers.isEmpty) {
      return;
    }
    await toggleManagedUserAccess(activeUsers.first.id);
  }

  void prepareSuperAdminReport(String format) {
    state = state.copyWith(
      superAdminNotifications: [
        NoticeItem(
          title: 'Laporan $format siap',
          message:
              'Rekap ${state.history.length} transaksi dan ${state.lots.length} lokasi berhasil disiapkan.',
          timeLabel: 'Baru saja',
          icon: format == 'PDF'
              ? Icons.picture_as_pdf_rounded
              : Icons.table_view_rounded,
          accent: format == 'PDF' ? AppTheme.blue : AppTheme.emerald,
        ),
        ...state.superAdminNotifications,
      ],
    );
  }

  Future<void> answerComplaint(String id, String reply) async {
    await _complaintService.answerComplaint(id: id, reply: reply);
    ComplaintItem? answered;
    final complaints = [
      for (final complaint in state.complaints)
        if (complaint.id == id)
          answered = complaint.copyWith(
            status: ComplaintStatus.answered,
            reply: reply,
          )
        else
          complaint,
    ];
    if (answered == null) {
      return;
    }

    final userNotice = NoticeItem(
      title: 'Komplain dijawab',
      message: '${answered.subject}: $reply',
      timeLabel: 'Baru saja',
      icon: Icons.support_agent_rounded,
      accent: AppTheme.emerald,
    );

    state = state.copyWith(
      complaints: complaints,
      customerNotifications: answered.senderRole == AccountMode.customer
          ? [userNotice, ...state.customerNotifications]
          : state.customerNotifications,
      adminNotifications:
          answered.senderRole == AccountMode.provider ||
              answered.senderRole == AccountMode.parkingGuard
          ? [userNotice, ...state.adminNotifications]
          : state.adminNotifications,
      superAdminNotifications: [
        NoticeItem(
          title: 'Komplain terjawab',
          message: '${answered.senderName} sudah menerima balasan admin super.',
          timeLabel: 'Baru saja',
          icon: Icons.done_all_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.superAdminNotifications,
      ],
    );
  }

  Future<void> closeComplaint(String id) async {
    await _complaintService.closeComplaint(id);
    state = state.copyWith(
      complaints: [
        for (final complaint in state.complaints)
          if (complaint.id == id)
            complaint.copyWith(status: ComplaintStatus.closed)
          else
            complaint,
      ],
    );
  }

  Future<void> updateCustomerProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    await _profileService.updateCurrentUserProfile(
      name: name,
      email: email,
      phone: phone,
    );
    state = state.copyWith(
      userName: state.currentMode == AccountMode.customer
          ? name
          : state.userName,
      email: state.currentMode == AccountMode.customer ? email : state.email,
      phoneNumber: state.currentMode == AccountMode.customer
          ? phone
          : state.phoneNumber,
      customerName: name,
      customerEmail: email,
      customerPhone: phone,
    );
  }

  Future<void> updateRoleProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    await _profileService.updateCurrentUserProfile(
      name: name,
      email: email,
      phone: phone,
    );

    final activeId = state.activeGuardId;
    state = state.copyWith(
      userName: name,
      email: email,
      phoneNumber: phone,
      parkingGuards:
          state.currentMode == AccountMode.parkingGuard && activeId != null
          ? [
              for (final guard in state.parkingGuards)
                if (guard.id == activeId)
                  ParkingGuardAccount(
                    id: guard.id,
                    name: name,
                    email: email,
                    phoneNumber: phone,
                    providerId: guard.providerId,
                    assignedLotIds: guard.assignedLotIds,
                    canScanQr: guard.canScanQr,
                    canConfirmCash: guard.canConfirmCash,
                    canManageSlots: guard.canManageSlots,
                  )
                else
                  guard,
            ]
          : state.parkingGuards,
    );
  }

  Future<void> updateCurrentUserPassword(String password) {
    return _profileService.updateCurrentUserPassword(password);
  }

  Future<void> updateCustomerSettings({
    required bool bookingNotificationEnabled,
    required bool paymentNotificationEnabled,
    required bool promoNotificationEnabled,
    required String selectedLanguage,
    required bool accountSecurityEnabled,
  }) async {
    await _customerSettingsService.saveCurrentCustomerSettings(
      bookingNotificationEnabled: bookingNotificationEnabled,
      paymentNotificationEnabled: paymentNotificationEnabled,
      promoNotificationEnabled: promoNotificationEnabled,
      selectedLanguage: selectedLanguage,
      accountSecurityEnabled: accountSecurityEnabled,
    );

    state = state.copyWith(
      bookingNotificationEnabled: bookingNotificationEnabled,
      paymentNotificationEnabled: paymentNotificationEnabled,
      promoNotificationEnabled: promoNotificationEnabled,
      selectedLanguage: selectedLanguage,
      accountSecurityEnabled: accountSecurityEnabled,
    );
  }

  Future<SupabaseProfileSettings> fetchCurrentProfileSettingsFromSupabase() {
    return _profileSettingsService.fetchCurrentProfileSettings();
  }

  Future<void> updateCurrentProfileSettings({
    required bool primaryNotificationEnabled,
    required bool secondaryNotificationEnabled,
    required bool reportNotificationEnabled,
    required String selectedLanguage,
    required bool accountSecurityEnabled,
  }) {
    return _profileSettingsService.saveCurrentProfileSettings(
      primaryNotificationEnabled: primaryNotificationEnabled,
      secondaryNotificationEnabled: secondaryNotificationEnabled,
      reportNotificationEnabled: reportNotificationEnabled,
      selectedLanguage: selectedLanguage,
      accountSecurityEnabled: accountSecurityEnabled,
    );
  }

  Future<void> updateCustomerAvatar(Uint8List bytes) async {
    await _profileService.uploadCurrentUserAvatar(bytes);
    state = state.copyWith(customerAvatarBytes: bytes);
  }

  Future<void> removeCustomerAvatar() async {
    await _profileService.removeCurrentUserAvatar();
    state = state.copyWith(removeCustomerAvatar: true);
  }

  Future<void> updateRoleAvatar(Uint8List bytes) async {
    await _profileService.uploadCurrentUserAvatar(bytes);
    state = state.copyWith(roleAvatarBytes: bytes);
  }

  Future<void> removeRoleAvatar() async {
    await _profileService.removeCurrentUserAvatar();
    state = state.copyWith(removeRoleAvatar: true);
  }

  Future<void> loadCurrentUserAvatarFromSupabase({
    required bool forCustomer,
  }) async {
    final bytes = await _profileService.fetchCurrentUserAvatarBytes();
    if (forCustomer) {
      state = state.copyWith(
        customerAvatarBytes: bytes,
        removeCustomerAvatar: bytes == null,
      );
      return;
    }

    state = state.copyWith(
      roleAvatarBytes: bytes,
      removeRoleAvatar: bytes == null,
    );
  }

  String createCustomerChatRoom({
    required String id,
    required String title,
    required String participantRole,
    required String participantName,
    String initialMessage = 'Room chat siap digunakan.',
  }) {
    for (final room in state.customerChatRooms) {
      if (room.id == id) {
        return room.id;
      }
    }
    final now = DateTime.now();
    final room = ChatRoom(
      id: id,
      title: title,
      participantRole: participantRole,
      participantName: participantName,
      lastMessage: initialMessage,
      lastMessageAt: now,
      unreadCount: 0,
    );
    state = state.copyWith(
      customerChatRooms: [room, ...state.customerChatRooms],
    );
    return id;
  }

  String createCustomerGuardChatRoomForBooking(Booking booking) {
    return createCustomerChatRoom(
      id: 'customer-guard-${booking.ticketNumber.toLowerCase()}',
      title: 'Chat Penjaga - ${booking.ticketNumber}',
      participantRole: 'Penjaga Parkir',
      participantName: 'Penjaga Parkir - ${booking.locationName}',
      initialMessage: 'Chat terkait tiket ${booking.ticketNumber}.',
    );
  }

  String createCustomerProviderChatRoomForLot(ParkingLot lot) {
    return createCustomerChatRoom(
      id: 'customer-provider-${lot.id}',
      title: 'Chat Penyedia - ${lot.name}',
      participantRole: 'Penyedia Parkir',
      participantName: 'Penyedia - ${lot.name}',
      initialMessage: 'Chat terkait lokasi ${lot.name}.',
    );
  }

  void markCustomerChatAsRead(String roomId) {
    state = state.copyWith(
      customerChatRooms: [
        for (final room in state.customerChatRooms)
          if (room.id == roomId) room.copyWith(unreadCount: 0) else room,
      ],
      customerChatMessages: [
        for (final message in state.customerChatMessages)
          if (message.roomId == roomId)
            message.copyWith(isRead: true)
          else
            message,
      ],
    );
  }

  void sendCustomerMessage({required String roomId, required String message}) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }
    ChatRoom? room;
    for (final item in state.customerChatRooms) {
      if (item.id == roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return;
    }
    final now = DateTime.now();
    final chatMessage = _outgoingMessage(
      roomId: roomId,
      senderRole: 'Customer',
      senderName: state.customerName,
      receiverRole: room.participantRole,
      receiverName: room.participantName,
      message: trimmed,
      createdAt: now,
    );
    _syncChatMessage(
      localRoomId: roomId,
      title: room.title,
      senderMode: AccountMode.customer,
      senderName: state.customerName,
      participantRole: room.participantRole,
      participantName: room.participantName,
      message: trimmed,
    );
    final mirrorRoomId = _mirrorRoomId(AccountMode.customer, roomId);
    state = state.copyWith(
      customerChatMessages: [...state.customerChatMessages, chatMessage],
      customerChatRooms: _touchRoom(
        state.customerChatRooms,
        roomId,
        trimmed,
        now,
      ),
      guardChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? [
              ...state.guardChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.guardChatMessages,
      guardChatRooms: mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? _touchRoom(
              state.guardChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.guardChatRooms,
      providerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? [
              ...state.providerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.providerChatMessages,
      providerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? _touchRoom(
              state.providerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.providerChatRooms,
      superAdminChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? [
              ...state.superAdminChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.superAdminChatMessages,
      superAdminChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? _touchRoom(
              state.superAdminChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.superAdminChatRooms,
    );
  }

  Future<void> submitCustomerComplaint({
    required String title,
    required String category,
    required String description,
    required String priority,
  }) async {
    final now = DateTime.now();
    final remoteComplaint = await _complaintService.submitComplaint(
      senderMode: AccountMode.customer,
      senderName: state.customerName,
      title: title,
      category: category,
      description: description,
      priority: priority,
    );
    final complaint =
        remoteComplaint ??
        Complaint(
          id: 'CUS-CMP-${now.millisecondsSinceEpoch}',
          senderRole: 'Customer',
          senderName: state.customerName,
          title: title,
          category: category,
          description: description,
          priority: priority,
          status: 'Terkirim',
          createdAt: now,
        );
    state = state.copyWith(
      customerComplaints: [complaint, ...state.customerComplaints],
    );
  }

  void selectLot(ParkingLot lot) {
    state = state.copyWith(selectedLot: lot);
  }

  String createGuardChatRoom({
    required String id,
    required String title,
    required String participantRole,
    required String participantName,
    String initialMessage = 'Room chat siap digunakan.',
  }) {
    for (final room in state.guardChatRooms) {
      if (room.id == id) {
        return room.id;
      }
    }
    final now = DateTime.now();
    final room = ChatRoom(
      id: id,
      title: title,
      participantRole: participantRole,
      participantName: participantName,
      lastMessage: initialMessage,
      lastMessageAt: now,
      unreadCount: 0,
    );
    state = state.copyWith(guardChatRooms: [room, ...state.guardChatRooms]);
    return id;
  }

  String createCustomerChatRoomForBooking(Booking booking) {
    return createGuardChatRoom(
      id: 'guard-customer-${booking.ticketNumber.toLowerCase()}',
      title: 'Chat Customer - ${booking.ticketNumber}',
      participantRole: 'Customer',
      participantName: 'Customer ${booking.ticketNumber}',
      initialMessage: 'Chat terkait tiket ${booking.ticketNumber}.',
    );
  }

  void markChatAsRead(String roomId) {
    state = state.copyWith(
      guardChatRooms: [
        for (final room in state.guardChatRooms)
          if (room.id == roomId) room.copyWith(unreadCount: 0) else room,
      ],
      guardChatMessages: [
        for (final message in state.guardChatMessages)
          if (message.roomId == roomId)
            message.copyWith(isRead: true)
          else
            message,
      ],
    );
  }

  void sendGuardMessage({required String roomId, required String message}) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }
    ChatRoom? room;
    for (final item in state.guardChatRooms) {
      if (item.id == roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return;
    }
    final guard = activeGuard(state);
    final now = DateTime.now();
    final chatMessage = _outgoingMessage(
      roomId: roomId,
      senderRole: 'Penjaga Parkir',
      senderName: guard?.name ?? 'Penjaga Parkir',
      receiverRole: room.participantRole,
      receiverName: room.participantName,
      message: trimmed,
      createdAt: now,
    );
    _syncChatMessage(
      localRoomId: roomId,
      title: room.title,
      senderMode: AccountMode.parkingGuard,
      senderName: guard?.name ?? 'Penjaga Parkir',
      participantRole: room.participantRole,
      participantName: room.participantName,
      message: trimmed,
    );
    final mirrorRoomId = _mirrorRoomId(AccountMode.parkingGuard, roomId);
    state = state.copyWith(
      guardChatMessages: [...state.guardChatMessages, chatMessage],
      guardChatRooms: _touchRoom(state.guardChatRooms, roomId, trimmed, now),
      customerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? [
              ...state.customerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.customerChatMessages,
      customerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? _touchRoom(
              state.customerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.customerChatRooms,
      providerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? [
              ...state.providerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.providerChatMessages,
      providerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? _touchRoom(
              state.providerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.providerChatRooms,
      superAdminChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? [
              ...state.superAdminChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.superAdminChatMessages,
      superAdminChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? _touchRoom(
              state.superAdminChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.superAdminChatRooms,
    );
  }

  void markProviderChatAsRead(String roomId) {
    state = state.copyWith(
      providerChatRooms: [
        for (final room in state.providerChatRooms)
          if (room.id == roomId) room.copyWith(unreadCount: 0) else room,
      ],
      providerChatMessages: [
        for (final message in state.providerChatMessages)
          if (message.roomId == roomId)
            message.copyWith(isRead: true)
          else
            message,
      ],
    );
  }

  void sendProviderMessage({required String roomId, required String message}) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }
    ChatRoom? room;
    for (final item in state.providerChatRooms) {
      if (item.id == roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return;
    }
    final now = DateTime.now();
    final chatMessage = _outgoingMessage(
      roomId: roomId,
      senderRole: 'Penyedia Parkir',
      senderName: 'Penyedia - Parkir Plaza Sudirman',
      receiverRole: room.participantRole,
      receiverName: room.participantName,
      message: trimmed,
      createdAt: now,
    );
    _syncChatMessage(
      localRoomId: roomId,
      title: room.title,
      senderMode: AccountMode.provider,
      senderName: 'Penyedia - Parkir Plaza Sudirman',
      participantRole: room.participantRole,
      participantName: room.participantName,
      message: trimmed,
    );
    final mirrorRoomId = _mirrorRoomId(AccountMode.provider, roomId);
    state = state.copyWith(
      providerChatMessages: [...state.providerChatMessages, chatMessage],
      providerChatRooms: _touchRoom(
        state.providerChatRooms,
        roomId,
        trimmed,
        now,
      ),
      customerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? [
              ...state.customerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.customerChatMessages,
      customerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? _touchRoom(
              state.customerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.customerChatRooms,
      guardChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? [
              ...state.guardChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.guardChatMessages,
      guardChatRooms: mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? _touchRoom(
              state.guardChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.guardChatRooms,
      superAdminChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? [
              ...state.superAdminChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.superAdminChatMessages,
      superAdminChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('superadmin-')
          ? _touchRoom(
              state.superAdminChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.superAdminChatRooms,
    );
  }

  void markSuperAdminChatAsRead(String roomId) {
    state = state.copyWith(
      superAdminChatRooms: [
        for (final room in state.superAdminChatRooms)
          if (room.id == roomId) room.copyWith(unreadCount: 0) else room,
      ],
      superAdminChatMessages: [
        for (final message in state.superAdminChatMessages)
          if (message.roomId == roomId)
            message.copyWith(isRead: true)
          else
            message,
      ],
    );
  }

  void sendSuperAdminMessage({
    required String roomId,
    required String message,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }
    ChatRoom? room;
    for (final item in state.superAdminChatRooms) {
      if (item.id == roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return;
    }
    final now = DateTime.now();
    final chatMessage = _outgoingMessage(
      roomId: roomId,
      senderRole: 'Super Admin',
      senderName: 'Admin Super Parkir Cepat',
      receiverRole: room.participantRole,
      receiverName: room.participantName,
      message: trimmed,
      createdAt: now,
    );
    _syncChatMessage(
      localRoomId: roomId,
      title: room.title,
      senderMode: AccountMode.superAdmin,
      senderName: 'Admin Super Parkir Cepat',
      participantRole: room.participantRole,
      participantName: room.participantName,
      message: trimmed,
    );
    final mirrorRoomId = _mirrorRoomId(AccountMode.superAdmin, roomId);
    state = state.copyWith(
      superAdminChatMessages: [...state.superAdminChatMessages, chatMessage],
      superAdminChatRooms: _touchRoom(
        state.superAdminChatRooms,
        roomId,
        trimmed,
        now,
      ),
      customerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? [
              ...state.customerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.customerChatMessages,
      customerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('customer-')
          ? _touchRoom(
              state.customerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.customerChatRooms,
      guardChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? [
              ...state.guardChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.guardChatMessages,
      guardChatRooms: mirrorRoomId != null && mirrorRoomId.startsWith('guard-')
          ? _touchRoom(
              state.guardChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.guardChatRooms,
      providerChatMessages:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? [
              ...state.providerChatMessages,
              _mirrorMessage(chatMessage, mirrorRoomId),
            ]
          : state.providerChatMessages,
      providerChatRooms:
          mirrorRoomId != null && mirrorRoomId.startsWith('provider-')
          ? _touchRoom(
              state.providerChatRooms,
              mirrorRoomId,
              trimmed,
              now,
              unread: true,
            )
          : state.providerChatRooms,
    );
  }

  Future<void> submitGuardComplaint({
    required String title,
    required String category,
    required String description,
    required String priority,
  }) async {
    final guard = activeGuard(state);
    final now = DateTime.now();
    final guardName = guard?.name ?? 'Penjaga Parkir';
    final remoteComplaint = await _complaintService.submitComplaint(
      senderMode: AccountMode.parkingGuard,
      senderName: guardName,
      title: title,
      category: category,
      description: description,
      priority: priority,
    );
    final complaint =
        remoteComplaint ??
        Complaint(
          id: 'CMP-${now.millisecondsSinceEpoch}',
          senderRole: 'Penjaga Parkir',
          senderName: guardName,
          title: title,
          category: category,
          description: description,
          priority: priority,
          status: 'Terkirim',
          createdAt: now,
        );
    state = state.copyWith(
      guardComplaints: [complaint, ...state.guardComplaints],
    );
  }

  Future<void> addLot({
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
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    String lotId = 'lot-${state.lots.length + 1}';
    String providerId = 'provider-main';

    if (user != null) {
      final provider = await Supabase.instance.client
          .from('providers')
          .select('id')
          .eq('profile_id', user.id)
          .single();
      providerId = provider['id'] as String;

      final insertedLot = await Supabase.instance.client
          .from('parking_lots')
          .insert({
            'provider_id': providerId,
            'name': name,
            'address': address,
            'price_per_hour': price,
            'total_slots': capacity,
            'open_hours': '24 Jam',
            'latitude': latitude,
            'longitude': longitude,
            'map_embed_url': mapEmbedUrl,
            'photo_url': null,
            'tariff_type': _tariffTypeToDb(tariffType),
            'motor_rate': motorRate,
            'car_rate': carRate,
            'truck_rate': truckRate,
            'is_active': true,
          })
          .select('id')
          .single();
      lotId = insertedLot['id'] as String;
      if (photoBytes != null) {
        final photoUrl = await _parkingService.uploadCurrentProviderLotPhoto(
          lotId: lotId,
          bytes: photoBytes,
          fileName: photoLabel,
        );
        if (photoUrl != null) {
          await Supabase.instance.client
              .from('parking_lots')
              .update({'photo_url': photoUrl})
              .eq('id', lotId);
          photoLabel = photoUrl;
        }
      }

      await Supabase.instance.client.from('parking_slots').insert([
        for (var index = 1; index <= capacity; index++)
          {
            'parking_lot_id': lotId,
            'label': 'A${index.toString().padLeft(3, '0')}',
            'status': 'available',
          },
      ]);
    }

    final generatedSlots = [
      for (var index = 1; index <= capacity; index++)
        ParkingSlot(
          id: '$lotId-slot-$index',
          label: 'A${index.toString().padLeft(3, '0')}',
          isAvailable: true,
        ),
    ];

    final lot = ParkingLot(
      id: lotId,
      providerId: providerId,
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
    state = state.copyWith(
      lots: [lot, ...state.lots],
      selectedLot: lot,
      slots: generatedSlots,
    );
  }

  String _tariffTypeToDb(ParkingTariffType type) => switch (type) {
    ParkingTariffType.hourly => 'hourly',
    ParkingTariffType.flat => 'flat',
    ParkingTariffType.daily => 'daily',
    ParkingTariffType.progressive => 'progressive',
  };

  Future<void> toggleFavoriteLot(String lotId) async {
    final current = [...state.favoriteLotIds];
    final wasFavorite = current.contains(lotId);
    if (current.contains(lotId)) {
      current.remove(lotId);
    } else {
      current.add(lotId);
    }
    state = state.copyWith(favoriteLotIds: current);

    try {
      if (wasFavorite) {
        await _favoriteService.removeFavoriteLot(lotId);
      } else {
        await _favoriteService.saveFavoriteLot(lotId);
      }
    } catch (_) {
      state = state.copyWith(
        favoriteLotIds: wasFavorite
            ? [...state.favoriteLotIds, lotId]
            : state.favoriteLotIds.where((id) => id != lotId).toList(),
      );
    }
  }

  Future<void> saveVehicle({
    required String plateNumber,
    required VehicleKind kind,
    required int quantity,
    required int durationHours,
  }) async {
    final remoteVehicle = await _vehicleService
        .saveCurrentCustomerVehicle(
          plateNumber: plateNumber,
          kind: kind,
          quantity: quantity,
          durationHours: durationHours,
        )
        .catchError((_) => null);

    final vehicle =
        remoteVehicle ??
        Vehicle(
          id: 'veh-${state.vehicles.length + 1}',
          plateNumber: plateNumber,
          kind: kind,
          quantity: quantity,
          durationHours: durationHours,
        );

    final remainingVehicles = state.vehicles
        .where((item) => item.plateNumber != vehicle.plateNumber)
        .toList();

    state = state.copyWith(
      vehicles: [vehicle, ...remainingVehicles],
      selectedVehicle: vehicle,
    );
  }

  Future<void> createBooking({
    required String slotCode,
    required DateTime entryTime,
  }) async {
    final lot = state.selectedLot ?? state.lots.first;
    final vehicle = state.selectedVehicle ?? state.vehicles.first;
    final selectedSlot = state.slots.firstWhere(
      (slot) => slot.label == slotCode,
      orElse: () => ParkingSlot(
        id: 'slot-${slotCode.toLowerCase()}',
        label: slotCode,
        isAvailable: true,
      ),
    );
    final total = calculateParkingCost(lot, vehicle);
    final remoteBooking = await _bookingService
        .createCurrentCustomerBooking(
          lot: lot,
          slot: selectedSlot,
          vehicle: vehicle,
          entryTime: entryTime,
          estimatedCost: total,
        )
        .catchError((_) => null);
    final ticketNumber =
        remoteBooking?.ticketNumber ?? 'TKT-${1000 + state.history.length}';

    final booking = Booking(
      ticketNumber: ticketNumber,
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
        if (slot.label == slotCode) slot.copyWith(isAvailable: false) else slot,
    ];
    final customerNotice = NoticeItem(
      title: 'Booking berhasil',
      message:
          'Slot $slotCode di ${lot.name} menunggu pembayaran sebelum tiket aktif.',
      timeLabel: 'Baru saja',
      icon: Icons.local_parking_rounded,
      accent: AppTheme.blue,
    );

    state = state.copyWith(
      activeBooking: booking,
      reservationLockedUntil: DateTime.now().add(const Duration(minutes: 15)),
      slots: updatedSlots,
      customerNotifications: [customerNotice, ...state.customerNotifications],
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
    _syncCurrentUserNotification(customerNotice, type: 'booking');
  }

  Future<void> payBooking(PaymentMethod method) async {
    final booking = state.activeBooking;
    if (booking == null) {
      return;
    }
    await _paymentService.payCurrentCustomerBooking(
      booking: booking,
      method: method,
    );
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
    final customerNotice = NoticeItem(
      title: 'Pembayaran demo berhasil',
      message: 'Tiket ${booking.ticketNumber} aktif dari simulasi bayar.',
      timeLabel: 'Baru saja',
      icon: Icons.payments_rounded,
      accent: AppTheme.emerald,
    );
    state = state.copyWith(
      activeBooking: updatedBooking,
      reservationLockedUntil: null,
      history: [transaction, ...state.history],
      customerNotifications: [customerNotice, ...state.customerNotifications],
      adminNotifications: [
        NoticeItem(
          title: 'Pembayaran demo berhasil',
          message:
              '${booking.plateNumber} menyelesaikan simulasi pembayaran parkir.',
          timeLabel: 'Baru saja',
          icon: Icons.verified_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.adminNotifications,
      ],
    );
    _syncCurrentUserNotification(customerNotice, type: 'payment');
  }

  Future<SupabaseGatewayPaymentResult?> createGatewayPayment(
    PaymentMethod method,
  ) async {
    final booking = state.activeBooking;
    if (booking == null) {
      return null;
    }

    return _paymentService.createMidtransPayment(
      booking: booking,
      method: method,
    );
  }

  Booking? bookingByTicketNumber(String ticketNumber) {
    final booking = state.activeBooking;
    if (booking == null || booking.ticketNumber != ticketNumber) {
      return null;
    }
    return booking;
  }

  Future<Booking?> loadBookingByTicketNumberFromSupabase(
    String ticketNumber,
  ) async {
    final localBooking = bookingByTicketNumber(ticketNumber);
    if (localBooking != null) {
      return localBooking;
    }

    final remoteBooking = await _bookingService.fetchBookingByTicketNumber(
      ticketNumber,
    );
    if (remoteBooking == null) {
      return null;
    }

    state = state.copyWith(activeBooking: remoteBooking.booking);
    return remoteBooking.booking;
  }

  Future<bool> verifyVehicleEntry(String ticketNumber) async {
    final booking = bookingByTicketNumber(ticketNumber);
    if (booking == null || !booking.isPaid) {
      return false;
    }
    await _bookingService.checkInBooking(ticketNumber);
    final updatedSlots = [
      for (final slot in state.slots)
        if (slot.label == booking.slotCode)
          slot.copyWith(isAvailable: false)
        else
          slot,
    ];
    final updatedBooking = booking.copyWith(status: BookingStatus.active);
    final activity = TransactionRecord(
      id: 'LOG-IN-${booking.ticketNumber}',
      locationName: booking.locationName,
      plateNumber: booking.plateNumber,
      status: 'Kendaraan masuk',
      total: 0,
      timeLabel: formatDateTime(DateTime.now()),
    );
    state = state.copyWith(
      activeBooking: updatedBooking,
      slots: updatedSlots,
      history: [activity, ...state.history],
      adminNotifications: [
        NoticeItem(
          title: 'Kendaraan masuk',
          message:
              '${booking.plateNumber} diverifikasi masuk di ${booking.locationName}.',
          timeLabel: 'Baru saja',
          icon: Icons.login_rounded,
          accent: AppTheme.emerald,
        ),
        ...state.adminNotifications,
      ],
    );
    return true;
  }

  Future<bool> confirmVehicleExit(String ticketNumber) async {
    final booking = bookingByTicketNumber(ticketNumber);
    if (booking == null || !booking.isPaid) {
      return false;
    }
    await _bookingService.checkOutBooking(ticketNumber);
    final updatedSlots = [
      for (final slot in state.slots)
        if (slot.label == booking.slotCode)
          slot.copyWith(isAvailable: true)
        else
          slot,
    ];
    final updatedBooking = booking.copyWith(status: BookingStatus.completed);
    final activity = TransactionRecord(
      id: 'LOG-OUT-${booking.ticketNumber}',
      locationName: booking.locationName,
      plateNumber: booking.plateNumber,
      status: 'Kendaraan keluar',
      total: 0,
      timeLabel: formatDateTime(DateTime.now()),
    );
    state = state.copyWith(
      activeBooking: updatedBooking,
      slots: updatedSlots,
      reservationLockedUntil: null,
      history: [activity, ...state.history],
      adminNotifications: [
        NoticeItem(
          title: 'Kendaraan keluar',
          message:
              '${booking.plateNumber} keluar dari ${booking.locationName}. Slot ${booking.slotCode} tersedia kembali.',
          timeLabel: 'Baru saja',
          icon: Icons.logout_rounded,
          accent: AppTheme.blue,
        ),
        ...state.adminNotifications,
      ],
    );
    return true;
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
    ParkingSlot? changedSlot;
    final updated = [
      for (final slot in state.slots)
        if (slot.id == id)
          changedSlot = slot.copyWith(isAvailable: !slot.isAvailable)
        else
          slot,
    ];
    state = state.copyWith(slots: updated);

    if (changedSlot != null) {
      unawaited(
        Supabase.instance.client
            .from('parking_slots')
            .update({
              'status': changedSlot.isAvailable ? 'available' : 'occupied',
            })
            .eq('id', changedSlot.id)
            .catchError((_) {}),
      );
    }
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
    final currentCost = calculateParkingCost(lot, vehicle);
    final updatedCost = calculateParkingCost(lot, updatedVehicle);
    state = state.copyWith(
      vehicles: updatedVehicles,
      selectedVehicle: updatedVehicle,
      activeBooking: booking.copyWith(
        estimatedCost: booking.estimatedCost + (updatedCost - currentCost),
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

  @override
  void dispose() {
    _stopRealtimeSubscriptions();
    super.dispose();
  }

  void _stopRealtimeSubscriptions() {
    _parkingSlotRealtimeDebounce?.cancel();
    _notificationRealtimeDebounce?.cancel();

    final channels = [
      _parkingSlotRealtimeChannel,
      _parkingLotRealtimeChannel,
      _notificationRealtimeChannel,
    ];
    for (final channel in channels) {
      if (channel != null) {
        unawaited(Supabase.instance.client.removeChannel(channel));
      }
    }

    _parkingSlotRealtimeChannel = null;
    _parkingLotRealtimeChannel = null;
    _notificationRealtimeChannel = null;
    _notificationRealtimeProfileId = null;
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

int baseRateForVehicle(ParkingLot lot, Vehicle vehicle) {
  return switch (vehicle.kind) {
    VehicleKind.motor => lot.motorRate ?? lot.pricePerHour,
    VehicleKind.mobil => lot.carRate ?? lot.pricePerHour,
    VehicleKind.truk => lot.truckRate ?? lot.pricePerHour,
  };
}

int calculateParkingCost(ParkingLot lot, Vehicle vehicle) {
  final rate = baseRateForVehicle(lot, vehicle);
  final hours = math.max(1, vehicle.durationHours);
  return switch (lot.tariffType) {
    ParkingTariffType.hourly => rate * hours,
    ParkingTariffType.flat => rate,
    ParkingTariffType.daily => rate * math.max(1, (hours / 24).ceil()),
    ParkingTariffType.progressive =>
      rate + (math.max(0, hours - 1) * rate ~/ 2),
  };
}

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

String _bookingStatusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pendingPayment => 'Menunggu Pembayaran',
  BookingStatus.paid => 'Lunas',
  BookingStatus.active => 'Aktif',
  BookingStatus.completed => 'Selesai',
  BookingStatus.cancelled => 'Dibatalkan',
};

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
  late final TextEditingController _passwordController;
  bool _rememberMe = true;
  bool _isLoading = false;
  AccountMode _mode = AccountMode.customer;

  Future<void> _submitLogin() async {
    if (_isLoading) {
      return;
    }

    final controller = ref.read(appControllerProvider.notifier);

    if (_mode == AccountMode.customer) {
      await _submitCustomerLogin(controller);
      return;
    }

    if (_mode == AccountMode.provider) {
      await _submitProviderLogin(controller);
      return;
    }

    if (_mode == AccountMode.superAdmin) {
      await _submitSuperAdminLogin(controller);
      return;
    }

    if (_mode == AccountMode.parkingGuard) {
      await _submitGuardLogin(controller);
      return;
    }

    controller.login(
      mode: _mode,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      rememberMe: _rememberMe,
    );
    context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
  }

  Future<void> _submitCustomerLogin(AppController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage('Email dan password customer wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = authResponse.user;

      if (user == null) {
        _showLoginMessage('Login customer gagal. Coba lagi.');
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, email, role, access_status')
          .eq('id', user.id)
          .single();

      if (profile['role'] != 'customer') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun ini bukan akun customer.');
        return;
      }

      if (profile['access_status'] == 'suspended') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun customer sedang dinonaktifkan.');
        return;
      }

      controller.login(
        mode: AccountMode.customer,
        email: email,
        phoneNumber: _phoneController.text,
        rememberMe: _rememberMe,
      );
      await controller
          .loadCurrentUserAvatarFromSupabase(forCustomer: true)
          .catchError((_) {});
      await controller.loadParkingDataFromSupabase().catchError((_) {});
      await controller.loadCustomerVehiclesFromSupabase().catchError((_) {});
      await controller.loadActiveBookingFromSupabase().catchError((_) {});
      await controller.loadCustomerHistoryFromSupabase().catchError((_) {});
      await controller.loadCustomerFavoritesFromSupabase().catchError((_) {});
      await controller.loadCustomerSettingsFromSupabase().catchError((_) {});
      await controller.loadCurrentUserNotificationsFromSupabase().catchError(
        (_) {},
      );

      if (!mounted) {
        return;
      }
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showLoginMessage(error.message);
    } catch (_) {
      _showLoginMessage(
        'Tidak bisa login customer. Cek email, password, dan koneksi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitProviderLogin(AppController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage('Email dan password penyedia wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = authResponse.user;

      if (user == null) {
        _showLoginMessage('Login penyedia gagal. Coba lagi.');
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, email, role, access_status')
          .eq('id', user.id)
          .single();

      if (profile['role'] != 'provider') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun ini bukan akun penyedia.');
        return;
      }

      if (profile['access_status'] == 'suspended') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun penyedia sedang dinonaktifkan.');
        return;
      }

      final provider = await supabase
          .from('providers')
          .select('status, business_name, business_address')
          .eq('profile_id', user.id)
          .single();
      final status = _accountStatusFromDb(provider['status'] as String?);
      final application = await _providerApplicationForLogin(user.id);

      controller.login(
        mode: AccountMode.provider,
        email: email,
        phoneNumber: _phoneController.text,
        rememberMe: _rememberMe,
        accountStatusOverride: status,
        providerApplication: application,
        clearProviderApplication: application == null,
      );
      await controller
          .loadCurrentUserAvatarFromSupabase(forCustomer: false)
          .catchError((_) {});
      await controller.loadParkingDataFromSupabase().catchError((_) {});
      await controller.loadCurrentUserNotificationsFromSupabase().catchError(
        (_) {},
      );

      if (!mounted) {
        return;
      }
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showLoginMessage(error.message);
    } catch (_) {
      _showLoginMessage(
        'Tidak bisa login penyedia. Cek email, password, dan koneksi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitSuperAdminLogin(AppController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage('Email dan password admin wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = authResponse.user;

      if (user == null) {
        _showLoginMessage('Login admin gagal. Coba lagi.');
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, email, role, account_status, access_status')
          .eq('id', user.id)
          .single();

      if (profile['role'] != 'super_admin') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun ini bukan akun Super Admin.');
        return;
      }

      if (profile['access_status'] == 'suspended') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun Super Admin sedang dinonaktifkan.');
        return;
      }

      controller.login(
        mode: AccountMode.superAdmin,
        email: email,
        phoneNumber: _phoneController.text,
        rememberMe: _rememberMe,
      );
      await controller
          .loadCurrentUserAvatarFromSupabase(forCustomer: false)
          .catchError((_) {});
      await controller.loadComplaintsFromSupabase().catchError((_) {});
      await controller.loadCurrentUserNotificationsFromSupabase().catchError(
        (_) {},
      );

      if (!mounted) {
        return;
      }
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showLoginMessage(error.message);
    } catch (_) {
      _showLoginMessage(
        'Tidak bisa login ke Supabase. Cek email, password, dan koneksi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitGuardLogin(AppController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLoginMessage('Email dan password penjaga wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = authResponse.user;

      if (user == null) {
        _showLoginMessage('Login penjaga gagal. Coba lagi.');
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, email, role, access_status')
          .eq('id', user.id)
          .single();

      if (profile['role'] != 'parking_guard') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun ini bukan akun penjaga.');
        return;
      }

      if (profile['access_status'] == 'suspended') {
        await supabase.auth.signOut();
        _showLoginMessage('Akun penjaga sedang dinonaktifkan.');
        return;
      }

      controller.login(
        mode: AccountMode.parkingGuard,
        email: email,
        phoneNumber: _phoneController.text,
        rememberMe: _rememberMe,
      );
      await controller
          .loadCurrentUserAvatarFromSupabase(forCustomer: false)
          .catchError((_) {});
      await controller.loadParkingDataFromSupabase().catchError((_) {});
      await controller.loadCurrentGuardFromSupabase().catchError((_) {});
      await controller.loadCurrentUserNotificationsFromSupabase().catchError(
        (_) {},
      );

      final guard = activeGuard(ref.read(appControllerProvider));
      if (guard == null) {
        await supabase.auth.signOut();
        _showLoginMessage(
          'Akun penjaga belum dihubungkan oleh penyedia parkir.',
        );
        return;
      }

      if (!mounted) {
        return;
      }
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showLoginMessage(error.message);
    } catch (_) {
      _showLoginMessage(
        'Tidak bisa login penjaga. Cek email, password, dan koneksi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLoginMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<ProviderApplication?> _providerApplicationForLogin(
    String profileId,
  ) async {
    final rows = await Supabase.instance.client
        .from('provider_applications')
        .select(
          'parking_name, address, photo_url, location_label, capacity, identity_document_url',
        )
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return ProviderApplication(
      parkingName: (row['parking_name'] as String?) ?? 'Lahan parkir',
      address: (row['address'] as String?) ?? '-',
      photoLabel: (row['photo_url'] as String?) ?? '-',
      locationLabel: (row['location_label'] as String?) ?? '-',
      capacity: (row['capacity'] as num?)?.toInt() ?? 0,
      identityLabel: (row['identity_document_url'] as String?) ?? '-',
    );
  }

  Future<void> _syncRegistrationStatus(
    RegistrationRequest selected,
    AccountStatus status,
  ) async {
    final dbStatus = switch (status) {
      AccountStatus.verified => 'verified',
      AccountStatus.rejected => 'rejected',
      AccountStatus.pending => 'pending',
    };

    final rows = await Supabase.instance.client
        .from('profiles')
        .select('id, role')
        .eq('email', selected.email)
        .limit(1);

    if (rows.isEmpty) {
      return;
    }

    final profile = rows.first;
    final profileId = profile['id'] as String;

    await Supabase.instance.client
        .from('profiles')
        .update({
          'account_status': dbStatus,
          'verified_at': status == AccountStatus.verified
              ? DateTime.now().toIso8601String()
              : null,
        })
        .eq('id', profileId);

    if (profile['role'] == 'provider') {
      await Supabase.instance.client
          .from('providers')
          .update({
            'status': dbStatus,
            'approved_by': Supabase.instance.client.auth.currentUser?.id,
            'approved_at': status == AccountStatus.verified
                ? DateTime.now().toIso8601String()
                : null,
            'rejection_reason': status == AccountStatus.rejected
                ? 'Ditolak oleh Super Admin.'
                : null,
          })
          .eq('profile_id', profileId);

      await Supabase.instance.client
          .from('provider_applications')
          .update({
            'status': dbStatus,
            'reviewed_by': Supabase.instance.client.auth.currentUser?.id,
            'reviewed_at': DateTime.now().toIso8601String(),
            'review_note': status == AccountStatus.verified
                ? 'Disetujui oleh Super Admin.'
                : status == AccountStatus.rejected
                ? 'Ditolak oleh Super Admin.'
                : null,
          })
          .eq('profile_id', profileId)
          .eq('status', 'pending');
    }
  }

  AccountStatus _accountStatusFromDb(String? value) => switch (value) {
    'verified' => AccountStatus.verified,
    'rejected' => AccountStatus.rejected,
    _ => AccountStatus.pending,
  };

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController(text: state.phoneNumber);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
          if (_mode == AccountMode.customer ||
              _mode == AccountMode.provider ||
              _mode == AccountMode.parkingGuard ||
              _mode == AccountMode.superAdmin) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
          ],
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
            label: _isLoading ? 'Memeriksa...' : 'Masuk',
            icon: Icons.login_rounded,
            onPressed: _isLoading ? null : _submitLogin,
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
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _parkingNameController;
  late final TextEditingController _parkingAddressController;
  late final TextEditingController _parkingPhotoController;
  late final TextEditingController _locationPointController;
  late final TextEditingController _identityController;
  final SupabaseProviderDocumentService _providerDocumentService =
      SupabaseProviderDocumentService();
  AccountMode _mode = AccountMode.customer;
  Uint8List? _identityDocumentBytes;
  String? _identityDocumentName;
  double _providerCapacity = 80;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Dio Pratama');
    _emailController = TextEditingController(text: 'dio@parkircepat.app');
    _phoneController = TextEditingController(text: '+62 812 7788 9911');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parkingNameController.dispose();
    _parkingAddressController.dispose();
    _parkingPhotoController.dispose();
    _locationPointController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  Future<void> _pickIdentityDocument() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _identityDocumentBytes = bytes;
      _identityDocumentName = picked.name;
      _identityController.text = picked.name;
    });
  }

  Future<void> _submitRegister() async {
    if (_isLoading) {
      return;
    }

    if (_mode == AccountMode.customer) {
      await _submitCustomerRegister();
      return;
    }

    if (_mode == AccountMode.provider) {
      await _submitProviderRegister();
      return;
    }

    if (_mode == AccountMode.parkingGuard) {
      await _submitGuardRegister();
      return;
    }

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
      _showRegisterMessage('Akun penyedia sedang menunggu verifikasi admin.');
    }
    final controller = ref.read(appControllerProvider.notifier);
    if (!mounted) {
      return;
    }
    context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
  }

  Future<void> _submitProviderRegister() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final parkingName = _parkingNameController.text.trim();
    final parkingAddress = _parkingAddressController.text.trim();
    final photoLabel = _parkingPhotoController.text.trim();
    final locationLabel = _locationPointController.text.trim();
    final identityLabel = _identityController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        parkingName.isEmpty ||
        parkingAddress.isEmpty) {
      _showRegisterMessage(
        'Nama, email, password, nama tempat, dan alamat wajib diisi.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showRegisterMessage('Konfirmasi password belum sama.');
      return;
    }

    if (password.length < 6) {
      _showRegisterMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'provider'},
      );
      final user = authResponse.user;

      if (user == null) {
        _showRegisterMessage(
          'Pendaftaran penyedia perlu konfirmasi email terlebih dahulu.',
        );
        return;
      }

      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'provider',
        'account_status': 'pending',
        'access_status': 'active',
      });

      var uploadedIdentityUrl = identityLabel;
      if (_identityDocumentBytes != null) {
        uploadedIdentityUrl =
            await _providerDocumentService.uploadIdentityDocument(
              profileId: user.id,
              bytes: _identityDocumentBytes!,
              fileName: _identityDocumentName,
            ) ??
            identityLabel;
      }

      final provider = await supabase
          .from('providers')
          .upsert({
            'profile_id': user.id,
            'business_name': parkingName,
            'business_address': parkingAddress,
            'identity_document_url': uploadedIdentityUrl.isEmpty
                ? null
                : uploadedIdentityUrl,
            'status': 'pending',
          }, onConflict: 'profile_id')
          .select('id')
          .single();

      final providerApplication = ProviderApplication(
        parkingName: parkingName,
        address: parkingAddress,
        photoLabel: photoLabel,
        locationLabel: locationLabel,
        capacity: _providerCapacity.toInt(),
        identityLabel: uploadedIdentityUrl,
      );

      await supabase.from('provider_applications').insert({
        'provider_id': provider['id'],
        'profile_id': user.id,
        'parking_name': parkingName,
        'address': parkingAddress,
        'photo_url': photoLabel.isEmpty ? null : photoLabel,
        'location_label': locationLabel.isEmpty ? null : locationLabel,
        'capacity': _providerCapacity.toInt(),
        'identity_document_url': uploadedIdentityUrl.isEmpty
            ? null
            : uploadedIdentityUrl,
        'status': 'pending',
      });

      ref
          .read(appControllerProvider.notifier)
          .register(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            mode: AccountMode.provider,
            providerApplication: providerApplication,
          );

      _showRegisterMessage('Akun penyedia sedang menunggu verifikasi admin.');

      if (!mounted) {
        return;
      }
      final controller = ref.read(appControllerProvider.notifier);
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showRegisterMessage(error.message);
    } catch (_) {
      _showRegisterMessage(
        'Tidak bisa daftar penyedia. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitCustomerRegister() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showRegisterMessage('Nama, email, dan password wajib diisi.');
      return;
    }

    if (password != confirmPassword) {
      _showRegisterMessage('Konfirmasi password belum sama.');
      return;
    }

    if (password.length < 6) {
      _showRegisterMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'customer'},
      );
      final user = authResponse.user;

      if (user == null) {
        _showRegisterMessage(
          'Pendaftaran customer perlu konfirmasi email terlebih dahulu.',
        );
        return;
      }

      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'customer',
        'account_status': 'verified',
        'access_status': 'active',
        'verified_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('customers').upsert({
        'profile_id': user.id,
      }, onConflict: 'profile_id');

      ref
          .read(appControllerProvider.notifier)
          .register(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            mode: AccountMode.customer,
          );

      final controller = ref.read(appControllerProvider.notifier);
      await controller.loadCustomerVehiclesFromSupabase().catchError((_) {});
      await controller.loadActiveBookingFromSupabase().catchError((_) {});
      await controller.loadCustomerHistoryFromSupabase().catchError((_) {});
      await controller.loadCustomerFavoritesFromSupabase().catchError((_) {});
      await controller.loadCustomerSettingsFromSupabase().catchError((_) {});
      await controller.loadCurrentUserNotificationsFromSupabase().catchError(
        (_) {},
      );

      if (!mounted) {
        return;
      }
      context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
    } on AuthException catch (error) {
      _showRegisterMessage(error.message);
    } catch (_) {
      _showRegisterMessage(
        'Tidak bisa daftar customer. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitGuardRegister() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showRegisterMessage('Nama, email, dan password penjaga wajib diisi.');
      return;
    }

    if (password != confirmPassword) {
      _showRegisterMessage('Konfirmasi password belum sama.');
      return;
    }

    if (password.length < 6) {
      _showRegisterMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'parking_guard'},
      );
      final user = authResponse.user;

      if (user == null) {
        _showRegisterMessage(
          'Pendaftaran penjaga perlu konfirmasi email terlebih dahulu.',
        );
        return;
      }

      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'parking_guard',
        'account_status': 'verified',
        'access_status': 'active',
        'verified_at': DateTime.now().toIso8601String(),
      });

      ref
          .read(appControllerProvider.notifier)
          .register(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            mode: AccountMode.parkingGuard,
          );

      _showRegisterMessage(
        'Akun penjaga dibuat. Minta penyedia menghubungkan email ini ke lokasi parkir.',
      );

      if (!mounted) {
        return;
      }
      context.go('/login');
    } on AuthException catch (error) {
      _showRegisterMessage(error.message);
    } catch (_) {
      _showRegisterMessage(
        'Tidak bisa daftar penjaga. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRegisterMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
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
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Upload KTP / verifikasi identitas',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickIdentityDocument,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(
                      _identityDocumentBytes == null
                          ? 'Pilih dokumen identitas'
                          : 'Ganti dokumen identitas',
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
                  'Daftar sebagai penjaga, lalu minta penyedia menghubungkan email ini ke lokasi parkir.',
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
            label: _isLoading ? 'Mendaftarkan...' : 'Daftar',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: _isLoading ? null : _submitRegister,
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
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email wajib diisi.')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: Uri.base.resolve('/reset-password').toString(),
      );
      ref.read(appControllerProvider.notifier).requestPasswordReset();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link reset password sudah dikirim ke email.'),
        ),
      );
      context.pop();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim link reset password.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle:
          'Masukkan email akun untuk menerima link reset password Supabase.',
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email akun',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _isSending ? 'Mengirim...' : 'Kirim link reset',
            icon: Icons.mark_email_read_rounded,
            onPressed: _isSending ? null : _sendResetEmail,
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key, this.isRecovery = false});

  final bool isRecovery;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Konfirmasi password belum sama.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateCurrentUserPassword(password);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui.')),
      );
      context.pop();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal memperbarui password. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRecovery ? 'Reset password' : 'Ganti password'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderSection(
                  title: 'Password baru',
                  subtitle: widget.isRecovery
                      ? 'Masukkan password baru setelah membuka link reset dari email.'
                      : 'Perbarui password akun yang sedang login.',
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password baru',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi password',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
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
                PrimaryButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan password',
                  icon: Icons.save_rounded,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
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
  bool _isDeleting = false;

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
                  label: _isDeleting ? 'Menghapus...' : 'Hapus akun permanen',
                  icon: Icons.delete_forever_rounded,
                  color: const Color(0xFFDC2626),
                  onPressed: _agree && !_isDeleting
                      ? () async {
                          setState(() => _isDeleting = true);
                          try {
                            await ref
                                .read(appControllerProvider.notifier)
                                .deleteAccount();
                            if (!context.mounted) return;
                            context.go('/login');
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal menghapus akun. Pastikan Edge Function delete-account sudah deploy.',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isDeleting = false);
                            }
                          }
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
                SecondaryButton(
                  label: 'Cek ulang status',
                  icon: Icons.refresh_rounded,
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Silakan login ulang sebagai penyedia.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      final provider = await Supabase.instance.client
                          .from('providers')
                          .select('status')
                          .eq('profile_id', user.id)
                          .single();
                      final updatedStatus = accountStatusFromDb(
                        provider['status'] as String?,
                      );
                      ref
                          .read(appControllerProvider.notifier)
                          .setProviderStatus(updatedStatus);
                      if (!context.mounted) return;
                      if (updatedStatus == AccountStatus.verified) {
                        context.go('/provider/dashboard');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status penyedia sudah diperbarui.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal mengecek status penyedia.'),
                        ),
                      );
                    }
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

class SuperAdminDashboardScreen extends ConsumerStatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  ConsumerState<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends ConsumerState<SuperAdminDashboardScreen> {
  late Future<SupabaseSuperAdminOverview> _overviewFuture;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _overviewFuture = ref
        .read(appControllerProvider.notifier)
        .fetchSuperAdminOverviewFromSupabase();
    Future.microtask(() async {
      try {
        await ref
            .read(appControllerProvider.notifier)
            .loadComplaintsFromSupabase();
      } catch (_) {
        if (mounted) {
          setState(
            () =>
                _loadError = 'Komplain super admin gagal dimuat dari Supabase.',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return SuperAdminShell(
      currentIndex: 0,
      child: FutureBuilder<SupabaseSuperAdminOverview>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          final overview =
              snapshot.data ??
              const SupabaseSuperAdminOverview(
                customerCount: 0,
                providerCount: 0,
                guardCount: 0,
                pendingVerificationCount: 0,
                suspendedUserCount: 0,
                waitingComplaintCount: 0,
                activeLotCount: 0,
                activeVehicleCount: 0,
                totalTransactionCount: 0,
                totalRevenue: 0,
              );
          final overviewError = snapshot.hasError
              ? 'Ringkasan super admin gagal dimuat dari Supabase.'
              : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              const HeaderSection(
                title: 'Super Admin',
                subtitle:
                    'Pantau pengguna, verifikasi akun, laporan lintas lokasi, transaksi, dan komplain.',
              ),
              const SizedBox(height: 18),
              if (overviewError != null || _loadError != null) ...[
                InlineNotice(
                  icon: Icons.wifi_off_rounded,
                  accent: const Color(0xFFD97706),
                  message: [
                    overviewError,
                    _loadError,
                  ].whereType<String>().join(' '),
                ),
                const SizedBox(height: 18),
              ],
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  StatCard(
                    label: 'Pelanggan',
                    value: '${overview.customerCount}',
                    accent: AppTheme.blue,
                    icon: Icons.groups_rounded,
                  ),
                  StatCard(
                    label: 'Penyedia',
                    value: '${overview.providerCount}',
                    accent: AppTheme.emerald,
                    icon: Icons.apartment_rounded,
                  ),
                  StatCard(
                    label: 'Penjaga',
                    value: '${overview.guardCount}',
                    accent: const Color(0xFFD97706),
                    icon: Icons.security_rounded,
                  ),
                  StatCard(
                    label: 'Pending verifikasi',
                    value: '${overview.pendingVerificationCount}',
                    accent: AppTheme.ink,
                    icon: Icons.verified_user_rounded,
                  ),
                  StatCard(
                    label: 'Akun nonaktif',
                    value: '${overview.suspendedUserCount}',
                    accent: const Color(0xFFD97706),
                    icon: Icons.block_rounded,
                  ),
                  StatCard(
                    label: 'Komplain menunggu',
                    value: '${overview.waitingComplaintCount}',
                    accent: AppTheme.blue,
                    icon: Icons.mark_chat_unread_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SectionTitle(
                title: 'Notifikasi super admin',
                action: 'User',
                onTap: () => context.push('/super-admin/users'),
              ),
              const SizedBox(height: 12),
              ...state.superAdminNotifications
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MiniInfoTile(
                        icon: item.icon,
                        iconColor: item.accent,
                        title: item.title,
                        subtitle: '${item.message} - ${item.timeLabel}',
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
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
                      value: '${overview.totalTransactionCount}',
                    ),
                    SummaryRow(
                      label: 'Lokasi parkir aktif',
                      value: '${overview.activeLotCount}',
                    ),
                    SummaryRow(
                      label: 'Kendaraan aktif',
                      value: '${overview.activeVehicleCount}',
                    ),
                    SummaryRow(
                      label: 'Pendapatan tercatat',
                      value: formatCurrency(overview.totalRevenue),
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
                    onTap: () async {
                      final hasActiveUser = ref
                          .read(appControllerProvider)
                          .managedUsers
                          .any(
                            (user) => user.status == UserAccessStatus.active,
                          );
                      try {
                        await ref
                            .read(appControllerProvider.notifier)
                            .suspendFirstActiveManagedUser();
                        if (!context.mounted) return;
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal memperbarui akses di Supabase.',
                            ),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            hasActiveUser
                                ? 'Akun aktif pertama berhasil dinonaktifkan.'
                                : 'Tidak ada akun aktif yang bisa dinonaktifkan.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class SuperAdminUsersScreen extends ConsumerStatefulWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  ConsumerState<SuperAdminUsersScreen> createState() =>
      _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends ConsumerState<SuperAdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadManagedUsersFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          SectionTitle(title: 'Konfirmasi pendaftaran'),
          const SizedBox(height: 12),
          if (state.registrationRequests.isEmpty)
            const InlineNotice(
              icon: Icons.verified_rounded,
              accent: AppTheme.emerald,
              message:
                  'Belum ada permintaan pendaftaran yang perlu dikonfirmasi.',
            )
          else
            ...state.registrationRequests.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RegistrationRequestCard(request: request),
              ),
            ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Kelola akses akun'),
          const SizedBox(height: 12),
          ...state.managedUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ManagedUserAccountCard(user: user),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Ringkasan role'),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.apartment_rounded,
            iconColor: AppTheme.emerald,
            title: 'Penyedia Parkir',
            subtitle:
                '${state.managedUsers.where((user) => user.role == AccountMode.provider && user.status == UserAccessStatus.active).length} akun aktif',
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'Penjaga Parkir',
            subtitle:
                '${state.managedUsers.where((user) => user.role == AccountMode.parkingGuard && user.status == UserAccessStatus.active).length} akun aktif',
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.person_rounded,
            iconColor: AppTheme.blue,
            title: 'Pelanggan',
            subtitle:
                '${state.managedUsers.where((user) => user.role == AccountMode.customer && user.status == UserAccessStatus.active).length} akun aktif',
          ),
        ],
      ),
    );
  }
}

class SuperAdminReportsScreen extends ConsumerStatefulWidget {
  const SuperAdminReportsScreen({super.key});

  @override
  ConsumerState<SuperAdminReportsScreen> createState() =>
      _SuperAdminReportsScreenState();
}

class _SuperAdminReportsScreenState
    extends ConsumerState<SuperAdminReportsScreen> {
  late Future<SupabaseSuperAdminReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ref
        .read(appControllerProvider.notifier)
        .fetchSuperAdminReportFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminShell(
      currentIndex: 2,
      child: FutureBuilder<SupabaseSuperAdminReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final report =
              snapshot.data ??
              const SupabaseSuperAdminReport(transactions: [], chartPoints: []);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              const HeaderSection(
                title: 'Laporan semua lokasi',
                subtitle: 'Transaksi dan performa seluruh lokasi parkir.',
              ),
              const SizedBox(height: 18),
              PremiumCard(
                child: SizedBox(
                  height: 220,
                  child: RevenueChart(points: report.chartPoints),
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
                        ref
                            .read(appControllerProvider.notifier)
                            .prepareSuperAdminReport('PDF');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan PDF Super Admin siap.'),
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
                        ref
                            .read(appControllerProvider.notifier)
                            .prepareSuperAdminReport('Excel');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan Excel Super Admin siap.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (report.transactions.isEmpty)
                const EmptyStateCard(
                  title: 'Belum ada transaksi',
                  body:
                      'Transaksi semua lokasi dari Supabase akan tampil di sini.',
                  actionLabel: 'Kembali',
                  onPressed: _noop,
                )
              else
                ...report.transactions.map(
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
          );
        },
      ),
    );
  }
}

class SuperAdminComplaintsScreen extends ConsumerStatefulWidget {
  const SuperAdminComplaintsScreen({super.key});

  @override
  ConsumerState<SuperAdminComplaintsScreen> createState() =>
      _SuperAdminComplaintsScreenState();
}

class _SuperAdminComplaintsScreenState
    extends ConsumerState<SuperAdminComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadComplaintsFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(appControllerProvider).complaints;
    return SuperAdminShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Komplain pengguna',
            subtitle:
                'Jawab komplain pelanggan, penyedia, dan penjaga dari satu antrian.',
          ),
          const SizedBox(height: 18),
          InlineNotice(
            icon: Icons.notifications_active_rounded,
            accent: AppTheme.blue,
            message:
                '${complaints.where((item) => item.status == ComplaintStatus.waiting).length} komplain menunggu balasan admin super.',
          ),
          const SizedBox(height: 18),
          ...complaints.map(
            (complaint) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ComplaintCard(complaint: complaint),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationRequestCard extends ConsumerWidget {
  const RegistrationRequestCard({super.key, required this.request});

  final RegistrationRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (request.status) {
      AccountStatus.pending => const Color(0xFFD97706),
      AccountStatus.verified => AppTheme.emerald,
      AccountStatus.rejected => const Color(0xFFDC2626),
    };
    final statusLabel = switch (request.status) {
      AccountStatus.pending => 'Menunggu',
      AccountStatus.verified => 'Disetujui',
      AccountStatus.rejected => 'Ditolak',
    };
    final application = request.providerApplication;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleAccent(request.role).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  roleIcon(request.role),
                  color: roleAccent(request.role),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${roleLabel(request.role)} - ${request.timeLabel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          SummaryRow(label: 'Email', value: request.email),
          SummaryRow(label: 'Nomor HP', value: request.phoneNumber),
          if (application != null) ...[
            SummaryRow(label: 'Lokasi parkir', value: application.parkingName),
            SummaryRow(
              label: 'Kapasitas',
              value: '${application.capacity} slot',
            ),
          ],
          if (request.status == AccountStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Tolak',
                    icon: Icons.close_rounded,
                    onPressed: () async {
                      try {
                        await ref
                            .read(appControllerProvider.notifier)
                            .updateRegistrationStatus(
                              request.id,
                              AccountStatus.rejected,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengajuan penyedia ditolak.'),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal memperbarui status di Supabase.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Setujui',
                    icon: Icons.verified_user_rounded,
                    onPressed: () async {
                      try {
                        await ref
                            .read(appControllerProvider.notifier)
                            .updateRegistrationStatus(
                              request.id,
                              AccountStatus.verified,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengajuan penyedia disetujui.'),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal memperbarui status di Supabase.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ManagedUserAccountCard extends ConsumerWidget {
  const ManagedUserAccountCard({super.key, required this.user});

  final ManagedUserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuspended = user.status == UserAccessStatus.suspended;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleAccent(user.role).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(roleIcon(user.role), color: roleAccent(user.role)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${roleLabel(user.role)} - ${user.email}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slate,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: userAccessStatusLabel(user.status),
                color: userAccessStatusColor(user.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.slate,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Hapus akun',
                  icon: Icons.delete_forever_rounded,
                  onPressed: () => _confirmDeleteManagedUser(
                    context: context,
                    ref: ref,
                    user: user,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: isSuspended ? 'Aktifkan' : 'Nonaktifkan',
                  icon: isSuspended
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  color: isSuspended
                      ? AppTheme.emerald
                      : const Color(0xFFDC2626),
                  onPressed: () async {
                    try {
                      await ref
                          .read(appControllerProvider.notifier)
                          .toggleManagedUserAccess(user.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSuspended
                                ? 'Akun berhasil diaktifkan kembali.'
                                : 'Akun berhasil dinonaktifkan.',
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal memperbarui akses di Supabase.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteManagedUser({
  required BuildContext context,
  required WidgetRef ref,
  required ManagedUserAccount user,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus akun?'),
      content: Text(
        'Akun ${user.name} (${user.email}) akan dihapus dari Supabase Auth. Tindakan ini tidak bisa dibatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  try {
    await ref
        .read(appControllerProvider.notifier)
        .deleteManagedUserAccount(user.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Akun ${user.email} berhasil dihapus.')),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Gagal menghapus akun. Pastikan Edge Function admin-delete-user sudah deploy.',
        ),
      ),
    );
  }
}

class ComplaintCard extends ConsumerWidget {
  const ComplaintCard({super.key, required this.complaint});

  final ComplaintItem complaint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleAccent(
                    complaint.senderRole,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  roleIcon(complaint.senderRole),
                  color: roleAccent(complaint.senderRole),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.subject,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${complaint.senderName} - ${roleLabel(complaint.senderRole)} - ${complaint.timeLabel}',
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
          Text(
            complaint.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.slate,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          StatusBadge(
            label: complaintStatusLabel(complaint.status),
            color: complaintStatusColor(complaint.status),
          ),
          if (complaint.reply != null) ...[
            const SizedBox(height: 14),
            InlineNotice(
              icon: Icons.reply_rounded,
              accent: AppTheme.emerald,
              message: complaint.reply!,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Tutup',
                  icon: Icons.done_all_rounded,
                  onPressed: complaint.status == ComplaintStatus.closed
                      ? null
                      : () async {
                          await ref
                              .read(appControllerProvider.notifier)
                              .closeComplaint(complaint.id);
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Balas',
                  icon: Icons.reply_rounded,
                  onPressed: complaint.status == ComplaintStatus.closed
                      ? null
                      : () =>
                            _showComplaintReplyDialog(context, ref, complaint),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showComplaintReplyDialog(
  BuildContext context,
  WidgetRef ref,
  ComplaintItem complaint,
) async {
  final controller = TextEditingController(
    text:
        complaint.reply ??
        'Terima kasih atas laporannya. Tim Parkir Cepat sudah menindaklanjuti dan status akan diperbarui.',
  );
  final reply = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Balas komplain'),
      content: TextField(
        controller: controller,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Jawaban admin super',
          prefixIcon: Icon(Icons.support_agent_rounded),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(controller.text),
          icon: const Icon(Icons.send_rounded),
          label: const Text('Kirim'),
        ),
      ],
    ),
  );
  controller.dispose();

  if (reply == null || reply.trim().isEmpty) {
    return;
  }
  await ref
      .read(appControllerProvider.notifier)
      .answerComplaint(complaint.id, reply.trim());
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Balasan komplain berhasil dikirim.')),
    );
  }
}

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isRefreshing = false;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshDashboardData);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchParkingLots(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      ref
          .read(appControllerProvider.notifier)
          .searchParkingLotsFromSupabase(value)
          .catchError((_) {});
    });
  }

  Future<void> _refreshDashboardData() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });
    final controller = ref.read(appControllerProvider.notifier);
    final failures = <String>[];
    await _runRefreshStep(
      failures,
      'lokasi parkir',
      controller.loadParkingDataFromSupabase,
    );
    await _runRefreshStep(
      failures,
      'kendaraan',
      controller.loadCustomerVehiclesFromSupabase,
    );
    await _runRefreshStep(
      failures,
      'booking aktif',
      controller.loadActiveBookingFromSupabase,
    );
    await _runRefreshStep(
      failures,
      'riwayat',
      controller.loadCustomerHistoryFromSupabase,
    );
    await _runRefreshStep(
      failures,
      'favorit',
      controller.loadCustomerFavoritesFromSupabase,
    );
    await _runRefreshStep(
      failures,
      'notifikasi',
      controller.loadCurrentUserNotificationsFromSupabase,
    );

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _refreshError = failures.isEmpty
            ? null
            : 'Sebagian data gagal dimuat: ${failures.join(', ')}. Cek koneksi lalu tarik untuk refresh.';
      });
    }
  }

  Future<void> _runRefreshStep(
    List<String> failures,
    String label,
    Future<void> Function() load,
  ) async {
    try {
      await load();
    } catch (_) {
      failures.add(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    void openLotDetail(ParkingLot lot) {
      ref.read(appControllerProvider.notifier).selectLot(lot);
      context.push('/customer/parking-detail');
    }

    void startBooking(ParkingLot lot) {
      ref.read(appControllerProvider.notifier).selectLot(lot);
      context.push('/customer/booking');
    }

    final lots = state.lots;
    final activeBooking = state.activeBooking;
    final totalAvailableSlots = lots.fold<int>(
      0,
      (total, lot) => total + lot.availableSlots,
    );
    final customerFirstName = state.customerName.trim().isEmpty
        ? state.userName.split(' ').first
        : state.customerName.trim().split(' ').first;

    if (lots.isEmpty) {
      return CustomerShell(
        currentIndex: 0,
        child: RefreshIndicator(
          onRefresh: _refreshDashboardData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              HeaderSection(
                title: 'Halo, $customerFirstName',
                subtitle: _isRefreshing
                    ? 'Memuat lokasi parkir dari Supabase...'
                    : 'Data lokasi parkir belum tersedia.',
                trailing: _CustomerDashboardAvatar(
                  bytes: state.customerAvatarBytes,
                ),
              ),
              const SizedBox(height: 18),
              EmptyStateCard(
                title: 'Belum ada lokasi parkir',
                body:
                    'Lokasi parkir akan tampil di sini setelah data Supabase tersedia.',
                actionLabel: 'Muat ulang',
                onPressed: _refreshDashboardData,
              ),
            ],
          ),
        ),
      );
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
            title: 'Halo, $customerFirstName',
            subtitle: _isRefreshing
                ? 'Menyinkronkan dashboard dari Supabase...'
                : '$totalAvailableSlots slot tersedia dari ${lots.length} lokasi',
            trailing: _CustomerDashboardAvatar(
              bytes: state.customerAvatarBytes,
            ),
          ),
          const SizedBox(height: 18),
          if (activeBooking != null) ...[
            PremiumCard(
              accent: AppTheme.blueSoft,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: AppTheme.blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking aktif ${activeBooking.ticketNumber}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${activeBooking.locationName} • ${activeBooking.slotCode}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.slate),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/customer/tickets'),
                    child: const Text('Lihat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (_refreshError != null) ...[
            InlineNotice(
              icon: Icons.wifi_off_rounded,
              accent: const Color(0xFFD97706),
              message: _refreshError!,
            ),
            const SizedBox(height: 18),
          ],
          SearchField(
            label: 'Cari lokasi parkir, mall, kantor',
            controller: _searchController,
            onChanged: _searchParkingLots,
          ),
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
    final selectedLot = state.lots.any((lot) => lot.id == state.selectedLot?.id)
        ? state.selectedLot!
        : state.lots.first;
    return CustomerShell(
      currentIndex: 1,
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
          SectionTitle(title: 'Daftar lokasi parkir'),
          const SizedBox(height: 12),
          ...state.lots.map(
            (lot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomerMapLotCard(
                lot: lot,
                selected: lot.id == selectedLot.id,
                onTap: () {
                  ref.read(appControllerProvider.notifier).selectLot(lot);
                },
                onDetail: () {
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

class _CustomerDashboardAvatar extends StatelessWidget {
  const _CustomerDashboardAvatar({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppTheme.blueSoft,
      backgroundImage: bytes == null ? null : MemoryImage(bytes!),
      child: bytes == null
          ? const Icon(Icons.person_rounded, color: AppTheme.blue)
          : null,
    );
  }
}

class _CustomerMapLotCard extends StatelessWidget {
  const _CustomerMapLotCard({
    required this.lot,
    required this.selected,
    required this.onTap,
    required this.onDetail,
  });

  final ParkingLot lot;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        accent: selected ? AppTheme.blueSoft : null,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: lot.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.near_me_rounded, color: lot.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lot.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? AppTheme.blue : AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ETA ${lot.etaMinutes} menit • ${lot.availableSlots}/${lot.totalSlots} slot • ${lot.distanceKm} km',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.slate,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(onPressed: onDetail, child: const Text('Detail')),
          ],
        ),
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
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Chat Penyedia',
                        icon: Icons.chat_bubble_rounded,
                        onPressed: () {
                          final roomId = ref
                              .read(appControllerProvider.notifier)
                              .createCustomerProviderChatRoomForLot(lot);
                          context.push('/customer/chat-room?roomId=$roomId');
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
  bool _isSaving = false;

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
                  label: _isSaving ? 'Menyimpan...' : 'Simpan kendaraan',
                  icon: Icons.save_rounded,
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final plateNumber = _plateController.text.trim();
                          if (plateNumber.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plat nomor wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          setState(() => _isSaving = true);
                          try {
                            await ref
                                .read(appControllerProvider.notifier)
                                .saveVehicle(
                                  plateNumber: plateNumber,
                                  kind: _kind,
                                  quantity: _quantity.toInt(),
                                  durationHours: _duration.toInt(),
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kendaraan berhasil disimpan.'),
                              ),
                            );
                            context.pop();
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal menyimpan kendaraan ke Supabase.',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
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
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final lot = state.selectedLot ?? state.lots.first;
    final vehicle = state.selectedVehicle ?? state.vehicles.first;
    final total = calculateParkingCost(lot, vehicle);
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
                  label: _isBooking
                      ? 'Membuat booking...'
                      : 'Konfirmasi booking',
                  icon: Icons.check_circle_rounded,
                  onPressed: _selectedSlot == null || _isBooking
                      ? null
                      : () async {
                          setState(() => _isBooking = true);
                          try {
                            await ref
                                .read(appControllerProvider.notifier)
                                .createBooking(
                                  slotCode: _selectedSlot!,
                                  entryTime: _entryTime,
                                );
                            if (!context.mounted) return;
                            context.go('/customer/payment');
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal membuat booking ke Supabase.',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isBooking = false);
                            }
                          }
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
          if (booking == null || !booking.canShowTicket)
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
                      data: 'PARKIRCEPAT|ENTRY_EXIT|${booking.ticketNumber}',
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
                  PrimaryButton(
                    label: 'Chat Penjaga',
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () {
                      final roomId = ref
                          .read(appControllerProvider.notifier)
                          .createCustomerGuardChatRoomForBooking(booking);
                      context.push('/customer/chat-room?roomId=$roomId');
                    },
                  ),
                  const SizedBox(height: 12),
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
  String _wallet = 'GoPay';
  late final TextEditingController _walletPhoneController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardNameController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  String? _paymentError;
  bool _isStartingGateway = false;

  @override
  void initState() {
    super.initState();
    _walletPhoneController = TextEditingController();
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

  Future<void> _completePayment(Booking booking) async {
    await ref.read(appControllerProvider.notifier).payBooking(_method);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PaymentSuccessDialog(
        ticketNumber: booking.ticketNumber,
        total: booking.estimatedCost,
        method: _method,
      ),
    );
  }

  Future<void> _payWithEWallet(Booking _) async {
    setState(() => _paymentError = null);
    await _startGatewayPayment();
  }

  Future<void> _payWithCard(Booking _) async {
    setState(() => _paymentError = null);
    await _startGatewayPayment();
  }

  void _requestCashPaymentConfirmation(Booking booking) {
    final roomId = ref
        .read(appControllerProvider.notifier)
        .createCustomerGuardChatRoomForBooking(booking);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Minta penjaga konfirmasi pembayaran tunai di lokasi.'),
      ),
    );
    context.push('/customer/chat-room?roomId=$roomId');
  }

  Future<void> _startGatewayPayment() async {
    if (_isStartingGateway) {
      return;
    }

    setState(() {
      _isStartingGateway = true;
      _paymentError = null;
    });

    try {
      final result = await ref
          .read(appControllerProvider.notifier)
          .createGatewayPayment(_method);
      if (!mounted) {
        return;
      }
      final redirectUrl = result?.redirectUrl;
      if (redirectUrl == null || redirectUrl.isEmpty) {
        setState(
          () => _paymentError =
              'Payment gateway belum aktif. Deploy Edge Function dan isi secret Midtrans dulu.',
        );
        return;
      }

      final opened = await launchUrl(
        Uri.parse(redirectUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        setState(
          () => _paymentError =
              'Tidak bisa membuka halaman pembayaran. Coba lagi nanti.',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _paymentError =
            'Payment gateway belum siap atau koneksi bermasalah. Detail: $error',
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingGateway = false);
      }
    }
  }

  void _useDemoCard() {
    setState(() {
      _paymentError = null;
      _cardNumberController.text = '4111111111111111';
      _cardNameController.text = 'Dio Pratama';
      _cardExpiryController.text = '12/30';
      _cardCvvController.text = '123';
    });
  }

  Future<void> _handlePayPressed(Booking booking) async {
    switch (_method) {
      case PaymentMethod.qris:
        setState(() => _paymentError = null);
        await _startGatewayPayment();
      case PaymentMethod.cash:
        setState(() => _paymentError = null);
        _requestCashPaymentConfirmation(booking);
      case PaymentMethod.ewallet:
        await _payWithEWallet(booking);
      case PaymentMethod.card:
        await _payWithCard(booking);
    }
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
    final isPayable = booking.status == BookingStatus.pendingPayment;
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran parkir')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            accent: AppTheme.blueSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.blue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Booking',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bookingStatusLabel(booking.status),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SummaryRow(label: 'Nama lokasi', value: booking.locationName),
                SummaryRow(label: 'Slot', value: booking.slotCode),
                SummaryRow(label: 'Plat kendaraan', value: booking.plateNumber),
                SummaryRow(
                  label: 'Jenis kendaraan',
                  value: booking.vehicleLabel,
                ),
                SummaryRow(
                  label: 'Durasi',
                  value: '${_durationHoursFor(state, booking)} jam',
                ),
                SummaryRow(
                  label: 'Total pembayaran',
                  value: formatCurrency(booking.estimatedCost),
                  valueColor: AppTheme.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
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
                  onChanged: isPayable
                      ? (value) => setState(() {
                          _method = value;
                          _paymentError = null;
                        })
                      : (_) {},
                ),
                const SizedBox(height: 14),
                const InlineNotice(
                  icon: Icons.lock_rounded,
                  accent: AppTheme.blue,
                  message:
                      'QRIS, e-wallet, dan kartu memakai payment gateway setelah Edge Function Midtrans dideploy. Tunai tetap dikonfirmasi penjaga.',
                ),
                const SizedBox(height: 20),
                _PaymentInstructionCard(
                  method: _method,
                  booking: booking,
                  wallet: _wallet,
                  walletPhoneController: _walletPhoneController,
                  cardNumberController: _cardNumberController,
                  cardNameController: _cardNameController,
                  cardExpiryController: _cardExpiryController,
                  cardCvvController: _cardCvvController,
                  onWalletChanged: (value) => setState(() => _wallet = value),
                  onUseDemoCard: _useDemoCard,
                ),
                if (_paymentError != null) ...[
                  const SizedBox(height: 12),
                  InlineNotice(
                    icon: Icons.error_outline_rounded,
                    accent: const Color(0xFFDC2626),
                    message: _paymentError!,
                  ),
                ],
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
                  label: _isStartingGateway
                      ? 'Membuka gateway...'
                      : _method == PaymentMethod.cash
                      ? 'Hubungi penjaga'
                      : 'Bayar lewat gateway',
                  icon: _method == PaymentMethod.cash
                      ? Icons.support_agent_rounded
                      : Icons.open_in_new_rounded,
                  onPressed: isPayable
                      ? _isStartingGateway
                            ? null
                            : () => _handlePayPressed(booking)
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

int _hourlyRateFor(AppState state, Booking booking) {
  for (final lot in state.lots) {
    if (lot.name == booking.locationName) {
      return lot.pricePerHour;
    }
  }
  return state.selectedLot?.pricePerHour ?? state.lots.first.pricePerHour;
}

int _durationHoursFor(AppState state, Booking booking) {
  final rate = math.max(1, _hourlyRateFor(state, booking));
  return math.max(1, booking.estimatedCost ~/ rate);
}

class _PaymentInstructionCard extends StatelessWidget {
  const _PaymentInstructionCard({
    required this.method,
    required this.booking,
    required this.wallet,
    required this.walletPhoneController,
    required this.cardNumberController,
    required this.cardNameController,
    required this.cardExpiryController,
    required this.cardCvvController,
    required this.onWalletChanged,
    required this.onUseDemoCard,
  });

  final PaymentMethod method;
  final Booking booking;
  final String wallet;
  final TextEditingController walletPhoneController;
  final TextEditingController cardNumberController;
  final TextEditingController cardNameController;
  final TextEditingController cardExpiryController;
  final TextEditingController cardCvvController;
  final ValueChanged<String> onWalletChanged;
  final VoidCallback onUseDemoCard;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (method) {
        PaymentMethod.qris => _PaymentMethodBox(
          key: const ValueKey('qris'),
          icon: Icons.qr_code_2_rounded,
          title: 'QRIS Gateway',
          subtitle:
              'Tekan tombol bayar untuk membuka halaman Midtrans. Status tiket aktif setelah webhook pembayaran diterima.',
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data:
                    'DEMO-PARKIRCEPAT-PAY|${booking.ticketNumber}|${booking.estimatedCost}',
                size: 150,
                eyeStyle: const QrEyeStyle(color: AppTheme.blue),
              ),
            ),
          ),
        ),
        PaymentMethod.ewallet => _PaymentMethodBox(
          key: const ValueKey('ewallet'),
          icon: Icons.account_balance_wallet_rounded,
          title: 'E-Wallet Gateway',
          subtitle:
              'Pilih dompet digital untuk catatan metode, lalu lanjutkan pembayaran di halaman Midtrans.',
          child: Column(
            children: [
              SegmentedChoice<String>(
                items: const [
                  ChoiceItem(
                    value: 'GoPay',
                    label: 'GoPay',
                    icon: Icons.wallet,
                  ),
                  ChoiceItem(value: 'OVO', label: 'OVO', icon: Icons.wallet),
                  ChoiceItem(value: 'DANA', label: 'DANA', icon: Icons.wallet),
                ],
                value: wallet,
                onChanged: onWalletChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: walletPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor HP demo $wallet',
                  prefixIcon: const Icon(Icons.phone_iphone_rounded),
                ),
              ),
            ],
          ),
        ),
        PaymentMethod.cash => _PaymentMethodBox(
          key: const ValueKey('cash'),
          icon: Icons.payments_rounded,
          title: 'Tunai di Loket',
          subtitle:
              'Customer tidak bisa melunasi tunai sendiri. Hubungi penjaga, lalu penjaga yang berwenang mengonfirmasi pembayaran di aplikasi.',
          child: const InlineNotice(
            icon: Icons.support_agent_rounded,
            accent: AppTheme.emerald,
            message:
                'Siapkan uang tunai sesuai total pembayaran dan tunjukkan tiket ke penjaga parkir.',
          ),
        ),
        PaymentMethod.card => _PaymentMethodBox(
          key: const ValueKey('card'),
          icon: Icons.credit_card_rounded,
          title: 'Debit/Kredit Gateway',
          subtitle:
              'Data kartu asli tidak disimpan aplikasi. Pembayaran kartu diproses di halaman gateway.',
          child: Column(
            children: [
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor kartu demo',
                  prefixIcon: Icon(Icons.credit_card_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama di kartu demo',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cardExpiryController,
                      decoration: const InputDecoration(labelText: 'MM/YY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cardCvvController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Gunakan kartu demo',
                icon: Icons.auto_fix_high_rounded,
                onPressed: onUseDemoCard,
              ),
            ],
          ),
        ),
      },
    );
  }
}

class _PaymentMethodBox extends StatelessWidget {
  const _PaymentMethodBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blueSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.slate,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
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
            width: 72,
            height: 72,
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
            'Pembayaran demo berhasil',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          SummaryRow(label: 'Nomor tiket', value: ticketNumber),
          SummaryRow(label: 'Total bayar', value: formatCurrency(total)),
          SummaryRow(label: 'Metode', value: _paymentMethodLabel(method)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.blueSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: 'PARKIRCEPAT|ENTRY_EXIT|$ticketNumber',
              size: 150,
              eyeStyle: const QrEyeStyle(color: AppTheme.blue),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'QR demo ini dipakai untuk scan masuk dan keluar oleh penjaga parkir.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.go('/customer/tickets');
          },
          child: const Text('Lihat Tiket QR'),
        ),
      ],
    );
  }
}

String _paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.qris => 'QRIS',
  PaymentMethod.ewallet => 'E-Wallet',
  PaymentMethod.cash => 'Tunai',
  PaymentMethod.card => 'Debit/Kredit',
};

class ParkingHistoryScreen extends ConsumerStatefulWidget {
  const ParkingHistoryScreen({super.key});

  @override
  ConsumerState<ParkingHistoryScreen> createState() =>
      _ParkingHistoryScreenState();
}

class _ParkingHistoryScreenState extends ConsumerState<ParkingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadCustomerHistoryFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      if (item.id.startsWith('TKT-')) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () => _showReviewDialog(context, item),
                            icon: const Icon(Icons.star_rounded),
                            label: const Text('Beri review'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    TransactionRecord item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ParkingReviewDialog(transaction: item),
    );
  }
}

class _ParkingReviewDialog extends ConsumerStatefulWidget {
  const _ParkingReviewDialog({required this.transaction});

  final TransactionRecord transaction;

  @override
  ConsumerState<_ParkingReviewDialog> createState() =>
      _ParkingReviewDialogState();
}

class _ParkingReviewDialogState extends ConsumerState<_ParkingReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(appControllerProvider.notifier)
          .submitParkingReview(
            ticketNumber: widget.transaction.id,
            rating: _rating,
            comment: _commentController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review berhasil dikirim')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal mengirim review. Review untuk tiket ini mungkin sudah ada.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review ${widget.transaction.locationName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var index = 1; index <= 5; index++)
                IconButton(
                  tooltip: '$index bintang',
                  onPressed: () => setState(() => _rating = index),
                  icon: Icon(
                    index <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFD97706),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan review',
              prefixIcon: Icon(Icons.rate_review_outlined),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: const Icon(Icons.send_rounded),
          label: Text(_isSaving ? 'Mengirim...' : 'Kirim'),
        ),
      ],
    );
  }
}

class CustomerChatListScreen extends ConsumerWidget {
  const CustomerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    ChatRoom? roomById(String id) {
      for (final room in state.customerChatRooms) {
        if (room.id == id) {
          return room;
        }
      }
      return null;
    }

    final guardRoom = roomById('customer-guard-tkt-1002');
    final providerRoom = roomById('customer-provider-lot-1');
    final adminRoom = roomById('customer-admin-app');
    return CustomerShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Chat Pelanggan',
            subtitle:
                'Hubungi penjaga, penyedia parkir, atau laporkan masalah aplikasi.',
          ),
          const SizedBox(height: 18),
          if (guardRoom != null)
            _CustomerChatCategoryCard(
              room: guardRoom,
              icon: Icons.security_rounded,
              accent: AppTheme.blue,
              onTap: () =>
                  context.push('/customer/chat-room?roomId=${guardRoom.id}'),
            ),
          if (providerRoom != null)
            _CustomerChatCategoryCard(
              room: providerRoom,
              icon: Icons.apartment_rounded,
              accent: AppTheme.emerald,
              onTap: () =>
                  context.push('/customer/chat-room?roomId=${providerRoom.id}'),
            ),
          if (adminRoom != null)
            _CustomerChatCategoryCard(
              room: adminRoom,
              icon: Icons.support_agent_rounded,
              accent: const Color(0xFFD97706),
              actionLabel: 'Buka chat',
              onTap: () =>
                  context.push('/customer/chat-room?roomId=${adminRoom.id}'),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/customer/complaint'),
            icon: const Icon(Icons.report_problem_rounded),
            label: const Text('Buat Komplain ke Admin Aplikasi'),
          ),
          if (state.customerComplaints.isNotEmpty) ...[
            const SizedBox(height: 22),
            SectionTitle(title: 'Riwayat komplain'),
            const SizedBox(height: 12),
            ...state.customerComplaints
                .take(3)
                .map(
                  (complaint) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  complaint.title,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              StatusBadge(
                                label: complaint.status,
                                color: AppTheme.emerald,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${complaint.category} - Prioritas ${complaint.priority}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.slate, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class CustomerChatRoomScreen extends ConsumerStatefulWidget {
  const CustomerChatRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<CustomerChatRoomScreen> createState() =>
      _CustomerChatRoomScreenState();
}

class _CustomerChatRoomScreenState
    extends ConsumerState<CustomerChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.roomId.isNotEmpty) {
        ref
            .read(appControllerProvider.notifier)
            .markCustomerChatAsRead(widget.roomId);
        _loadAndWatchMessages();
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAndWatchMessages() async {
    final controller = ref.read(appControllerProvider.notifier);
    await controller
        .loadChatMessagesFromSupabase(
          mode: AccountMode.customer,
          roomId: widget.roomId,
        )
        .catchError((_) {});
    final stream = await controller
        .watchChatMessagesFromSupabase(roomId: widget.roomId)
        .catchError((_) => const Stream<List<ChatMessage>>.empty());
    _chatSubscription?.cancel();
    _chatSubscription = stream.listen((messages) {
      if (!mounted) {
        return;
      }
      ref
          .read(appControllerProvider.notifier)
          .replaceChatMessagesFromSupabase(
            mode: AccountMode.customer,
            roomId: widget.roomId,
            messages: messages,
          );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    ref
        .read(appControllerProvider.notifier)
        .sendCustomerMessage(roomId: widget.roomId, message: text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    ChatRoom? room;
    for (final item in state.customerChatRooms) {
      if (item.id == widget.roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return CustomerShell(
        currentIndex: 3,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            EmptyStateCard(
              title: 'Room chat tidak ditemukan',
              body: 'Pilih room chat dari daftar Chat Pelanggan.',
              actionLabel: 'Kembali ke Chat',
              onPressed: () => context.go('/customer/chat'),
            ),
          ],
        ),
      );
    }

    final messages =
        state.customerChatMessages
            .where((message) => message.roomId == room!.id)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return CustomerShell(
      currentIndex: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/customer/chat'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _customerChatAccent(
                      room.participantRole,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _customerChatIcon(room.participantRole),
                    color: _customerChatAccent(room.participantRole),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${room.participantRole} - ${room.participantName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _CustomerChatBubble(
                  message: message,
                  isMine: message.senderRole == 'Customer',
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.14))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(Icons.send_rounded),
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

class RoleChatListScreen extends ConsumerWidget {
  const RoleChatListScreen({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
  });

  final AccountMode mode;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final rooms = switch (mode) {
      AccountMode.provider => state.providerChatRooms,
      AccountMode.superAdmin => state.superAdminChatRooms,
      AccountMode.customer => state.customerChatRooms,
      AccountMode.parkingGuard => state.guardChatRooms,
    };
    final routePrefix = switch (mode) {
      AccountMode.provider => '/provider',
      AccountMode.superAdmin => '/super-admin',
      AccountMode.customer => '/customer',
      AccountMode.parkingGuard => '/guard',
    };
    final child = ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        HeaderSection(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        for (final room in rooms)
          _RoleChatCard(
            room: room,
            onTap: () =>
                context.push('$routePrefix/chat-room?roomId=${room.id}'),
          ),
      ],
    );

    return switch (mode) {
      AccountMode.provider => AdminShell(currentIndex: 3, child: child),
      AccountMode.superAdmin => SuperAdminShell(currentIndex: 4, child: child),
      AccountMode.customer => CustomerShell(currentIndex: 3, child: child),
      AccountMode.parkingGuard => GuardShell(currentIndex: 3, child: child),
    };
  }
}

class RoleChatRoomScreen extends ConsumerStatefulWidget {
  const RoleChatRoomScreen({
    super.key,
    required this.mode,
    required this.roomId,
  });

  final AccountMode mode;
  final String roomId;

  @override
  ConsumerState<RoleChatRoomScreen> createState() => _RoleChatRoomScreenState();
}

class _RoleChatRoomScreenState extends ConsumerState<RoleChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(appControllerProvider.notifier);
      switch (widget.mode) {
        case AccountMode.provider:
          controller.markProviderChatAsRead(widget.roomId);
        case AccountMode.superAdmin:
          controller.markSuperAdminChatAsRead(widget.roomId);
        case AccountMode.customer:
          controller.markCustomerChatAsRead(widget.roomId);
        case AccountMode.parkingGuard:
          controller.markChatAsRead(widget.roomId);
      }
      _loadAndWatchMessages();
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAndWatchMessages() async {
    final controller = ref.read(appControllerProvider.notifier);
    await controller
        .loadChatMessagesFromSupabase(mode: widget.mode, roomId: widget.roomId)
        .catchError((_) {});
    final stream = await controller
        .watchChatMessagesFromSupabase(roomId: widget.roomId)
        .catchError((_) => const Stream<List<ChatMessage>>.empty());
    _chatSubscription?.cancel();
    _chatSubscription = stream.listen((messages) {
      if (!mounted) {
        return;
      }
      ref
          .read(appControllerProvider.notifier)
          .replaceChatMessagesFromSupabase(
            mode: widget.mode,
            roomId: widget.roomId,
            messages: messages,
          );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final controller = ref.read(appControllerProvider.notifier);
    switch (widget.mode) {
      case AccountMode.provider:
        controller.sendProviderMessage(roomId: widget.roomId, message: text);
      case AccountMode.superAdmin:
        controller.sendSuperAdminMessage(roomId: widget.roomId, message: text);
      case AccountMode.customer:
        controller.sendCustomerMessage(roomId: widget.roomId, message: text);
      case AccountMode.parkingGuard:
        controller.sendGuardMessage(roomId: widget.roomId, message: text);
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final rooms = switch (widget.mode) {
      AccountMode.provider => state.providerChatRooms,
      AccountMode.superAdmin => state.superAdminChatRooms,
      AccountMode.customer => state.customerChatRooms,
      AccountMode.parkingGuard => state.guardChatRooms,
    };
    final messages = switch (widget.mode) {
      AccountMode.provider => state.providerChatMessages,
      AccountMode.superAdmin => state.superAdminChatMessages,
      AccountMode.customer => state.customerChatMessages,
      AccountMode.parkingGuard => state.guardChatMessages,
    };
    final room = rooms.where((room) => room.id == widget.roomId).firstOrNull;
    final routePrefix = switch (widget.mode) {
      AccountMode.provider => '/provider',
      AccountMode.superAdmin => '/super-admin',
      AccountMode.customer => '/customer',
      AccountMode.parkingGuard => '/guard',
    };
    if (room == null) {
      return _roleShell(
        mode: widget.mode,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            EmptyStateCard(
              title: 'Room chat tidak ditemukan',
              body: 'Pilih room dari daftar chat.',
              actionLabel: 'Kembali',
              onPressed: () => context.go('$routePrefix/chat'),
            ),
          ],
        ),
      );
    }
    final visibleMessages =
        messages.where((message) => message.roomId == room.id).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return _roleShell(
      mode: widget.mode,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('$routePrefix/chat'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HeaderSection(
                    title: room.title,
                    subtitle:
                        '${room.participantRole} - ${room.participantName}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              itemCount: visibleMessages.length,
              itemBuilder: (context, index) {
                final message = visibleMessages[index];
                return _RoleChatBubble(
                  message: message,
                  isMine: message.senderRole == roleLabel(widget.mode),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.14))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleShell({required AccountMode mode, required Widget child}) {
    return switch (mode) {
      AccountMode.provider => AdminShell(currentIndex: 3, child: child),
      AccountMode.superAdmin => SuperAdminShell(currentIndex: 4, child: child),
      AccountMode.customer => CustomerShell(currentIndex: 3, child: child),
      AccountMode.parkingGuard => GuardShell(currentIndex: 3, child: child),
    };
  }
}

class _RoleChatCard extends StatelessWidget {
  const _RoleChatCard({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: PremiumCard(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _customerChatAccent(
                    room.participantRole,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _customerChatIcon(room.participantRole),
                  color: _customerChatAccent(room.participantRole),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
              if (room.unreadCount > 0)
                StatusBadge(label: '${room.unreadCount}', color: AppTheme.blue),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChatBubble extends StatelessWidget {
  const _RoleChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: math.min(MediaQuery.sizeOf(context).width * 0.74, 520),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.08))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? Colors.white70 : AppTheme.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isMine ? Colors.white : AppTheme.ink,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerComplaintScreen extends ConsumerStatefulWidget {
  const CustomerComplaintScreen({super.key});

  @override
  ConsumerState<CustomerComplaintScreen> createState() =>
      _CustomerComplaintScreenState();
}

class _CustomerComplaintScreenState
    extends ConsumerState<CustomerComplaintScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'Pembayaran';
  String _priority = 'Sedang';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await ref
          .read(appControllerProvider.notifier)
          .submitCustomerComplaint(
            title: _titleController.text.trim(),
            category: _category,
            description: _descriptionController.text.trim(),
            priority: _priority,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim komplain ke Supabase')),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Komplain berhasil dikirim')));
    context.go('/customer/chat');
  }

  @override
  Widget build(BuildContext context) {
    return CustomerShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Komplain Admin Aplikasi',
            subtitle:
                'Laporkan masalah pembayaran, QR ticket, booking, lokasi, akun, atau aplikasi.',
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go('/customer/chat'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Kembali ke Chat'),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul komplain',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Judul komplain wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori masalah',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pembayaran',
                        child: Text('Pembayaran'),
                      ),
                      DropdownMenuItem(
                        value: 'QR Ticket',
                        child: Text('QR Ticket'),
                      ),
                      DropdownMenuItem(
                        value: 'Booking',
                        child: Text('Booking'),
                      ),
                      DropdownMenuItem(
                        value: 'Lokasi Parkir',
                        child: Text('Lokasi Parkir'),
                      ),
                      DropdownMenuItem(value: 'Akun', child: Text('Akun')),
                      DropdownMenuItem(
                        value: 'Aplikasi Error',
                        child: Text('Aplikasi Error'),
                      ),
                      DropdownMenuItem(
                        value: 'Lainnya',
                        child: Text('Lainnya'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi masalah',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi masalah wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Prioritas',
                      prefixIcon: Icon(Icons.priority_high_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Rendah', child: Text('Rendah')),
                      DropdownMenuItem(value: 'Sedang', child: Text('Sedang')),
                      DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Kirim Komplain',
                    icon: Icons.send_rounded,
                    onPressed: _submitComplaint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerChatCategoryCard extends StatelessWidget {
  const _CustomerChatCategoryCard({
    required this.room,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.actionLabel = 'Buka chat',
  });

  final ChatRoom room;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: PremiumCard(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (room.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${room.unreadCount}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_customerChatTimeLabel(room.lastMessageAt)} - $actionLabel',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerChatBubble extends StatelessWidget {
  const _CustomerChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppTheme.blue : Colors.white;
    final textColor = isMine ? Colors.white : AppTheme.ink;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: EdgeInsets.only(
          left: isMine ? 52 : 0,
          right: isMine ? 0 : 52,
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 20),
          ),
          boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.1))],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? Colors.white70 : AppTheme.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.45),
            ),
            const SizedBox(height: 6),
            Text(
              _customerChatTimeLabel(message.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? Colors.white70 : AppTheme.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _customerChatIcon(String role) {
  if (role == 'Penjaga Parkir') {
    return Icons.security_rounded;
  }
  if (role == 'Penyedia Parkir') {
    return Icons.apartment_rounded;
  }
  return Icons.support_agent_rounded;
}

Color _customerChatAccent(String role) {
  if (role == 'Penjaga Parkir') {
    return AppTheme.blue;
  }
  if (role == 'Penyedia Parkir') {
    return AppTheme.emerald;
  }
  return const Color(0xFFD97706);
}

String _customerChatTimeLabel(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.inMinutes < 1) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  return formatDateTime(time);
}

class CustomerNotificationsScreen extends ConsumerStatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  ConsumerState<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends ConsumerState<CustomerNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadCurrentUserNotificationsFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(appControllerProvider).customerNotifications;
    return CustomerShell(
      currentIndex: -1,
      child: NotificationsList(
        title: 'Notifikasi pengguna',
        subtitle:
            'Booking, pembayaran, verifikasi QR, dan status durasi parkir.',
        items: notices,
      ),
    );
  }
}

class CustomerFavoriteLotsScreen extends ConsumerStatefulWidget {
  const CustomerFavoriteLotsScreen({super.key});

  @override
  ConsumerState<CustomerFavoriteLotsScreen> createState() =>
      _CustomerFavoriteLotsScreenState();
}

class _CustomerFavoriteLotsScreenState
    extends ConsumerState<CustomerFavoriteLotsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(appControllerProvider.notifier);
      await controller.loadParkingDataFromSupabase().catchError((_) {});
      await controller.loadCustomerFavoritesFromSupabase().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final favoriteLots = [
      for (final lot in state.lots)
        if (state.favoriteLotIds.contains(lot.id)) lot,
    ];

    return CustomerShell(
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Lokasi favorit',
            subtitle:
                'Lokasi parkir yang kamu simpan untuk akses cepat booking berikutnya.',
          ),
          const SizedBox(height: 18),
          if (favoriteLots.isEmpty)
            EmptyStateCard(
              title: 'Belum ada favorit',
              body:
                  'Tekan ikon love pada lokasi parkir untuk menyimpannya di daftar ini.',
              actionLabel: 'Cari lokasi',
              onPressed: () => context.go('/customer/home'),
            )
          else
            ...favoriteLots.map(
              (lot) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ParkingLotCard(
                  lot: lot,
                  isFavorite: true,
                  onToggleFavorite: () => ref
                      .read(appControllerProvider.notifier)
                      .toggleFavoriteLot(lot.id),
                  onDetail: () {
                    ref.read(appControllerProvider.notifier).selectLot(lot);
                    context.push('/customer/parking-detail');
                  },
                  onBooking: lot.isFull
                      ? () {}
                      : () {
                          ref
                              .read(appControllerProvider.notifier)
                              .selectLot(lot);
                          context.push('/customer/booking');
                        },
                ),
              ),
            ),
        ],
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
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFDC2626),
            title: 'Lokasi favorit',
            subtitle: '${state.favoriteLotIds.length} lokasi tersimpan',
            onTap: () => context.push('/customer/favorites'),
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
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.blue,
            title: 'Ganti password',
            subtitle: 'Perbarui password login akun.',
            onTap: () => context.push('/change-password'),
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
  Uint8List? _avatarBytes;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isSavingAvatar = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _nameController = TextEditingController(text: state.customerName);
    _emailController = TextEditingController(text: state.customerEmail);
    _phoneController = TextEditingController(text: state.customerPhone);
    _avatarBytes = state.customerAvatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

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

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateCustomerProfile(name: name, email: email, phone: phone);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      context.go('/customer/profile');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal menyimpan profil ke Supabase. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }
    final result = await showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CustomerAvatarAdjustDialog(
        bytes: bytes,
        hasExistingPhoto: _avatarBytes != null,
      ),
    );
    if (result == null) {
      return;
    }
    if (result.isEmpty) {
      _removePhoto();
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSavingAvatar = true;
    });
    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateCustomerAvatar(result);
      if (!mounted) {
        return;
      }
      setState(() => _avatarBytes = result);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal upload foto profil. Pastikan SQL storage avatar sudah dijalankan.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingAvatar = false);
      }
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isSavingAvatar = true);
    try {
      await ref.read(appControllerProvider.notifier).removeCustomerAvatar();
      if (!mounted) {
        return;
      }
      setState(() => _avatarBytes = null);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = 'Gagal menghapus foto profil.');
    } finally {
      if (mounted) {
        setState(() => _isSavingAvatar = false);
      }
    }
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
                GestureDetector(
                  onTap: _isSavingAvatar ? null : _pickPhoto,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.blueSoft,
                    backgroundImage: _avatarBytes == null
                        ? null
                        : MemoryImage(_avatarBytes!),
                    child: _avatarBytes == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: AppTheme.blue,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSavingAvatar ? null : _pickPhoto,
                        icon: const Icon(Icons.photo_camera_rounded, size: 18),
                        label: Text(
                          _isSavingAvatar ? 'Mengupload...' : 'Ganti Foto',
                        ),
                      ),
                      if (_avatarBytes != null)
                        OutlinedButton.icon(
                          onPressed: _isSavingAvatar ? null : _removePhoto,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                          label: const Text('Hapus Foto'),
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
                _CustomerCompactButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  icon: Icons.save_rounded,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ],
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
  late bool _bookingNotificationEnabled;
  late bool _paymentNotificationEnabled;
  late bool _promoNotificationEnabled;
  late bool _accountSecurityEnabled;
  late String _selectedLanguage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _bookingNotificationEnabled = state.bookingNotificationEnabled;
    _paymentNotificationEnabled = state.paymentNotificationEnabled;
    _promoNotificationEnabled = state.promoNotificationEnabled;
    _accountSecurityEnabled = state.accountSecurityEnabled;
    _selectedLanguage = state.selectedLanguage;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateCustomerSettings(
            bookingNotificationEnabled: _bookingNotificationEnabled,
            paymentNotificationEnabled: _paymentNotificationEnabled,
            promoNotificationEnabled: _promoNotificationEnabled,
            selectedLanguage: _selectedLanguage,
            accountSecurityEnabled: _accountSecurityEnabled,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan akun berhasil disimpan')),
      );
      context.go('/customer/profile');
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan pengaturan ke Supabase.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                  'Notifikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _bookingNotificationEnabled,
                  onChanged: (value) =>
                      setState(() => _bookingNotificationEnabled = value),
                  title: const Text('Notifikasi booking'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.blue,
                ),
                SwitchListTile(
                  value: _paymentNotificationEnabled,
                  onChanged: (value) =>
                      setState(() => _paymentNotificationEnabled = value),
                  title: const Text('Notifikasi pembayaran'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.emerald,
                ),
                SwitchListTile(
                  value: _promoNotificationEnabled,
                  onChanged: (value) =>
                      setState(() => _promoNotificationEnabled = value),
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
                  'Preferensi akun',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Bahasa aplikasi',
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Indonesia',
                      child: Text('Indonesia'),
                    ),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value ?? 'Indonesia'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _accountSecurityEnabled,
                  onChanged: (value) =>
                      setState(() => _accountSecurityEnabled = value),
                  title: const Text('Mode keamanan akun'),
                  subtitle: const Text('Aktifkan perlindungan akun tambahan.'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _CustomerCompactButton(
            label: _isSaving ? 'Menyimpan...' : 'Simpan Pengaturan',
            icon: Icons.save_rounded,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class RoleAccountSettingsScreen extends ConsumerStatefulWidget {
  const RoleAccountSettingsScreen({super.key, required this.mode});

  final AccountMode mode;

  @override
  ConsumerState<RoleAccountSettingsScreen> createState() =>
      _RoleAccountSettingsScreenState();
}

class _RoleAccountSettingsScreenState
    extends ConsumerState<RoleAccountSettingsScreen> {
  bool _primaryNotificationEnabled = true;
  bool _secondaryNotificationEnabled = true;
  bool _reportNotificationEnabled = true;
  bool _accountSecurityEnabled = true;
  String _selectedLanguage = 'Indonesia';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await ref
          .read(appControllerProvider.notifier)
          .fetchCurrentProfileSettingsFromSupabase();
      if (!mounted) {
        return;
      }
      setState(() {
        _primaryNotificationEnabled = settings.primaryNotificationEnabled;
        _secondaryNotificationEnabled = settings.secondaryNotificationEnabled;
        _reportNotificationEnabled = settings.reportNotificationEnabled;
        _selectedLanguage = settings.selectedLanguage;
        _accountSecurityEnabled = settings.accountSecurityEnabled;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateCurrentProfileSettings(
            primaryNotificationEnabled: _primaryNotificationEnabled,
            secondaryNotificationEnabled: _secondaryNotificationEnabled,
            reportNotificationEnabled: _reportNotificationEnabled,
            selectedLanguage: _selectedLanguage,
            accountSecurityEnabled: _accountSecurityEnabled,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan akun berhasil disimpan.')),
      );
      context.go(
        widget.mode == AccountMode.parkingGuard
            ? '/guard/profile'
            : '/provider/profile',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menyimpan pengaturan. Pastikan SQL profile_settings sudah dijalankan.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuard = widget.mode == AccountMode.parkingGuard;
    final title = isGuard ? 'Pengaturan Penjaga' : 'Pengaturan Penyedia';
    final firstLabel = isGuard
        ? 'Notifikasi tugas lokasi'
        : 'Notifikasi booking masuk';
    final secondLabel = isGuard
        ? 'Notifikasi scan QR'
        : 'Notifikasi pembayaran';
    final reportLabel = isGuard
        ? 'Notifikasi aktivitas shift'
        : 'Notifikasi laporan harian';

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              HeaderSection(
                title: title,
                subtitle: 'Preferensi akun ini disimpan di Supabase.',
              ),
              const SizedBox(height: 18),
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
                      value: _primaryNotificationEnabled,
                      onChanged: (value) =>
                          setState(() => _primaryNotificationEnabled = value),
                      title: Text(firstLabel),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.blue,
                    ),
                    SwitchListTile(
                      value: _secondaryNotificationEnabled,
                      onChanged: (value) =>
                          setState(() => _secondaryNotificationEnabled = value),
                      title: Text(secondLabel),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.emerald,
                    ),
                    SwitchListTile(
                      value: _reportNotificationEnabled,
                      onChanged: (value) =>
                          setState(() => _reportNotificationEnabled = value),
                      title: Text(reportLabel),
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
                      'Preferensi akun',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
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
                        () => _selectedLanguage = value ?? 'Indonesia',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _accountSecurityEnabled,
                      onChanged: (value) =>
                          setState(() => _accountSecurityEnabled = value),
                      title: const Text('Mode keamanan akun'),
                      subtitle: const Text(
                        'Aktifkan perlindungan akun tambahan.',
                      ),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.emerald,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan pengaturan',
                icon: Icons.save_rounded,
                onPressed: _isSaving ? null : _save,
              ),
            ],
          );

    return isGuard
        ? GuardShell(currentIndex: 4, child: content)
        : AdminShell(currentIndex: 4, child: content);
  }
}

class _CustomerAvatarAdjustDialog extends StatefulWidget {
  const _CustomerAvatarAdjustDialog({
    required this.bytes,
    required this.hasExistingPhoto,
  });

  final Uint8List bytes;
  final bool hasExistingPhoto;

  @override
  State<_CustomerAvatarAdjustDialog> createState() =>
      _CustomerAvatarAdjustDialogState();
}

class _CustomerAvatarAdjustDialogState
    extends State<_CustomerAvatarAdjustDialog> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _previewKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final currentScale = _controller.value.getMaxScaleOnAxis();
    final nextScale = (currentScale * factor).clamp(1.0, 4.0);
    _controller.value = Matrix4.diagonal3Values(nextScale, nextScale, 1);
  }

  void _reset() {
    _controller.value = Matrix4.identity();
  }

  Future<Uint8List> _capturePreview() async {
    final boundary =
        _previewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      return widget.bytes;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List() ?? widget.bytes;
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxHeight = mediaSize.height * 0.80;
    final previewSize = math.min(mediaSize.width - 72, 320.0);

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
              padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                'Atur Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: RepaintBoundary(
                        key: _previewKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            width: previewSize,
                            height: previewSize,
                            child: InteractiveViewer(
                              transformationController: _controller,
                              minScale: 1,
                              maxScale: 4,
                              panEnabled: true,
                              boundaryMargin: const EdgeInsets.all(80),
                              child: Image.memory(
                                widget.bytes,
                                width: previewSize,
                                height: previewSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Zoom out',
                          onPressed: () => _zoom(0.85),
                          icon: const Icon(Icons.zoom_out_rounded),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          tooltip: 'Reset posisi',
                          onPressed: _reset,
                          icon: const Icon(Icons.center_focus_strong_rounded),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          tooltip: 'Zoom in',
                          onPressed: () => _zoom(1.18),
                          icon: const Icon(Icons.zoom_in_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  if (widget.hasExistingPhoto)
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(Uint8List(0)),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Hapus Foto'),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bytes = await _capturePreview();
                      if (context.mounted) {
                        Navigator.of(context).pop(bytes);
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Gunakan Foto Ini'),
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

class _CustomerCompactButton extends StatelessWidget {
  const _CustomerCompactButton({
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late Future<SupabaseProviderDashboardSummary> _summaryFuture;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(appControllerProvider.notifier);
    _summaryFuture = controller.fetchProviderDashboardSummaryFromSupabase();
    Future.microtask(() async {
      try {
        await controller.loadParkingDataFromSupabase();
      } catch (_) {
        if (mounted) {
          setState(
            () => _loadError = 'Data lokasi/slot gagal dimuat dari Supabase.',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final occupiedSlots = state.slots.where((slot) => !slot.isAvailable).length;
    return AdminShell(
      currentIndex: 0,
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
          if (state.isUsingDemoData || _loadError != null) ...[
            InlineNotice(
              icon: _loadError == null
                  ? Icons.science_rounded
                  : Icons.wifi_off_rounded,
              accent: _loadError == null
                  ? AppTheme.blue
                  : const Color(0xFFD97706),
              message:
                  _loadError ??
                  'Dashboard masih memakai data demo/lokal sampai data Supabase berhasil dimuat.',
            ),
            const SizedBox(height: 18),
          ],
          FutureBuilder<SupabaseProviderDashboardSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              final summary =
                  snapshot.data ??
                  const SupabaseProviderDashboardSummary(
                    vehiclesEnteredToday: 0,
                    revenueToday: 0,
                  );
              final summaryError = snapshot.hasError
                  ? 'Ringkasan penyedia gagal dimuat dari Supabase.'
                  : null;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  if (summaryError != null)
                    InlineNotice(
                      icon: Icons.wifi_off_rounded,
                      accent: const Color(0xFFD97706),
                      message: summaryError,
                    ),
                  StatCard(
                    label: 'Kendaraan masuk',
                    value: '${summary.vehiclesEnteredToday}',
                    accent: AppTheme.blue,
                    icon: Icons.directions_car_rounded,
                    onTap: () => context.push('/provider/transaction-detail'),
                  ),
                  StatCard(
                    label: 'Pendapatan hari ini',
                    value: formatCurrency(summary.revenueToday),
                    accent: AppTheme.emerald,
                    icon: Icons.trending_up_rounded,
                    onTap: () => context.push('/provider/daily-revenue'),
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
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Monitoring kendaraan realtime',
            action: 'Lihat detail',
            onTap: () => context.push('/provider/monitoring'),
          ),
          const SizedBox(height: 12),
          PremiumCard(child: SizedBox(height: 220, child: RevenueChart())),
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
    final selectedLot = lots.contains(state.selectedLot)
        ? state.selectedLot!
        : lots.first;
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
              child: MiniInfoTile(
                icon: Icons.domain_add_rounded,
                iconColor: lot.accent,
                title: lot.name,
                subtitle:
                    '${lot.availableSlots}/${lot.totalSlots} slot tersedia • ${lot.address}',
                onTap: () =>
                    ref.read(appControllerProvider.notifier).selectLot(lot),
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
  ConsumerState<AddParkingLotScreen> createState() =>
      _AddParkingLotScreenState();
}

class _AddParkingLotScreenState extends ConsumerState<AddParkingLotScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  double _capacity = 60;
  double _price = 12000;
  ParkingTariffType _tariffType = ParkingTariffType.hourly;
  double _motorRate = 5000;
  double _carRate = 12000;
  double _truckRate = 20000;
  Uint8List? _photoBytes;
  String? _photoLabel;
  bool _isPickingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Neo Smart Parking Hub');
    _addressController = TextEditingController(
      text: 'Jl. Gatot Subroto Smart Gate 8',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
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

  Future<void> _pickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoLabel = file.name;
      });
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const plazaSudirmanMapEmbedUrl =
        'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3966.4161452224284!2d106.82248539999999!3d-6.208714500000001!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e69f51300fe5895%3A0xa89d22dd2b5922c9!2sSudirman%20Plaza%20Gedung%20Plaza%20Marein!5e0!3m2!1sen!2sid!4v1780720226941!5m2!1sen!2sid';
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
                const MapEmbedView(
                  title: 'Plaza Sudirman',
                  embedUrl: plazaSudirmanMapEmbedUrl,
                  latitude: -6.2087145,
                  longitude: 106.8224854,
                  height: 320,
                ),
                const SizedBox(height: 8),
                Text(
                  'Titik lokasi dipilih: Plaza Sudirman',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
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
                const SizedBox(height: 16),
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
                      icon: Icons.calendar_today_rounded,
                    ),
                    ChoiceItem(
                      value: ParkingTariffType.progressive,
                      label: 'Progresif',
                      icon: Icons.trending_up_rounded,
                    ),
                  ],
                  value: _tariffType,
                  onChanged: (value) => setState(() => _tariffType = value),
                ),
                const SizedBox(height: 16),
                LabeledSlider(
                  label: 'Tarif motor',
                  value: _motorRate,
                  min: 2000,
                  max: 20000,
                  divisions: 18,
                  display: formatCurrency(_motorRate.toInt()),
                  onChanged: (value) => setState(() => _motorRate = value),
                ),
                const SizedBox(height: 16),
                LabeledSlider(
                  label: 'Tarif mobil',
                  value: _carRate,
                  min: 5000,
                  max: 40000,
                  divisions: 35,
                  display: formatCurrency(_carRate.toInt()),
                  onChanged: (value) => setState(() => _carRate = value),
                ),
                const SizedBox(height: 16),
                LabeledSlider(
                  label: 'Tarif truk',
                  value: _truckRate,
                  min: 10000,
                  max: 60000,
                  divisions: 50,
                  display: formatCurrency(_truckRate.toInt()),
                  onChanged: (value) => setState(() => _truckRate = value),
                ),
                const SizedBox(height: 18),
                MiniInfoTile(
                  icon: Icons.add_photo_alternate_rounded,
                  iconColor: AppTheme.blue,
                  title: _photoLabel == null
                      ? 'Upload foto lahan'
                      : 'Foto: $_photoLabel',
                  subtitle: _photoBytes == null
                      ? 'Pilih foto lahan parkir dari galeri.'
                      : 'Foto lahan berhasil dipilih.',
                  onTap: _isPickingPhoto ? null : _pickPhoto,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan lahan',
                  icon: Icons.save_rounded,
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final error = _lotFormError();
                          if (error != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                            return;
                          }
                          setState(() => _isSaving = true);
                          try {
                            await ref
                                .read(appControllerProvider.notifier)
                                .addLot(
                                  name: _nameController.text.trim(),
                                  address: _addressController.text.trim(),
                                  capacity: _capacity.toInt(),
                                  price: _price.toInt(),
                                  mapEmbedUrl: plazaSudirmanMapEmbedUrl,
                                  latitude: -6.2087145,
                                  longitude: 106.8224854,
                                  tariffType: _tariffType,
                                  motorRate: _motorRate.toInt(),
                                  carRate: _carRate.toInt(),
                                  truckRate: _truckRate.toInt(),
                                  photoLabel: _photoLabel,
                                  photoBytes: _photoBytes,
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lahan dan slot berhasil disimpan.',
                                ),
                              ),
                            );
                            context.pop();
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal menyimpan lahan ke Supabase.',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
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
  late final TextEditingController _passwordController;
  final Set<String> _selectedLotIds = {};
  bool _canConfirmCash = true;
  bool _canManageSlots = true;
  bool _isSavingGuard = false;
  String? _editingGuardId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sinta Penjaga');
    _emailController = TextEditingController(
      text: 'sinta.guard@parkircepat.app',
    );
    _phoneController = TextEditingController(text: '+62 812 4455 6677');
    _passwordController = TextEditingController();
    final lots = visibleLotsFor(ref.read(appControllerProvider));
    if (lots.isNotEmpty) {
      _selectedLotIds.add(lots.first.id);
    }
    Future.microtask(() async {
      final controller = ref.read(appControllerProvider.notifier);
      await controller.loadParkingDataFromSupabase().catchError((_) {});
      await controller.loadProviderGuardsFromSupabase().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
    if (_editingGuardId == null && _passwordController.text.length < 6) {
      return 'Password awal penjaga minimal 6 karakter.';
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
    _passwordController.clear();
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

  Future<void> _saveGuard(List<ParkingLot> lots) async {
    if (_isSavingGuard) {
      return;
    }

    final error = _guardFormError(lots);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final controller = ref.read(appControllerProvider.notifier);
    final editingGuardId = _editingGuardId;
    setState(() => _isSavingGuard = true);
    try {
      if (editingGuardId == null) {
        await controller.createParkingGuard(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          assignedLotIds: _selectedLotIds.toList(),
          canScanQr: true,
          canConfirmCash: _canConfirmCash,
          canManageSlots: _canManageSlots,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun penjaga berhasil dihubungkan.')),
        );
      } else {
        await controller.updateParkingGuard(
          id: editingGuardId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          assignedLotIds: _selectedLotIds.toList(),
          canConfirmCash: _canConfirmCash,
          canManageSlots: _canManageSlots,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun penjaga berhasil diperbarui.')),
        );
      }
      _resetGuardForm(lots);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menyimpan. Pastikan Edge Function create-guard-account dan SQL guard sudah dijalankan.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingGuard = false);
      }
    }
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

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(appControllerProvider.notifier)
          .deleteParkingGuard(guard.id);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menghapus penjaga dari Supabase.')),
      );
      return;
    }
    if (_editingGuardId == guard.id) {
      _resetGuardForm(visibleLotsFor(ref.read(appControllerProvider)));
    }
    messenger.showSnackBar(
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
                        ? 'Hubungkan akun penjaga'
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
                const SizedBox(height: 10),
                const InlineNotice(
                  icon: Icons.info_outline_rounded,
                  accent: Color(0xFFD97706),
                  message:
                      'Penyedia bisa membuat akun login penjaga langsung, lalu memberikan email dan password awal ke penjaga.',
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
                if (_editingGuardId == null) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password awal penjaga',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                ],
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
                  label: _isSavingGuard
                      ? 'Menyimpan...'
                      : _editingGuardId == null
                      ? 'Hubungkan akun penjaga'
                      : 'Simpan perubahan',
                  icon: _editingGuardId == null
                      ? Icons.person_add_alt_1_rounded
                      : Icons.save_rounded,
                  onPressed: _isSavingGuard ? null : () => _saveGuard(lots),
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

class VehicleMonitoringScreen extends ConsumerStatefulWidget {
  const VehicleMonitoringScreen({super.key});

  @override
  ConsumerState<VehicleMonitoringScreen> createState() =>
      _VehicleMonitoringScreenState();
}

class _VehicleMonitoringScreenState
    extends ConsumerState<VehicleMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadProviderMonitoringFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
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

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  late final MobileScannerController _scannerController;
  final TextEditingController _manualTicketController = TextEditingController();
  Booking? _scannedBooking;
  String? _lastScannedTicket;
  DateTime? _lastScanTime;
  String? _lastScanStatus;
  bool _handlingScan = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _scannerController.stop();
    _scannerController.dispose();
    _manualTicketController.dispose();
    super.dispose();
  }

  String get _dashboardRoute {
    final mode = ref.read(appControllerProvider).currentMode;
    return switch (mode) {
      AccountMode.parkingGuard => '/guard/home',
      AccountMode.provider => '/provider/dashboard',
      AccountMode.superAdmin => '/super-admin/dashboard',
      AccountMode.customer => '/customer/home',
    };
  }

  Future<void> _stopCamera() async {
    try {
      await _scannerController.stop();
    } catch (_) {}
  }

  Future<void> _startCamera() async {
    try {
      await _scannerController.start();
    } catch (_) {}
  }

  Future<void> _goBack() async {
    if (_isLeaving) {
      return;
    }
    _isLeaving = true;
    await _stopCamera();
    if (!mounted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(_dashboardRoute);
    }
  }

  Future<void> _goDashboard() async {
    if (_isLeaving) {
      return;
    }
    _isLeaving = true;
    await _stopCamera();
    if (mounted) {
      context.go(_dashboardRoute);
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _handlingScan = false;
      _scannedBooking = null;
      _lastScanStatus = 'Siap scan ulang';
    });
    await _startCamera();
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash tidak tersedia di perangkat ini')),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ganti kamera tidak tersedia')),
      );
    }
  }

  Future<void> _handleDetectedCode(String rawCode) async {
    final ticketNumber = _extractTicketNumber(rawCode);
    await _stopCamera();
    if (!mounted) {
      return;
    }
    final booking = await ref
        .read(appControllerProvider.notifier)
        .loadBookingByTicketNumberFromSupabase(ticketNumber);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastScannedTicket = ticketNumber;
      _lastScanTime = DateTime.now();
      _scannedBooking = booking;
      _lastScanStatus = booking == null
          ? 'Tiket tidak ditemukan'
          : 'Tiket ditemukan';
    });
    if (booking == null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('QR Ticket tidak ditemukan'),
          content: Text('Kode "$ticketNumber" tidak cocok dengan tiket aktif.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goDashboard();
              },
              child: const Text('Kembali'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _scanAgain();
              },
              child: const Text('Scan Lagi'),
            ),
          ],
        ),
      );
      return;
    }
    await _showScanResultDialog(booking);
  }

  String _extractTicketNumber(String rawCode) {
    final trimmed = rawCode.trim();
    final match = RegExp(r'TKT-\d+').firstMatch(trimmed);
    return match?.group(0) ?? trimmed;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingScan) {
      return;
    }
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .firstOrNull;
    if (code == null) {
      return;
    }
    _handlingScan = true;
    _handleDetectedCode(code);
  }

  Future<void> _showManualInputDialog() async {
    _manualTicketController.text = _lastScannedTicket ?? '';
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Input Kode Tiket Manual'),
        content: TextField(
          controller: _manualTicketController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Nomor tiket',
            hintText: 'Contoh: TKT-1001',
            prefixIcon: Icon(Icons.confirmation_num_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(_manualTicketController.text),
            child: const Text('Cek Tiket'),
          ),
        ],
      ),
    );
    if (code != null && code.trim().isNotEmpty) {
      await _handleDetectedCode(code);
    }
  }

  Future<void> _showScanResultDialog(Booking booking) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hasil Scan QR'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ScannedTicketCard(booking: booking),
              const SizedBox(height: 12),
              const Text(
                'Pilih aksi verifikasi atau scan ulang.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _goDashboard();
            },
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _scanAgain();
            },
            child: const Text('Scan Lagi'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _confirmExit();
            },
            child: const Text('Konfirmasi Keluar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _verifyEntry();
            },
            child: const Text('Verifikasi Masuk'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyEntry() async {
    final booking = _scannedBooking;
    if (booking == null) {
      return;
    }
    final success = await ref
        .read(appControllerProvider.notifier)
        .verifyVehicleEntry(booking.ticketNumber);
    if (!mounted) {
      return;
    }
    final updatedBooking = ref
        .read(appControllerProvider.notifier)
        .bookingByTicketNumber(booking.ticketNumber);
    setState(() {
      _scannedBooking = updatedBooking ?? booking;
      _lastScanTime = DateTime.now();
      _lastScanStatus = success
          ? 'Kendaraan masuk terverifikasi'
          : 'Tiket belum dapat diverifikasi';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Kendaraan masuk berhasil diverifikasi'
              : 'Tiket belum lunas atau tidak valid',
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final booking = _scannedBooking;
    if (booking == null) {
      return;
    }
    final success = await ref
        .read(appControllerProvider.notifier)
        .confirmVehicleExit(booking.ticketNumber);
    if (!mounted) {
      return;
    }
    final updatedBooking = ref
        .read(appControllerProvider.notifier)
        .bookingByTicketNumber(booking.ticketNumber);
    setState(() {
      _scannedBooking =
          updatedBooking ??
          booking.copyWith(
            status: success ? BookingStatus.completed : booking.status,
          );
      _lastScanTime = DateTime.now();
      _lastScanStatus = success
          ? 'Kendaraan keluar dikonfirmasi'
          : 'Tiket belum dapat dikonfirmasi';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Kendaraan keluar berhasil dikonfirmasi'
              : 'Tiket tidak valid untuk keluar',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = _scannedBooking;
    final scanContextLot = _selectedGuardLot(ref.watch(appControllerProvider));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          title: const Text('Scan QR kendaraan'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (scanContextLot != null) ...[
              InlineNotice(
                icon: Icons.location_on_rounded,
                accent: scanContextLot.accent,
                message: 'Scan untuk lokasi ${scanContextLot.name}.',
              ),
              const SizedBox(height: 14),
            ],
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      height: 320,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.blue.withValues(alpha: 0.24),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'Input manual',
                                    icon: Icons.keyboard_rounded,
                                    onPressed: _showManualInputDialog,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton.filledTonal(
                                  onPressed: _toggleTorch,
                                  icon: const Icon(Icons.flash_on_rounded),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: _switchCamera,
                                  icon: const Icon(Icons.cameraswitch_rounded),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_lastScanStatus != null) ...[
                    const SizedBox(height: 12),
                    InlineNotice(
                      icon: Icons.qr_code_scanner_rounded,
                      accent: AppTheme.blue,
                      message:
                          '${_lastScanStatus!}${_lastScanTime == null ? '' : ' - ${formatDateTime(_lastScanTime!)}'}',
                    ),
                  ],
                  if (_lastScannedTicket != null) ...[
                    const SizedBox(height: 8),
                    SummaryRow(
                      label: 'Scan terakhir',
                      value: _lastScannedTicket!,
                    ),
                  ],
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
                    onPressed: booking == null ? null : _verifyEntry,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Konfirmasi kendaraan keluar',
                    icon: Icons.exit_to_app_rounded,
                    onPressed: booking == null ? null : _confirmExit,
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

class _ScannedTicketCard extends StatelessWidget {
  const _ScannedTicketCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
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
                  Icons.confirmation_number_rounded,
                  color: AppTheme.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.ticketNumber,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bookingStatusLabel(booking.status),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SummaryRow(label: 'Lokasi', value: booking.locationName),
          SummaryRow(label: 'Slot', value: booking.slotCode),
          SummaryRow(label: 'Plat nomor', value: booking.plateNumber),
          SummaryRow(
            label: 'Metode',
            value: _paymentMethodLabel(booking.paymentMethod),
          ),
          SummaryRow(
            label: 'Estimasi biaya',
            value: formatCurrency(booking.estimatedCost),
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
    final state = ref.watch(appControllerProvider);
    if (state.currentMode == AccountMode.provider) {
      return const ProviderFinancialReportScreen();
    }

    final transaction = state.history.first;
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

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  late final Future<SupabaseReceiptRecord?> _receiptFuture;

  @override
  void initState() {
    super.initState();
    _receiptFuture = ref
        .read(appControllerProvider.notifier)
        .fetchLatestReceiptFromSupabase();
  }

  Future<Uint8List> _buildReceiptPdf({
    required String receiptNumber,
    required String ticketNumber,
    required String locationName,
    required String plateNumber,
    required String paymentStatus,
    required String paymentMethod,
    required int amount,
    required String issuedAt,
  }) async {
    final pdf = pw.Document();
    final rows = <(String, String)>[
      ('Nomor nota', receiptNumber),
      ('Nomor tiket', ticketNumber),
      ('Lokasi', locationName),
      ('Kendaraan', plateNumber),
      ('Pembayaran', paymentStatus),
      ('Metode', paymentMethod),
      ('Diterbitkan', issuedAt),
      ('Total', formatCurrency(amount)),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Parkir Cepat',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text('Nota Digital Parkir'),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: receiptNumber,
                  width: 120,
                  height: 120,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.2),
                  1: pw.FlexColumnWidth(2),
                },
                children: [
                  for (final row in rows)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            row.$1,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(row.$2),
                        ),
                      ],
                    ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Dokumen ini dibuat otomatis oleh aplikasi Parkir Cepat.',
                style: const pw.TextStyle(color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(appControllerProvider).history;
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak nota parkir')),
      body: FutureBuilder<SupabaseReceiptRecord?>(
        future: _receiptFuture,
        builder: (context, snapshot) {
          final receipt = snapshot.data;
          final fallbackTransaction = history.isEmpty ? null : history.first;
          if (snapshot.connectionState == ConnectionState.waiting &&
              fallbackTransaction == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (receipt == null && fallbackTransaction == null) {
            return const Center(child: Text('Belum ada nota parkir.'));
          }

          final receiptNumber =
              receipt?.receiptNumber ?? 'RCT-${fallbackTransaction!.id}';
          final ticketNumber = receipt?.ticketNumber ?? fallbackTransaction!.id;
          final locationName =
              receipt?.locationName ?? fallbackTransaction!.locationName;
          final plateNumber =
              receipt?.plateNumber ?? fallbackTransaction!.plateNumber;
          final paymentStatus =
              receipt?.paymentStatus ?? fallbackTransaction!.status;
          final paymentMethod = receipt?.paymentMethod ?? '-';
          final amount = receipt?.amount ?? fallbackTransaction!.total;
          final issuedAt = receipt == null
              ? fallbackTransaction!.timeLabel
              : formatDateTime(receipt.issuedAt);
          Future<Uint8List> buildPdf() {
            return _buildReceiptPdf(
              receiptNumber: receiptNumber,
              ticketNumber: ticketNumber,
              locationName: locationName,
              plateNumber: plateNumber,
              paymentStatus: paymentStatus,
              paymentMethod: paymentMethod,
              amount: amount,
              issuedAt: issuedAt,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PremiumCard(
                child: Column(
                  children: [
                    Text(
                      'Nota Digital',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: receiptNumber,
                      size: 150,
                      eyeStyle: const QrEyeStyle(color: AppTheme.emerald),
                    ),
                    const SizedBox(height: 18),
                    SummaryRow(label: 'Nomor nota', value: receiptNumber),
                    SummaryRow(label: 'Nomor tiket', value: ticketNumber),
                    SummaryRow(label: 'Lokasi', value: locationName),
                    SummaryRow(label: 'Kendaraan', value: plateNumber),
                    SummaryRow(label: 'Pembayaran', value: paymentStatus),
                    SummaryRow(label: 'Metode', value: paymentMethod),
                    SummaryRow(label: 'Diterbitkan', value: issuedAt),
                    SummaryRow(label: 'Total', value: formatCurrency(amount)),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Cetak nota',
                      icon: Icons.print_rounded,
                      onPressed: () async {
                        await Printing.layoutPdf(
                          name: '$receiptNumber.pdf',
                          onLayout: (_) => buildPdf(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Export PDF',
                      icon: Icons.picture_as_pdf_rounded,
                      onPressed: () async {
                        await Printing.sharePdf(
                          bytes: await buildPdf(),
                          filename: '$receiptNumber.pdf',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProviderFinancialReportScreen extends ConsumerStatefulWidget {
  const ProviderFinancialReportScreen({super.key});

  @override
  ConsumerState<ProviderFinancialReportScreen> createState() =>
      _ProviderFinancialReportScreenState();
}

class _ProviderFinancialReportScreenState
    extends ConsumerState<ProviderFinancialReportScreen> {
  late Future<SupabaseProviderFinancialReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ref
        .read(appControllerProvider.notifier)
        .fetchProviderFinancialReportFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan keuangan')),
      body: FutureBuilder<SupabaseProviderFinancialReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final report =
              snapshot.data ??
              const SupabaseProviderFinancialReport(
                transactions: [],
                dailyRevenue: 0,
                monthlyRevenue: 0,
                availableSlots: 0,
                occupiedSlots: 0,
                chartPoints: [],
              );
          final recentTransactions = report.transactions.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan pendapatan',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    SummaryRow(
                      label: 'Total pendapatan bulan ini',
                      value: formatCurrency(report.totalRevenue),
                      valueColor: AppTheme.emerald,
                    ),
                    SummaryRow(
                      label: 'Estimasi pengeluaran',
                      value: formatCurrency(report.estimatedExpense),
                      valueColor: const Color(0xFFDC2626),
                    ),
                    SummaryRow(
                      label: 'Laba bersih estimasi',
                      value: formatCurrency(report.estimatedNetIncome),
                      valueColor: AppTheme.blue,
                    ),
                    SummaryRow(
                      label: 'Jumlah transaksi',
                      value: '${report.transactions.length} transaksi',
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Download laporan PDF',
                      icon: Icons.picture_as_pdf_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan PDF siap diunduh'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionTitle(title: 'Transaksi terbaru'),
              const SizedBox(height: 12),
              if (recentTransactions.isEmpty)
                const EmptyStateCard(
                  title: 'Belum ada transaksi',
                  body: 'Transaksi bulan ini akan tampil di laporan ini.',
                  actionLabel: 'Kembali',
                  onPressed: _noop,
                )
              else
                ...recentTransactions.map(
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
                          SummaryRow(
                            label: 'Kendaraan',
                            value: item.plateNumber,
                          ),
                          SummaryRow(label: 'Waktu', value: item.timeLabel),
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
          );
        },
      ),
    );
  }
}

class ProviderStatisticsContent extends StatelessWidget {
  const ProviderStatisticsContent({super.key, required this.report});

  final SupabaseProviderFinancialReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            StatCard(
              label: 'Pendapatan harian',
              value: formatCurrency(report.dailyRevenue),
              accent: AppTheme.emerald,
              icon: Icons.calendar_today_rounded,
            ),
            StatCard(
              label: 'Pendapatan bulanan',
              value: formatCurrency(report.monthlyRevenue),
              accent: AppTheme.blue,
              icon: Icons.insights_rounded,
            ),
          ],
        ),
        const SizedBox(height: 18),
        PremiumCard(
          child: SizedBox(
            height: 220,
            child: RevenueChart(points: report.chartPoints),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              SummaryRow(
                label: 'Slot tersedia',
                value: '${report.availableSlots}',
              ),
              SummaryRow(label: 'Slot penuh', value: '${report.occupiedSlots}'),
            ],
          ),
        ),
      ],
    );
  }
}

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late Future<SupabaseProviderFinancialReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ref
        .read(appControllerProvider.notifier)
        .fetchProviderFinancialReportFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik dan laporan')),
      body: FutureBuilder<SupabaseProviderFinancialReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final report =
              snapshot.data ??
              const SupabaseProviderFinancialReport(
                transactions: [],
                dailyRevenue: 0,
                monthlyRevenue: 0,
                availableSlots: 0,
                occupiedSlots: 0,
                chartPoints: [],
              );
          return ProviderStatisticsContent(report: report);
        },
      ),
    );
  }
}

class ProviderDailyRevenueScreen extends ConsumerStatefulWidget {
  const ProviderDailyRevenueScreen({super.key});

  @override
  ConsumerState<ProviderDailyRevenueScreen> createState() =>
      _ProviderDailyRevenueScreenState();
}

class _ProviderDailyRevenueScreenState
    extends ConsumerState<ProviderDailyRevenueScreen> {
  late Future<SupabaseProviderDailyRevenue> _dailyRevenueFuture;

  @override
  void initState() {
    super.initState();
    _dailyRevenueFuture = ref
        .read(appControllerProvider.notifier)
        .fetchProviderDailyRevenueFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendapatan hari ini')),
      body: FutureBuilder<SupabaseProviderDailyRevenue>(
        future: _dailyRevenueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data ??
              const SupabaseProviderDailyRevenue(
                transactions: [],
                qrisRevenue: 0,
                cashRevenue: 0,
                otherRevenue: 0,
              );
          final todayTransactions = data.transactions;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency(data.totalRevenue),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.emerald,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total pendapatan dari transaksi Supabase hari ini.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
                    ),
                    const SizedBox(height: 18),
                    SummaryRow(
                      label: 'Transaksi hari ini',
                      value: '${todayTransactions.length} transaksi',
                    ),
                    SummaryRow(
                      label: 'Rata-rata transaksi',
                      value: formatCurrency(data.averageTransaction),
                    ),
                    SummaryRow(
                      label: 'Transaksi terbesar',
                      value: formatCurrency(data.highestTransaction),
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
                      'Metode pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SummaryRow(
                      label: 'QRIS / digital',
                      value: formatCurrency(data.qrisRevenue),
                      valueColor: AppTheme.blue,
                    ),
                    SummaryRow(
                      label: 'Tunai',
                      value: formatCurrency(data.cashRevenue),
                      valueColor: AppTheme.emerald,
                    ),
                    if (data.otherRevenue > 0)
                      SummaryRow(
                        label: 'Lainnya',
                        value: formatCurrency(data.otherRevenue),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionTitle(title: 'Transaksi hari ini'),
              const SizedBox(height: 12),
              if (todayTransactions.isEmpty)
                const EmptyStateCard(
                  title: 'Belum ada transaksi',
                  body: 'Transaksi yang masuk hari ini akan tampil di sini.',
                  actionLabel: 'Lihat statistik',
                  onPressed: _noop,
                )
              else
                ...todayTransactions.map(
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
                          SummaryRow(label: 'ID transaksi', value: item.id),
                          SummaryRow(
                            label: 'Kendaraan',
                            value: item.plateNumber,
                          ),
                          SummaryRow(label: 'Status', value: item.status),
                          SummaryRow(label: 'Waktu', value: item.timeLabel),
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
          );
        },
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

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(appControllerProvider.notifier)
          .loadCurrentUserNotificationsFromSupabase()
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundImage: state.roleAvatarBytes == null
                      ? null
                      : MemoryImage(state.roleAvatarBytes!),
                  child: state.roleAvatarBytes == null
                      ? const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: AppTheme.emerald,
                        )
                      : null,
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
            onTap: () => context.push('/provider/edit-profile'),
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
            onTap: () => context.push('/provider/account-settings'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.blue,
            title: 'Ganti password',
            subtitle: 'Perbarui password login akun.',
            onTap: () => context.push('/change-password'),
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

class SuperAdminProfileScreen extends ConsumerWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return SuperAdminShell(
      currentIndex: 5,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          PremiumCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.blueSoft,
                  backgroundImage: state.roleAvatarBytes == null
                      ? null
                      : MemoryImage(state.roleAvatarBytes!),
                  child: state.roleAvatarBytes == null
                      ? const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: AppTheme.blue,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  state.userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const StatusBadge(label: 'Super Admin', color: AppTheme.blue),
                const SizedBox(height: 10),
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
            subtitle: 'Perbarui nama, email, nomor HP, dan foto profil.',
            onTap: () => context.push('/super-admin/edit-profile'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.security_rounded,
            iconColor: AppTheme.emerald,
            title: 'Akses super admin',
            subtitle: 'Akun ini dipakai untuk pengawasan seluruh aplikasi.',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.blue,
            title: 'Ganti password',
            subtitle: 'Perbarui password login akun.',
            onTap: () => context.push('/change-password'),
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

class RoleEditProfileScreen extends ConsumerStatefulWidget {
  const RoleEditProfileScreen({super.key, required this.mode});

  final AccountMode mode;

  @override
  ConsumerState<RoleEditProfileScreen> createState() =>
      _RoleEditProfileScreenState();
}

class _RoleEditProfileScreenState extends ConsumerState<RoleEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  Uint8List? _avatarBytes;
  bool _isSaving = false;
  bool _isSavingAvatar = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    final guard = activeGuard(state);
    _avatarBytes = state.roleAvatarBytes;
    _nameController = TextEditingController(
      text: widget.mode == AccountMode.parkingGuard
          ? (guard?.name ?? state.userName)
          : state.userName,
    );
    _emailController = TextEditingController(
      text: widget.mode == AccountMode.parkingGuard
          ? (guard?.email.isNotEmpty == true ? guard!.email : state.email)
          : state.email,
    );
    _phoneController = TextEditingController(
      text: widget.mode == AccountMode.parkingGuard
          ? (guard?.phoneNumber.isNotEmpty == true
                ? guard!.phoneNumber
                : state.phoneNumber)
          : state.phoneNumber,
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    final result = await showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CustomerAvatarAdjustDialog(
        bytes: bytes,
        hasExistingPhoto: _avatarBytes != null,
      ),
    );
    if (result == null) {
      return;
    }
    if (result.isEmpty) {
      await _removePhoto();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSavingAvatar = true;
    });
    try {
      await ref.read(appControllerProvider.notifier).updateRoleAvatar(result);
      if (!mounted) {
        return;
      }
      setState(() => _avatarBytes = result);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal upload foto profil. Pastikan SQL storage avatar sudah dijalankan.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingAvatar = false);
      }
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isSavingAvatar = true);
    try {
      await ref.read(appControllerProvider.notifier).removeRoleAvatar();
      if (!mounted) {
        return;
      }
      setState(() => _avatarBytes = null);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = 'Gagal menghapus foto profil.');
    } finally {
      if (mounted) {
        setState(() => _isSavingAvatar = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong.');
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

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      await ref
          .read(appControllerProvider.notifier)
          .updateRoleProfile(name: name, email: email, phone: phone);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      context.go(switch (widget.mode) {
        AccountMode.parkingGuard => '/guard/profile',
        AccountMode.superAdmin => '/super-admin/profile',
        _ => '/provider/profile',
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage =
            'Gagal menyimpan profil ke Supabase. Cek koneksi dan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      AccountMode.parkingGuard => 'Edit Profil Penjaga',
      AccountMode.superAdmin => 'Edit Profil Super Admin',
      _ => 'Edit Profil Penyedia',
    };
    final form = ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        HeaderSection(
          title: title,
          subtitle: 'Perbarui data akun yang tersimpan di Supabase.',
        ),
        const SizedBox(height: 18),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _isSavingAvatar ? null : _pickPhoto,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.emeraldSoft,
                  backgroundImage: _avatarBytes == null
                      ? null
                      : MemoryImage(_avatarBytes!),
                  child: _avatarBytes == null
                      ? Icon(
                          widget.mode == AccountMode.parkingGuard
                              ? Icons.security_rounded
                              : widget.mode == AccountMode.superAdmin
                              ? Icons.admin_panel_settings_rounded
                              : Icons.apartment_rounded,
                          size: 42,
                          color: AppTheme.emerald,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSavingAvatar ? null : _pickPhoto,
                      icon: const Icon(Icons.photo_camera_rounded, size: 18),
                      label: Text(
                        _isSavingAvatar ? 'Mengupload...' : 'Ganti Foto',
                      ),
                    ),
                    if (_avatarBytes != null)
                      OutlinedButton.icon(
                        onPressed: _isSavingAvatar ? null : _removePhoto,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Hapus Foto'),
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
                  labelText: 'Nama',
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
              PrimaryButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan Profil',
                icon: Icons.save_rounded,
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ],
    );

    return switch (widget.mode) {
      AccountMode.parkingGuard => GuardShell(currentIndex: 4, child: form),
      AccountMode.superAdmin => SuperAdminShell(currentIndex: 5, child: form),
      _ => AdminShell(currentIndex: 4, child: form),
    };
  }
}

class ParkingGuardDashboardScreen extends ConsumerStatefulWidget {
  const ParkingGuardDashboardScreen({super.key});

  @override
  ConsumerState<ParkingGuardDashboardScreen> createState() =>
      _ParkingGuardDashboardScreenState();
}

class _ParkingGuardDashboardScreenState
    extends ConsumerState<ParkingGuardDashboardScreen> {
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(appControllerProvider.notifier);
      final failures = <String>[];
      try {
        await controller.loadParkingDataFromSupabase();
      } catch (_) {
        failures.add('lokasi/slot');
      }
      try {
        await controller.loadCurrentGuardFromSupabase();
      } catch (_) {
        failures.add('akun penjaga');
      }
      if (mounted && failures.isNotEmpty) {
        setState(
          () => _loadError =
              'Sebagian data penjaga gagal dimuat: ${failures.join(', ')}.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final guard = activeGuard(state);
    final lots = visibleLotsFor(state);
    final availableSlots = lots.fold<int>(
      0,
      (total, lot) => total + lot.availableSlots,
    );
    final totalSlots = lots.fold<int>(
      0,
      (total, lot) => total + lot.totalSlots,
    );
    final occupiedSlots = math.max(0, totalSlots - availableSlots);
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
          if (state.isUsingDemoData || _loadError != null) ...[
            InlineNotice(
              icon: _loadError == null
                  ? Icons.science_rounded
                  : Icons.wifi_off_rounded,
              accent: _loadError == null
                  ? AppTheme.blue
                  : const Color(0xFFD97706),
              message:
                  _loadError ??
                  'Dashboard masih memakai data demo/lokal sampai assignment Supabase berhasil dimuat.',
            ),
            const SizedBox(height: 18),
          ],
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StatCard(
                label: 'Lokasi assigned',
                value: '${lots.length}',
                accent: AppTheme.emerald,
                icon: Icons.apartment_rounded,
                onTap: () => context.push('/guard/assigned-locations'),
              ),
              StatCard(
                label: 'Slot tersedia',
                value: '$availableSlots',
                accent: AppTheme.blue,
                icon: Icons.local_parking_rounded,
                onTap: () => context.push('/guard/available-slots'),
              ),
              StatCard(
                label: 'Slot penuh',
                value: '$occupiedSlots',
                accent: const Color(0xFFD97706),
                icon: Icons.block_rounded,
                onTap: () => context.push('/guard/occupied-slots'),
              ),
              StatCard(
                label: 'Cek Pembayaran',
                value: state.activeBooking?.isPaid ?? false ? 'Lunas' : 'Cek',
                accent: AppTheme.ink,
                icon: Icons.payments_rounded,
                onTap: () => context.push('/guard/check-payment'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MiniInfoTile(
            icon: Icons.chat_bubble_rounded,
            iconColor: AppTheme.blue,
            title: 'Chat & Komplain',
            subtitle: 'Hubungi customer, penyedia, atau admin aplikasi.',
            onTap: () => context.push('/guard/chat'),
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

class GuardAssignedLocationsScreen extends ConsumerWidget {
  const GuardAssignedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final lots = visibleLotsFor(state);
    return GuardShell(
      currentIndex: 0,
      child: _GuardSubPage(
        title: 'Lokasi assigned',
        subtitle: 'Daftar lokasi kerja yang terhubung dengan akun penjaga.',
        children: [
          if (lots.isEmpty)
            EmptyStateCard(
              title: 'Belum ada lokasi assigned',
              body:
                  'Penyedia parkir belum menetapkan lokasi kerja untuk akun ini.',
              actionLabel: 'Kembali ke Dashboard',
              onPressed: () => context.go('/guard/dashboard'),
            )
          else
            ...lots.map((lot) {
              final fullSlots = lot.totalSlots - lot.availableSlots;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    ref.read(appControllerProvider.notifier).selectLot(lot);
                    context.push('/guard/location-detail');
                  },
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lot.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.slate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lot.address,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.slate, height: 1.45),
                        ),
                        const SizedBox(height: 14),
                        SummaryRow(
                          label: 'Slot tersedia',
                          value: '${lot.availableSlots} slot',
                          valueColor: AppTheme.emerald,
                        ),
                        SummaryRow(
                          label: 'Slot penuh',
                          value: '$fullSlots slot',
                          valueColor: fullSlots > 0
                              ? const Color(0xFFD97706)
                              : AppTheme.slate,
                        ),
                        SummaryRow(
                          label: 'Total slot',
                          value: '${lot.totalSlots} slot',
                        ),
                        SummaryRow(
                          label: 'Status aktif',
                          value: lot.isFull ? 'Penuh' : 'Aktif',
                          valueColor: lot.isFull
                              ? const Color(0xFFDC2626)
                              : AppTheme.emerald,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class GuardLocationDetailScreen extends ConsumerWidget {
  const GuardLocationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final lot = _selectedGuardLot(state);
    final booking = state.activeBooking;

    if (lot == null) {
      return GuardShell(
        currentIndex: 0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            EmptyStateCard(
              title: 'Lokasi belum dipilih',
              body: 'Pilih salah satu lokasi kerja dari dashboard penjaga.',
              actionLabel: 'Kembali ke Dashboard',
              onPressed: () => context.go('/guard/dashboard'),
            ),
          ],
        ),
      );
    }

    final occupiedSlots = lot.totalSlots - lot.availableSlots;
    return GuardShell(
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          HeaderSection(
            title: lot.name,
            subtitle: 'Detail lokasi kerja penjaga parkir.',
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go('/guard/dashboard'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Kembali ke Dashboard'),
          ),
          const SizedBox(height: 18),
          PremiumCard(
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lot.address,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.slate, height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SummaryRow(
                  label: 'Slot tersedia',
                  value: '${lot.availableSlots} slot',
                  valueColor: AppTheme.emerald,
                ),
                SummaryRow(
                  label: 'Slot penuh',
                  value: '$occupiedSlots slot',
                  valueColor: occupiedSlots > 0
                      ? const Color(0xFFD97706)
                      : AppTheme.slate,
                ),
                SummaryRow(
                  label: 'Total slot',
                  value: '${lot.totalSlots} slot',
                ),
                SummaryRow(
                  label: 'Tarif per jam',
                  value: formatCurrency(lot.pricePerHour),
                  valueColor: AppTheme.blue,
                ),
                SummaryRow(
                  label: 'Status aktif',
                  value: lot.isFull ? 'Penuh' : 'Aktif',
                  valueColor: lot.isFull
                      ? const Color(0xFFDC2626)
                      : AppTheme.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Daftar slot'),
          const SizedBox(height: 12),
          if (state.slots.isEmpty)
            EmptyStateCard(
              title: 'Belum ada data slot',
              body: 'Data slot akan tampil setelah penyedia menambahkan slot.',
              actionLabel: 'Kembali ke Dashboard',
              onPressed: () => context.go('/guard/dashboard'),
            )
          else
            ...state.slots.map((slot) {
              final activeBookingInLot =
                  booking != null && booking.locationName == lot.name;
              final matchedBooking =
                  activeBookingInLot && booking.slotCode == slot.label
                  ? booking
                  : null;
              final statusColor = slot.isAvailable
                  ? AppTheme.emerald
                  : const Color(0xFFD97706);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuardSlotCard(
                  slotCode: slot.label,
                  locationName: lot.name,
                  plateNumber: matchedBooking?.plateNumber,
                  status: slot.isAvailable ? 'Tersedia' : 'Terisi',
                  statusColor: statusColor,
                ),
              );
            }),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Lihat Kendaraan Aktif',
            icon: Icons.directions_car_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).selectLot(lot);
              context.push('/guard/vehicles');
            },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Scan QR',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () {
              ref.read(appControllerProvider.notifier).selectLot(lot);
              context.push('/guard/scan-qr');
            },
          ),
        ],
      ),
    );
  }
}

class GuardAvailableSlotsScreen extends ConsumerWidget {
  const GuardAvailableSlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final lots = visibleLotsFor(state);
    final slots = state.slots.where((slot) => slot.isAvailable).toList();
    return GuardShell(
      currentIndex: 0,
      child: _GuardSubPage(
        title: 'Slot tersedia',
        subtitle: 'Slot kosong dari lokasi yang ditugaskan ke penjaga.',
        children: [
          if (slots.isEmpty)
            EmptyStateCard(
              title: 'Tidak ada slot tersedia',
              body: 'Semua slot sedang penuh atau belum ada data slot.',
              actionLabel: 'Kembali ke Dashboard',
              onPressed: () => context.go('/guard/dashboard'),
            )
          else
            ...slots.map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuardSlotCard(
                  slotCode: slot.label,
                  locationName: _guardSlotLocationName(lots),
                  status: 'Tersedia',
                  statusColor: AppTheme.emerald,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GuardOccupiedSlotsScreen extends ConsumerWidget {
  const GuardOccupiedSlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final lots = visibleLotsFor(state);
    final slots = state.slots.where((slot) => !slot.isAvailable).toList();
    final booking = state.activeBooking;
    return GuardShell(
      currentIndex: 0,
      child: _GuardSubPage(
        title: 'Slot penuh',
        subtitle: 'Slot yang sedang terisi pada area kerja penjaga.',
        children: [
          if (slots.isEmpty)
            EmptyStateCard(
              title: 'Belum ada slot penuh',
              body: 'Slot penuh akan tampil saat ada kendaraan yang masuk.',
              actionLabel: 'Kembali ke Dashboard',
              onPressed: () => context.go('/guard/dashboard'),
            )
          else
            ...slots.map((slot) {
              final matchedBooking =
                  booking != null && booking.slotCode == slot.label
                  ? booking
                  : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuardSlotCard(
                  slotCode: slot.label,
                  locationName:
                      matchedBooking?.locationName ??
                      _guardSlotLocationName(lots),
                  plateNumber: matchedBooking?.plateNumber,
                  status: 'Terisi',
                  statusColor: const Color(0xFFD97706),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class GuardCheckPaymentScreen extends ConsumerStatefulWidget {
  const GuardCheckPaymentScreen({super.key});

  @override
  ConsumerState<GuardCheckPaymentScreen> createState() =>
      _GuardCheckPaymentScreenState();
}

class _GuardCheckPaymentScreenState
    extends ConsumerState<GuardCheckPaymentScreen> {
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  Booking? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _ticketController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _checkPayment() {
    final ticket = _ticketController.text.trim();
    final plate = _plateController.text.trim().toUpperCase();
    final booking = ref.read(appControllerProvider).activeBooking;
    final ticketMatches = ticket.isEmpty || booking?.ticketNumber == ticket;
    final plateMatches =
        plate.isEmpty || booking?.plateNumber.toUpperCase() == plate;

    if (booking != null && ticketMatches && plateMatches) {
      setState(() {
        _result = booking;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _result = null;
      _errorMessage =
          'Tiket tidak ditemukan. Periksa nomor tiket atau plat kendaraan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GuardShell(
      currentIndex: 0,
      child: _GuardSubPage(
        title: 'Cek Pembayaran',
        subtitle:
            'Masukkan nomor tiket atau plat kendaraan untuk mengecek status.',
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _ticketController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nomor tiket',
                    prefixIcon: Icon(Icons.confirmation_num_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Plat kendaraan',
                    prefixIcon: Icon(Icons.directions_car_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Cek Status Pembayaran',
                  icon: Icons.search_rounded,
                  onPressed: _checkPayment,
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            InlineNotice(
              icon: Icons.error_outline_rounded,
              accent: const Color(0xFFDC2626),
              message: _errorMessage!,
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 14),
            PremiumCard(
              accent: AppTheme.blueSoft,
              child: Column(
                children: [
                  SummaryRow(
                    label: 'Nomor tiket',
                    value: _result!.ticketNumber,
                  ),
                  SummaryRow(
                    label: 'Nama lokasi',
                    value: _result!.locationName,
                  ),
                  SummaryRow(
                    label: 'Plat kendaraan',
                    value: _result!.plateNumber,
                  ),
                  SummaryRow(
                    label: 'Total bayar',
                    value: formatCurrency(_result!.estimatedCost),
                    valueColor: AppTheme.blue,
                  ),
                  SummaryRow(
                    label: 'Metode pembayaran',
                    value: _paymentMethodLabel(_result!.paymentMethod),
                  ),
                  SummaryRow(
                    label: 'Status pembayaran',
                    value: _result!.isPaid ? 'Sudah Bayar' : 'Belum Bayar',
                    valueColor: _result!.isPaid
                        ? AppTheme.emerald
                        : const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuardSubPage extends StatelessWidget {
  const _GuardSubPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        HeaderSection(title: title, subtitle: subtitle),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => context.go('/guard/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Kembali ke Dashboard'),
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

class _GuardSlotCard extends StatelessWidget {
  const _GuardSlotCard({
    required this.slotCode,
    required this.locationName,
    required this.status,
    required this.statusColor,
    this.plateNumber,
  });

  final String slotCode;
  final String locationName;
  final String status;
  final Color statusColor;
  final String? plateNumber;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.local_parking_rounded, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slot $slotCode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plateNumber == null
                      ? locationName
                      : '$locationName - $plateNumber',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.slate,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}

String _guardSlotLocationName(List<ParkingLot> lots) {
  if (lots.isEmpty) {
    return 'Lokasi belum ditetapkan';
  }
  return lots.first.name;
}

ParkingLot? _selectedGuardLot(AppState state) {
  final lots = visibleLotsFor(state);
  for (final lot in lots) {
    if (lot.id == state.selectedLot?.id) {
      return lot;
    }
  }
  return null;
}

class GuardVehiclesScreen extends ConsumerWidget {
  const GuardVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final selectedLot = _selectedGuardLot(state);
    final guard = activeGuard(state);
    final canConfirmCash = guard?.canConfirmCash ?? false;
    final activeBooking = state.activeBooking;
    final booking =
        selectedLot == null || activeBooking?.locationName == selectedLot.name
        ? activeBooking
        : null;
    return GuardShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          HeaderSection(
            title: 'Kendaraan aktif',
            subtitle:
                'Verifikasi masuk, keluar, dan status pembayaran pelanggan.',
          ),
          const SizedBox(height: 18),
          if (booking == null)
            EmptyStateCard(
              title: 'Belum ada kendaraan aktif',
              body: selectedLot == null
                  ? 'Kendaraan akan tampil setelah pelanggan booking tiket.'
                  : 'Belum ada kendaraan aktif pada lokasi yang dipilih.',
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
                  PrimaryButton(
                    label: 'Chat Customer',
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () {
                      final roomId = ref
                          .read(appControllerProvider.notifier)
                          .createCustomerChatRoomForBooking(booking);
                      context.push('/guard/chat-room?roomId=$roomId');
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: canConfirmCash
                        ? 'Konfirmasi pembayaran tunai'
                        : 'Tidak punya izin tunai',
                    icon: Icons.payments_rounded,
                    onPressed: booking.isPaid || !canConfirmCash
                        ? null
                        : () async {
                            await ref
                                .read(appControllerProvider.notifier)
                                .payBooking(PaymentMethod.cash);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pembayaran tunai berhasil dikonfirmasi.',
                                ),
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

class GuardChatListScreen extends ConsumerWidget {
  const GuardChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    ChatRoom? roomById(String id) {
      for (final room in state.guardChatRooms) {
        if (room.id == id) {
          return room;
        }
      }
      return null;
    }

    final customerRoom = roomById('guard-customer-tkt-1002');
    final providerRoom = roomById('guard-provider-main');
    final adminRoom = roomById('guard-admin-app');
    return GuardShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Chat & Komplain',
            subtitle:
                'Hubungi customer, penyedia parkir, atau admin aplikasi dari satu tempat.',
          ),
          const SizedBox(height: 18),
          if (customerRoom != null)
            _GuardChatCategoryCard(
              room: customerRoom,
              icon: Icons.person_rounded,
              accent: AppTheme.blue,
              onTap: () =>
                  context.push('/guard/chat-room?roomId=${customerRoom.id}'),
            ),
          if (providerRoom != null)
            _GuardChatCategoryCard(
              room: providerRoom,
              icon: Icons.apartment_rounded,
              accent: AppTheme.emerald,
              onTap: () =>
                  context.push('/guard/chat-room?roomId=${providerRoom.id}'),
            ),
          if (adminRoom != null)
            _GuardChatCategoryCard(
              room: adminRoom,
              icon: Icons.support_agent_rounded,
              accent: const Color(0xFFD97706),
              actionLabel: 'Kirim komplain',
              onTap: () => context.push('/guard/complaint'),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/guard/complaint'),
            icon: const Icon(Icons.report_problem_rounded),
            label: const Text('Buat Komplain ke Admin Aplikasi'),
          ),
          if (state.guardComplaints.isNotEmpty) ...[
            const SizedBox(height: 22),
            SectionTitle(title: 'Komplain terakhir'),
            const SizedBox(height: 12),
            ...state.guardComplaints
                .take(3)
                .map(
                  (complaint) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  complaint.title,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              StatusBadge(
                                label: complaint.status,
                                color: AppTheme.emerald,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${complaint.category} - Prioritas ${complaint.priority}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.slate, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class GuardChatRoomScreen extends ConsumerStatefulWidget {
  const GuardChatRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<GuardChatRoomScreen> createState() =>
      _GuardChatRoomScreenState();
}

class _GuardChatRoomScreenState extends ConsumerState<GuardChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.roomId.isNotEmpty) {
        ref.read(appControllerProvider.notifier).markChatAsRead(widget.roomId);
        _loadAndWatchMessages();
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAndWatchMessages() async {
    final controller = ref.read(appControllerProvider.notifier);
    await controller
        .loadChatMessagesFromSupabase(
          mode: AccountMode.parkingGuard,
          roomId: widget.roomId,
        )
        .catchError((_) {});
    final stream = await controller
        .watchChatMessagesFromSupabase(roomId: widget.roomId)
        .catchError((_) => const Stream<List<ChatMessage>>.empty());
    _chatSubscription?.cancel();
    _chatSubscription = stream.listen((messages) {
      if (!mounted) {
        return;
      }
      ref
          .read(appControllerProvider.notifier)
          .replaceChatMessagesFromSupabase(
            mode: AccountMode.parkingGuard,
            roomId: widget.roomId,
            messages: messages,
          );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    ref
        .read(appControllerProvider.notifier)
        .sendGuardMessage(roomId: widget.roomId, message: text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    ChatRoom? room;
    for (final item in state.guardChatRooms) {
      if (item.id == widget.roomId) {
        room = item;
        break;
      }
    }
    if (room == null) {
      return GuardShell(
        currentIndex: 3,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            EmptyStateCard(
              title: 'Room chat tidak ditemukan',
              body: 'Pilih room chat dari daftar Chat & Komplain.',
              actionLabel: 'Kembali ke Chat',
              onPressed: () => context.go('/guard/chat'),
            ),
          ],
        ),
      );
    }

    final messages =
        state.guardChatMessages
            .where((message) => message.roomId == room!.id)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return GuardShell(
      currentIndex: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/guard/chat'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _guardChatAccent(
                      room.participantRole,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _guardChatIcon(room.participantRole),
                    color: _guardChatAccent(room.participantRole),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${room.participantRole} - ${room.participantName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _GuardChatBubble(
                  message: message,
                  isMine: message.senderRole == 'Penjaga Parkir',
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.14))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(Icons.send_rounded),
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

class GuardComplaintScreen extends ConsumerStatefulWidget {
  const GuardComplaintScreen({super.key});

  @override
  ConsumerState<GuardComplaintScreen> createState() =>
      _GuardComplaintScreenState();
}

class _GuardComplaintScreenState extends ConsumerState<GuardComplaintScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'QR Scanner';
  String _priority = 'Sedang';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await ref
          .read(appControllerProvider.notifier)
          .submitGuardComplaint(
            title: _titleController.text.trim(),
            category: _category,
            description: _descriptionController.text.trim(),
            priority: _priority,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim komplain ke Supabase')),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Komplain berhasil dikirim')));
    context.go('/guard/chat');
  }

  @override
  Widget build(BuildContext context) {
    return GuardShell(
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const HeaderSection(
            title: 'Komplain Admin Aplikasi',
            subtitle:
                'Laporkan kendala aplikasi seperti scanner, tiket, pembayaran, atau akun.',
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go('/guard/chat'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Kembali ke Chat'),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul komplain',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Judul komplain wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori masalah',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'QR Scanner',
                        child: Text('QR Scanner'),
                      ),
                      DropdownMenuItem(
                        value: 'Pembayaran',
                        child: Text('Pembayaran'),
                      ),
                      DropdownMenuItem(
                        value: 'Data Tiket',
                        child: Text('Data Tiket'),
                      ),
                      DropdownMenuItem(
                        value: 'Aplikasi Error',
                        child: Text('Aplikasi Error'),
                      ),
                      DropdownMenuItem(value: 'Akun', child: Text('Akun')),
                      DropdownMenuItem(
                        value: 'Lainnya',
                        child: Text('Lainnya'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi masalah',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi masalah wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Prioritas',
                      prefixIcon: Icon(Icons.priority_high_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Rendah', child: Text('Rendah')),
                      DropdownMenuItem(value: 'Sedang', child: Text('Sedang')),
                      DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Kirim Komplain',
                    icon: Icons.send_rounded,
                    onPressed: _submitComplaint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardChatCategoryCard extends StatelessWidget {
  const _GuardChatCategoryCard({
    required this.room,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.actionLabel = 'Buka chat',
  });

  final ChatRoom room;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: PremiumCard(
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (room.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${room.unreadCount}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_guardChatTimeLabel(room.lastMessageAt)} - $actionLabel',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuardChatBubble extends StatelessWidget {
  const _GuardChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppTheme.blue : Colors.white;
    final textColor = isMine ? Colors.white : AppTheme.ink;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: EdgeInsets.only(
          left: isMine ? 52 : 0,
          right: isMine ? 0 : 52,
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 20),
          ),
          boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.1))],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? Colors.white70 : AppTheme.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.45),
            ),
            const SizedBox(height: 6),
            Text(
              _guardChatTimeLabel(message.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? Colors.white70 : AppTheme.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _guardChatIcon(String role) {
  if (role == 'Customer') {
    return Icons.person_rounded;
  }
  if (role == 'Penyedia Parkir') {
    return Icons.apartment_rounded;
  }
  return Icons.support_agent_rounded;
}

Color _guardChatAccent(String role) {
  if (role == 'Customer') {
    return AppTheme.blue;
  }
  if (role == 'Penyedia Parkir') {
    return AppTheme.emerald;
  }
  return const Color(0xFFD97706);
}

String _guardChatTimeLabel(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.inMinutes < 1) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  return formatDateTime(time);
}

class GuardProfileScreen extends ConsumerWidget {
  const GuardProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final guard = activeGuard(state);
    return GuardShell(
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
                  backgroundImage: state.roleAvatarBytes == null
                      ? null
                      : MemoryImage(state.roleAvatarBytes!),
                  child: state.roleAvatarBytes == null
                      ? const Icon(
                          Icons.security_rounded,
                          size: 40,
                          color: AppTheme.emerald,
                        )
                      : null,
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
          MiniInfoTile(
            icon: Icons.edit_rounded,
            iconColor: AppTheme.blue,
            title: 'Edit profil',
            subtitle: 'Perbarui nama, email, nomor HP, dan foto penjaga.',
            onTap: () => context.push('/guard/edit-profile'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.settings_rounded,
            iconColor: AppTheme.slate,
            title: 'Pengaturan akun',
            subtitle: 'Atur preferensi tugas dan notifikasi.',
            onTap: () => context.push('/guard/account-settings'),
          ),
          const SizedBox(height: 12),
          MiniInfoTile(
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.blue,
            title: 'Ganti password',
            subtitle: 'Perbarui password login akun.',
            onTap: () => context.push('/change-password'),
          ),
          const SizedBox(height: 12),
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
          label: 'Chat',
          icon: Icons.chat_bubble_rounded,
          route: '/customer/chat',
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
          route: '/provider/monitoring',
        ),
        ShellDestination(
          label: 'Chat',
          icon: Icons.chat_bubble_rounded,
          route: '/provider/chat',
        ),
        ShellDestination(
          label: 'Profil',
          icon: Icons.person_rounded,
          route: '/provider/profile',
        ),
      ],
      child: child,
    );
  }
}

class SuperAdminShell extends ConsumerWidget {
  const SuperAdminShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pendingVerifications = state.registrationRequests
        .where((request) => request.status == AccountStatus.pending)
        .length;
    final waitingComplaints = state.complaints
        .where((complaint) => complaint.status == ComplaintStatus.waiting)
        .length;
    return AppShell(
      currentIndex: currentIndex,
      destinations: [
        const ShellDestination(
          label: 'Home',
          icon: Icons.admin_panel_settings_rounded,
          route: '/super-admin/dashboard',
        ),
        ShellDestination(
          label: 'User',
          icon: Icons.manage_accounts_rounded,
          route: '/super-admin/users',
          badgeCount: pendingVerifications,
        ),
        const ShellDestination(
          label: 'Laporan',
          icon: Icons.insights_rounded,
          route: '/super-admin/reports',
        ),
        ShellDestination(
          label: 'Komplain',
          icon: Icons.support_agent_rounded,
          route: '/super-admin/complaints',
          badgeCount: waitingComplaints,
        ),
        const ShellDestination(
          label: 'Chat',
          icon: Icons.chat_bubble_rounded,
          route: '/super-admin/chat',
        ),
        const ShellDestination(
          label: 'Profil',
          icon: Icons.person_rounded,
          route: '/super-admin/profile',
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
          label: 'Chat',
          icon: Icons.chat_bubble_rounded,
          route: '/guard/chat',
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
                        SizedBox(
                          height: 24,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: selected
                                    ? AppTheme.blue
                                    : AppTheme.slate,
                              ),
                              if (item.badgeCount > 0)
                                Positioned(
                                  right: -14,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      item.badgeCount > 9
                                          ? '9+'
                                          : item.badgeCount.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final String route;
  final int badgeCount;
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
  const SearchField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String detail;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

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
    final activeLot = selected ?? (lots.isNotEmpty ? lots.first : null);
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
            Positioned.fill(
              child: activeLot == null
                  ? const ParkingMapBackground()
                  : MapEmbedView(
                      title: activeLot.name,
                      embedUrl: activeLot.mapEmbedUrl,
                      latitude: activeLot.latitude,
                      longitude: activeLot.longitude,
                      height: 320,
                    ),
            ),
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
  const RevenueChart({super.key, this.points = const []});

  final List<SupabaseRevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    final chartPoints = points.isEmpty
        ? const [
            SupabaseRevenuePoint(label: 'Sen', amount: 3500000),
            SupabaseRevenuePoint(label: 'Sel', amount: 5200000),
            SupabaseRevenuePoint(label: 'Rab', amount: 4600000),
            SupabaseRevenuePoint(label: 'Kam', amount: 8400000),
            SupabaseRevenuePoint(label: 'Jum', amount: 7800000),
            SupabaseRevenuePoint(label: 'Sab', amount: 9600000),
            SupabaseRevenuePoint(label: 'Min', amount: 11000000),
          ]
        : points;
    final maxAmount = chartPoints.fold<int>(
      0,
      (maxValue, point) => math.max(maxValue, point.amount),
    );
    final maxY = math.max(1, (maxAmount / 1000000).ceil()).toDouble();
    final interval = math.max(1, (maxY / 4).ceil()).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
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
              interval: interval,
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
                final index = value.toInt();
                final text = index >= 0 && index < chartPoints.length
                    ? chartPoints[index].label
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
            spots: [
              for (var index = 0; index < chartPoints.length; index++)
                FlSpot(index.toDouble(), chartPoints[index].amount / 1000000),
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
