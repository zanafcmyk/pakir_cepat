import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

part 'src/core/app_state.dart';
part 'src/core/app_theme.dart';
part 'src/auth/auth_screens.dart';
part 'src/customer/customer_screens.dart';
part 'src/admin/admin_screens.dart';
part 'src/shared/shared_widgets.dart';

final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) => AppController());

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
