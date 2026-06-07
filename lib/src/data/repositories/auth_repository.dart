import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final _client = SupabaseService.instance.client;

  Future<AuthResponse> signUpCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final auth = await _client.auth.signUp(email: email, password: password);
    final userId = auth.user?.id;
    if (userId == null) throw Exception('Auth user not created');
    await _upsertUser(userId, fullName, email, phone, UserRole.customer);
    return auth;
  }

  Future<AuthResponse> signUpSuperAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final auth = await _client.auth.signUp(email: email, password: password);
    final userId = auth.user?.id;
    if (userId == null) throw Exception('Auth user not created');
    await _upsertUser(userId, fullName, email, phone, UserRole.superAdmin);
    return auth;
  }

  Future<AuthResponse> signUpProvider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String parkingName,
    required String address,
    required int capacity,
    required double latitude,
    required double longitude,
    required String parkingPhotoUrl,
    required String ktpPhotoUrl,
  }) async {
    final auth = await _client.auth.signUp(email: email, password: password);
    final userId = auth.user?.id;
    if (userId == null) throw Exception('Auth user not created');

    await _upsertUser(userId, fullName, email, phone, UserRole.provider);

    await _client.from('parking_locations').upsert({
      'provider_id': userId,
      'parking_name': parkingName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'total_slots': capacity,
      'available_slots': capacity,
      'parking_price': 0,
    });

    return auth;
  }

  Future<AuthResponse> createParkingGuard({
    required String providerId,
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required List<String> assignedLocationIds,
    required bool canScanQr,
    required bool canConfirmCash,
    required bool canManageSlots,
  }) async {
    final auth = await _client.auth.signUp(email: email, password: password);
    final userId = auth.user?.id;
    if (userId == null) throw Exception('Auth user not created');
    await _upsertUser(userId, fullName, email, phone, UserRole.parkingGuard);
    await _client.from('parking_guards').upsert({
      'user_id': userId,
      'provider_id': providerId,
      'assigned_location_ids': assignedLocationIds,
      'can_scan_qr': canScanQr,
      'can_confirm_cash': canConfirmCash,
      'can_manage_slots': canManageSlots,
    });
    return auth;
  }

  Future<void> _upsertUser(
    String id,
    String fullName,
    String email,
    String phone,
    UserRole role,
  ) {
    return _client.from('users').upsert({
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
    });
  }

  Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;
}
