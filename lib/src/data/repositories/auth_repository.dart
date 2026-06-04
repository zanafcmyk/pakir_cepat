import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final _client = SupabaseService.instance.client;
  Future<AuthResponse> signUpCustomer({required String fullName, required String email, required String phone, required String password}) async { final auth = await _client.auth.signUp(email: email, password: password); await _upsertUser(auth.user!.id, fullName, email, phone, UserRole.customer); return auth; }
  Future<AuthResponse> signUpProvider({required String fullName, required String email, required String phone, required String password, required String parkingName, required String address, required int capacity, required double latitude, required double longitude, required String parkingPhotoUrl, required String ktpPhotoUrl}) async { final auth = await _client.auth.signUp(email: email, password: password); await _upsertUser(auth.user!.id, fullName, email, phone, UserRole.provider); await _client.from('providers').upsert({'user_id': auth.user!.id,'parking_name': parkingName,'address': address,'latitude': latitude,'longitude': longitude,'capacity': capacity,'parking_photo': parkingPhotoUrl,'ktp_photo': ktpPhotoUrl,'verification_status': 'pending'}); return auth; }
  Future<void> _upsertUser(String id, String fullName, String email, String phone, UserRole role) => _client.from('users').upsert({'id': id,'full_name': fullName,'email': email,'phone': phone,'role': role.name});
  Future<AuthResponse> signIn(String email, String password) => _client.auth.signInWithPassword(email: email, password: password);
  Future<void> signOut() => _client.auth.signOut();
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;
}
