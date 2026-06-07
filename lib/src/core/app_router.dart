import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_screens.dart';
import '../screens/role_screens.dart';
import '../../customer_screens.dart';
import '../../provider_screens.dart';
import '../data/models/app_models.dart';
import 'providers.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(sessionControllerProvider, (previous, next) => notifyListeners());
  }
  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider).valueOrNull;
      final location = state.matchedLocation;
      if (location == '/') return null;
      final onAuth = location == '/login' || location.startsWith('/register');
      if (session == null || !session.isAuthenticated) return onAuth ? null : '/login';
      if (session.role == UserRole.superAdmin) {
        return location.startsWith('/super-admin') ? null : '/super-admin/dashboard';
      }
      if (session.role == UserRole.parkingGuard) {
        return location.startsWith('/guard') ? null : '/guard/dashboard';
      }
      if (session.role == UserRole.customer) return location.startsWith('/customer') ? null : '/customer/dashboard';
      if (session.role == UserRole.provider && session.providerStatus == VerificationStatus.pending) return location == '/provider/pending' ? null : '/provider/pending';
      if (session.role == UserRole.provider) return location.startsWith('/provider') ? null : '/provider/dashboard';
      return '/login';
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterChoiceScreen()),
      GoRoute(path: '/register/customer', builder: (context, state) => const CustomerRegisterScreen()),
      GoRoute(path: '/register/provider', builder: (context, state) => const ProviderRegisterScreen()),
      GoRoute(path: '/register/super-admin', builder: (context, state) => const SuperAdminRegisterScreen()),
      GoRoute(path: '/super-admin/dashboard', builder: (context, state) => const SuperAdminDashboardScreen()),
      GoRoute(path: '/customer/dashboard', builder: (context, state) => const CustomerDashboardScreen()),
      GoRoute(path: '/customer/vehicles', builder: (context, state) => const VehicleScreen()),
      GoRoute(path: '/customer/bookings', builder: (context, state) => const BookingScreen()),
      GoRoute(path: '/customer/tickets', builder: (context, state) => const TicketScreen()),
      GoRoute(path: '/customer/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(path: '/provider/dashboard', builder: (context, state) => const ProviderDashboardScreen()),
      GoRoute(path: '/provider/locations', builder: (context, state) => const ProviderLocationScreen()),
      GoRoute(path: '/provider/monitoring', builder: (context, state) => const ProviderMonitoringScreen()),
      GoRoute(path: '/provider/statistics', builder: (context, state) => const ProviderStatisticsScreen()),
      GoRoute(path: '/provider/guards', builder: (context, state) => const ParkingGuardManagementScreen()),
      GoRoute(path: '/provider/pending', builder: (context, state) => const ProviderPendingScreen()),
      GoRoute(path: '/guard/dashboard', builder: (context, state) => const ParkingGuardDashboardScreen()),
    ],
  );
});
