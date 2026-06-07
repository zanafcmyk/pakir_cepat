import 'dart:io';

import '../models/app_models.dart';
import '../services/supabase_service.dart';

class AppRepository {
  final _client = SupabaseService.instance.client;

  Future<AppUser?> fetchCurrentUser(String userId) async {
    final data = await _client.from('users').select().eq('id', userId).maybeSingle();
    return data == null ? null : AppUser.fromJson(data);
  }

  Future<ProviderProfile?> fetchProviderProfile(String userId) async {
    final data = await _client.from('providers').select().eq('user_id', userId).maybeSingle();
    return data == null ? null : ProviderProfile.fromJson(data);
  }

  Future<ParkingGuardProfile?> fetchParkingGuardProfile(String userId) async {
    final data = await _client.from('parking_guards').select().eq('user_id', userId).maybeSingle();
    return data == null ? null : ParkingGuardProfile.fromJson(data);
  }

  Future<List<ParkingLocation>> fetchParkingLocations() async {
    final data = await _client.from('parking_locations').select().order('created_at');
    return data.map<ParkingLocation>((e) => ParkingLocation.fromJson(e)).toList();
  }

  Future<List<ParkingLocation>> fetchProviderParkingLocations(String providerId) async {
    final data = await _client
        .from('parking_locations')
        .select()
        .eq('provider_id', providerId)
        .order('created_at');
    return data.map<ParkingLocation>((e) => ParkingLocation.fromJson(e)).toList();
  }

  Future<List<ParkingLocation>> fetchGuardParkingLocations(String guardUserId) async {
    final guard = await fetchParkingGuardProfile(guardUserId);
    if (guard == null || guard.assignedLocationIds.isEmpty) return [];
    final data = await _client
        .from('parking_locations')
        .select()
        .inFilter('id', guard.assignedLocationIds)
        .order('created_at');
    return data.map<ParkingLocation>((e) => ParkingLocation.fromJson(e)).toList();
  }

  Future<List<Vehicle>> fetchVehicles(String userId) async {
    final data = await _client.from('vehicles').select().eq('user_id', userId).order('created_at', ascending: false);
    return data.map<Vehicle>((e) => Vehicle.fromJson(e)).toList();
  }

  Future<List<Booking>> fetchBookings(String userId) async {
    final data = await _client.from('bookings').select().eq('user_id', userId).order('created_at', ascending: false);
    return data.map<Booking>((e) => Booking.fromJson(e)).toList();
  }

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.storage.from(bucket).upload(path, file);
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Stream<List<Map<String, dynamic>>> watchTable(String table) =>
      _client.from(table).stream(primaryKey: ['id']);
}
