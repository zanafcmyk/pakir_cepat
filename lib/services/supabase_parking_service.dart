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

class SupabaseProviderDailyRevenue {
  const SupabaseProviderDailyRevenue({
    required this.transactions,
    required this.qrisRevenue,
    required this.cashRevenue,
    required this.otherRevenue,
  });

  final List<TransactionRecord> transactions;
  final int qrisRevenue;
  final int cashRevenue;
  final int otherRevenue;

  int get totalRevenue =>
      transactions.fold(0, (total, item) => total + item.total);

  int get averageTransaction =>
      transactions.isEmpty ? 0 : (totalRevenue / transactions.length).round();

  int get highestTransaction => transactions.isEmpty
      ? 0
      : transactions
            .map((item) => item.total)
            .reduce((value, item) => value > item ? value : item);
}

class SupabaseRevenuePoint {
  const SupabaseRevenuePoint({required this.label, required this.amount});

  final String label;
  final int amount;
}

class SupabaseProviderFinancialReport {
  const SupabaseProviderFinancialReport({
    required this.transactions,
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.chartPoints,
  });

  final List<TransactionRecord> transactions;
  final int dailyRevenue;
  final int monthlyRevenue;
  final int availableSlots;
  final int occupiedSlots;
  final List<SupabaseRevenuePoint> chartPoints;

  int get totalRevenue =>
      transactions.fold(0, (total, item) => total + item.total);

  int get estimatedExpense => (totalRevenue * 0.3).round();

  int get estimatedNetIncome => totalRevenue - estimatedExpense;
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
    final lotIds = await _currentProviderLotIds();

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

