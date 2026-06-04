import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/app_models.dart';
import '../data/repositories/app_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/supabase_service.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService.instance);
final authRepositoryProvider = Provider((ref) => AuthRepository());
final appRepositoryProvider = Provider((ref) => AppRepository());

class SessionState {
  SessionState({required this.session, required this.role, required this.providerStatus, this.user});
  final Session? session;
  final AppUser? user;
  final UserRole? role;
  final VerificationStatus? providerStatus;
  bool get isAuthenticated => session != null;
}

class SessionController extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    await ref.read(supabaseServiceProvider).init();
    final auth = ref.read(authRepositoryProvider);
    auth.authStateChanges().listen((data) async {
      final session = data.session;
      if (session == null) {
        state = AsyncData(SessionState(session: null, role: null, providerStatus: null));
        return;
      }
      final repo = ref.read(appRepositoryProvider);
      final user = await repo.fetchCurrentUser(session.user.id);
      final provider = await repo.fetchProviderProfile(session.user.id);
      state = AsyncData(SessionState(session: session, user: user, role: user?.role, providerStatus: provider?.verificationStatus));
    });
    final current = auth.currentUser;
    if (current == null) return SessionState(session: null, role: null, providerStatus: null);
    final repo = ref.read(appRepositoryProvider);
    final user = await repo.fetchCurrentUser(current.id);
    final provider = await repo.fetchProviderProfile(current.id);
    return SessionState(session: Supabase.instance.client.auth.currentSession, user: user, role: user?.role, providerStatus: provider?.verificationStatus);
  }
}

final sessionControllerProvider = AsyncNotifierProvider<SessionController, SessionState>(SessionController.new);
