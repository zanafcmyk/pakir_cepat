import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseParkingData {
  const SupabaseParkingData({required this.lots, required this.slots});

  final List<ParkingLot> lots;
  final List<ParkingSlot> slots;
}

class SupabaseProviderDashboardSummary {
  const SupabaseProviderDashboardSummary({
    required this.vehiclesEnteredToday,
    required this.revenueToday,
  });

  final int vehiclesEnteredToday;
  final int revenueToday;
}

class SupabaseParkingService {
  SupabaseParkingService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String?> uploadCurrentProviderLotPhoto({
    required String lotId,
    required Uint8List bytes,
    String? fileName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final extension = _fileExtension(fileName);
    final path =
        '${user.id}/$lotId/lot-${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage
        .from('parking-lot-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(extension),
            upsert: true,
          ),
        );

    return _client.storage.from('parking-lot-photos').getPublicUrl(path);
  }

  Future<SupabaseParkingData> fetchParkingData() async {
    final lotRows = await _client
        .from('parking_lots')
        .select(
          'id, provider_id, name, address, price_per_hour, total_slots, open_hours, rating, map_embed_url, latitude, longitude, photo_url, tariff_type, motor_rate, car_rate, truck_rate',
        )
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final slotRows = await _client
        .from('parking_slots')
        .select('id, parking_lot_id, label, status')
        .order('label');

    final availableByLot = <String, int>{};
    for (final row in slotRows) {
      if (row['status'] != 'available') {
        continue;
      }
      final lotId = row['parking_lot_id'] as String?;
      if (lotId == null) {
        continue;
      }
      availableByLot[lotId] = (availableByLot[lotId] ?? 0) + 1;
    }

    final lots = [
      for (final row in lotRows)
        _parkingLotFromRow(
          row,
          availableSlots: availableByLot[row['id'] as String?] ?? 0,
        ),
    ];

    final slots = [
      for (final row in slotRows)
        ParkingSlot(
          id: row['id'] as String,
          label: row['label'] as String? ?? '-',
          isAvailable: row['status'] == 'available',
        ),
    ];

    return SupabaseParkingData(lots: lots, slots: slots);
  }

  Future<SupabaseProviderDashboardSummary>
  fetchCurrentProviderDashboardSummary() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const SupabaseProviderDashboardSummary(
        vehiclesEnteredToday: 0,
        revenueToday: 0,
      );
    }

    final providerRows = await _client
        .from('providers')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);

    if (providerRows.isEmpty) {
      return const SupabaseProviderDashboardSummary(
        vehiclesEnteredToday: 0,
        revenueToday: 0,
      );
    }

    final providerId = providerRows.first['id'] as String?;
    if (providerId == null) {
      return const SupabaseProviderDashboardSummary(
        vehiclesEnteredToday: 0,
        revenueToday: 0,
      );
    }

    final lotRows = await _client
        .from('parking_lots')
        .select('id')
        .eq('provider_id', providerId);
    final lotIds = [
      for (final row in lotRows)
        if (row['id'] != null) row['id'] as String,
    ];

    if (lotIds.isEmpty) {
      return const SupabaseProviderDashboardSummary(
        vehiclesEnteredToday: 0,
        revenueToday: 0,
      );
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayRows = await _client
        .from('bookings')
        .select('status, estimated_cost, final_cost, checked_in_at')
        .inFilter('parking_lot_id', lotIds)
        .gte('created_at', todayStart.toIso8601String());

    var vehiclesEnteredToday = 0;
    var revenueToday = 0;

    for (final row in todayRows) {
      final status = row['status'] as String?;
      if (row['checked_in_at'] != null ||
          status == 'active' ||
          status == 'completed') {
        vehiclesEnteredToday++;
      }

      if (status == 'paid' || status == 'active' || status == 'completed') {
        revenueToday +=
            (row['final_cost'] as num?)?.toInt() ??
            (row['estimated_cost'] as num?)?.toInt() ??
            0;
      }
    }

    return SupabaseProviderDashboardSummary(
      vehiclesEnteredToday: vehiclesEnteredToday,
      revenueToday: revenueToday,
    );
  }

  ParkingLot _parkingLotFromRow(
    Map<String, dynamic> row, {
    required int availableSlots,
  }) {
    final pricePerHour = (row['price_per_hour'] as num?)?.toInt() ?? 0;
    final totalSlots = (row['total_slots'] as num?)?.toInt() ?? 0;

    return ParkingLot(
      id: row['id'] as String,
      providerId: row['provider_id'] as String? ?? 'provider-main',
      name: row['name'] as String? ?? 'Lokasi Parkir',
      address: row['address'] as String? ?? '-',
      pricePerHour: pricePerHour,
      availableSlots: availableSlots,
      totalSlots: totalSlots,
      distanceKm: 0.8,
      etaMinutes: 3,
      openHours: row['open_hours'] as String? ?? '24 Jam',
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      accent: const Color(0xFF10B981),
      mapEmbedUrl: row['map_embed_url'] as String? ?? '',
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0,
      photoLabel: row['photo_url'] as String?,
      tariffType: _tariffTypeFromDb(row['tariff_type'] as String?),
      motorRate: (row['motor_rate'] as num?)?.toInt() ?? pricePerHour,
      carRate: (row['car_rate'] as num?)?.toInt() ?? pricePerHour,
      truckRate: (row['truck_rate'] as num?)?.toInt() ?? pricePerHour,
    );
  }

  ParkingTariffType _tariffTypeFromDb(String? value) => switch (value) {
    'flat' => ParkingTariffType.flat,
    'daily' => ParkingTariffType.daily,
    'progressive' => ParkingTariffType.progressive,
    _ => ParkingTariffType.hourly,
  };

  String _fileExtension(String? fileName) {
    final extension = fileName?.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'png',
      'webp' => 'webp',
      'jpg' || 'jpeg' => 'jpg',
      _ => 'jpg',
    };
  }

  String _contentType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