  Future<SupabaseProviderDailyRevenue>
  fetchCurrentProviderDailyRevenue() async {
    final lotIds = await _currentProviderLotIds();
    if (lotIds.isEmpty) {
      return const SupabaseProviderDailyRevenue(
        transactions: [],
        qrisRevenue: 0,
        cashRevenue: 0,
        otherRevenue: 0,
      );
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final rows = await _client
        .from('bookings')
        .select(
          'ticket_number, entry_time, estimated_cost, final_cost, status, '
          'parking_lots(name), vehicles(plate_number), '
          'payments(method, status, amount, paid_at)',
        )
        .inFilter('parking_lot_id', lotIds)
        .gte('created_at', todayStart.toIso8601String())
        .inFilter('status', ['paid', 'active', 'completed'])
        .order('created_at', ascending: false);

    var qrisRevenue = 0;
    var cashRevenue = 0;
    var otherRevenue = 0;
    final transactions = <TransactionRecord>[];

    for (final item in rows) {
      final row = Map<String, dynamic>.from(item as Map);
      final payment = _latestSuccessfulPayment(row['payments']);
      final amount =
          (payment?['amount'] as num?)?.toInt() ??
          (row['final_cost'] as num?)?.toInt() ??
          (row['estimated_cost'] as num?)?.toInt() ??
          0;
      final method = payment?['method'] as String?;

      switch (method) {
        case 'qris':
        case 'ewallet':
        case 'card':
          qrisRevenue += amount;
        case 'cash':
          cashRevenue += amount;
        default:
          otherRevenue += amount;
      }

      transactions.add(
        TransactionRecord(
          id: row['ticket_number'] as String? ?? '-',
          locationName: _nestedText(row['parking_lots'], 'name'),
          plateNumber: _nestedText(row['vehicles'], 'plate_number'),
          status: _bookingStatusLabel(row['status'] as String?),
          total: amount,
          timeLabel: _timeLabel(row['entry_time'] as String?),
        ),
      );
    }

    return SupabaseProviderDailyRevenue(
      transactions: transactions,
      qrisRevenue: qrisRevenue,
      cashRevenue: cashRevenue,
      otherRevenue: otherRevenue,
    );
  }

  Future<SupabaseProviderFinancialReport>
  fetchCurrentProviderFinancialReport() async {
    final lotIds = await _currentProviderLotIds();
    if (lotIds.isEmpty) {
      return const SupabaseProviderFinancialReport(
        transactions: [],
        dailyRevenue: 0,
        monthlyRevenue: 0,
        availableSlots: 0,
        occupiedSlots: 0,
        chartPoints: [],
      );
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final rows = await _client
        .from('bookings')
        .select(
          'ticket_number, entry_time, estimated_cost, final_cost, status, '
          'created_at, parking_lots(name), vehicles(plate_number), '
          'payments(method, status, amount, paid_at)',
        )
        .inFilter('parking_lot_id', lotIds)
        .gte('created_at', monthStart.toIso8601String())
        .inFilter('status', ['paid', 'active', 'completed'])
        .order('created_at', ascending: false);

    final transactions = <TransactionRecord>[];
    final chartBuckets = <int, int>{
      for (var index = 0; index < 7; index++) index: 0,
    };
    var dailyRevenue = 0;
    var monthlyRevenue = 0;

    for (final item in rows) {
      final row = Map<String, dynamic>.from(item as Map);
      final createdAt = DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal();
      final amount = _bookingRevenueAmount(row);
      monthlyRevenue += amount;

      if (createdAt != null && !createdAt.isBefore(todayStart)) {
        dailyRevenue += amount;
      }

      if (createdAt != null && !createdAt.isBefore(weekStart)) {
        final bucketIndex = createdAt.difference(weekStart).inDays.clamp(0, 6);
        chartBuckets[bucketIndex] = (chartBuckets[bucketIndex] ?? 0) + amount;
      }

      transactions.add(
        TransactionRecord(
          id: row['ticket_number'] as String? ?? '-',
          locationName: _nestedText(row['parking_lots'], 'name'),
          plateNumber: _nestedText(row['vehicles'], 'plate_number'),
          status: _bookingStatusLabel(row['status'] as String?),
          total: amount,
          timeLabel: _dateTimeLabel(row['entry_time'] as String?),
        ),
      );
    }

    final slotRows = await _client
        .from('parking_slots')
        .select('status')
        .inFilter('parking_lot_id', lotIds);
    var availableSlots = 0;
    var occupiedSlots = 0;
    for (final row in slotRows) {
      if (row['status'] == 'available') {
        availableSlots++;
      } else {
        occupiedSlots++;
      }
    }

    return SupabaseProviderFinancialReport(
      transactions: transactions,
      dailyRevenue: dailyRevenue,
      monthlyRevenue: monthlyRevenue,
      availableSlots: availableSlots,
      occupiedSlots: occupiedSlots,
      chartPoints: [
        for (var index = 0; index < 7; index++)
          SupabaseRevenuePoint(
            label: _shortDayLabel(weekStart.add(Duration(days: index))),
            amount: chartBuckets[index] ?? 0,
          ),
      ],
    );
  }

  Future<List<String>> _currentProviderLotIds() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final providerRows = await _client
        .from('providers')
        .select('id')
        .eq('profile_id', user.id)
        .limit(1);

    if (providerRows.isEmpty) {
      return const [];
    }

    final providerId = providerRows.first['id'] as String?;
    if (providerId == null) {
      return const [];
    }

    final lotRows = await _client
        .from('parking_lots')
        .select('id')
        .eq('provider_id', providerId);

    return [
      for (final row in lotRows)
        if (row['id'] != null) row['id'] as String,
    ];
  }

  Map<String, dynamic>? _latestSuccessfulPayment(dynamic value) {
    if (value is! List || value.isEmpty) {
      return null;
    }

    final payments = [
      for (final item in value) Map<String, dynamic>.from(item as Map),
    ];
    payments.sort((a, b) {
      final aTime =
          DateTime.tryParse(a['paid_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          DateTime.tryParse(b['paid_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    for (final payment in payments) {
      if (payment['status'] == 'paid') {
        return payment;
      }
    }
    return payments.first;
  }

  int _bookingRevenueAmount(Map<String, dynamic> row) {
    final payment = _latestSuccessfulPayment(row['payments']);
    return (payment?['amount'] as num?)?.toInt() ??
        (row['final_cost'] as num?)?.toInt() ??
        (row['estimated_cost'] as num?)?.toInt() ??
        0;
  }

  String _nestedText(dynamic value, String key) {
    if (value is Map && value[key] != null) {
      return value[key] as String;
    }
    return '-';
  }

  String _bookingStatusLabel(String? status) => switch (status) {
    'paid' => 'Lunas',
    'active' => 'Aktif',
    'completed' => 'Selesai',
    _ => 'Diproses',
  };

  String _timeLabel(String? value) {
    final time = DateTime.tryParse(value ?? '');
    if (time == null) {
      return '-';
    }

    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Hari ini, $hour:$minute';
  }

  String _dateTimeLabel(String? value) {
    final time = DateTime.tryParse(value ?? '');
    if (time == null) {
      return '-';
    }

    final local = time.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _shortDayLabel(DateTime value) {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return labels[value.weekday - 1];
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
