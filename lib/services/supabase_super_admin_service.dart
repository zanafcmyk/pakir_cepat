import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import 'supabase_parking_service.dart';

class SupabaseSuperAdminOverview {
  const SupabaseSuperAdminOverview({
    required this.customerCount,
    required this.providerCount,
    required this.guardCount,
    required this.pendingVerificationCount,
    required this.suspendedUserCount,
    required this.waitingComplaintCount,
    required this.activeLotCount,
    required this.activeVehicleCount,
    required this.totalTransactionCount,
    required this.totalRevenue,
  });

  final int customerCount;
  final int providerCount;
  final int guardCount;
  final int pendingVerificationCount;
  final int suspendedUserCount;
  final int waitingComplaintCount;
  final int activeLotCount;
  final int activeVehicleCount;
  final int totalTransactionCount;
  final int totalRevenue;
}

class SupabaseSuperAdminReport {
  const SupabaseSuperAdminReport({
    required this.transactions,
    required this.chartPoints,
  });

  final List<TransactionRecord> transactions;
  final List<SupabaseRevenuePoint> chartPoints;
}

class SupabaseSuperAdminService {
  SupabaseSuperAdminService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<RegistrationRequest>> fetchProviderRegistrationRequests() async {
    final rows = await _client
        .from('provider_applications')
        .select(
          'id, parking_name, address, photo_url, location_label, capacity, '
          'identity_document_url, status, created_at, '
          'profiles(id, full_name, email, phone_number)',
        )
        .inFilter('status', ['pending', 'rejected'])
        .order('created_at', ascending: false);

    return [
      for (final item in rows)
        _registrationRequestFromRow(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<List<ManagedUserAccount>> fetchManagedUsers() async {
    final rows = await _client
        .from('profiles')
        .select(
          'id, full_name, email, role, account_status, access_status, note, created_at',
        )
        .neq('role', 'super_admin')
        .order('created_at', ascending: false);

    return [
      for (final item in rows)
        _managedUserFromRow(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> updateUserAccessStatus({
    required String profileId,
    required UserAccessStatus status,
  }) {
    return _client
        .from('profiles')
        .update({
          'access_status': _accessStatusToDb(status),
          'note': status == UserAccessStatus.suspended
              ? 'Dinonaktifkan oleh Super Admin untuk pemeriksaan.'
              : 'Diaktifkan kembali oleh Super Admin.',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', profileId);
  }

  Future<void> deleteManagedUser(String profileId) {
    return _client.functions.invoke(
      'admin-delete-user',
      body: {'profileId': profileId},
    );
  }

  Future<SupabaseSuperAdminOverview> fetchOverview() async {
    final profiles = await _client
        .from('profiles')
        .select('role, account_status, access_status');
    final complaints = await _client.from('complaints').select('status');
    final lots = await _client.from('parking_lots').select('is_active');
    final bookings = await _client
        .from('bookings')
        .select('status, estimated_cost, final_cost');

    var customerCount = 0;
    var providerCount = 0;
    var guardCount = 0;
    var pendingVerificationCount = 0;
    var suspendedUserCount = 0;
    for (final row in profiles) {
      switch (row['role'] as String?) {
        case 'customer':
          customerCount++;
        case 'provider':
          providerCount++;
        case 'parking_guard':
          guardCount++;
      }
      if (row['account_status'] == 'pending') {
        pendingVerificationCount++;
      }
      if (row['access_status'] == 'suspended') {
        suspendedUserCount++;
      }
    }

    final waitingComplaintCount = complaints
        .where((row) => row['status'] == 'waiting')
        .length;
    final activeLotCount = lots.where((row) => row['is_active'] == true).length;
    var activeVehicleCount = 0;
    var totalTransactionCount = 0;
    var totalRevenue = 0;
    for (final row in bookings) {
      final status = row['status'] as String?;
      if (status == 'paid' || status == 'active' || status == 'completed') {
        totalTransactionCount++;
        totalRevenue +=
            (row['final_cost'] as num?)?.toInt() ??
            (row['estimated_cost'] as num?)?.toInt() ??
            0;
      }
      if (status == 'active') {
        activeVehicleCount++;
      }
    }

    return SupabaseSuperAdminOverview(
      customerCount: customerCount,
      providerCount: providerCount,
      guardCount: guardCount,
      pendingVerificationCount: pendingVerificationCount,
      suspendedUserCount: suspendedUserCount,
      waitingComplaintCount: waitingComplaintCount,
      activeLotCount: activeLotCount,
      activeVehicleCount: activeVehicleCount,
      totalTransactionCount: totalTransactionCount,
      totalRevenue: totalRevenue,
    );
  }

  Future<SupabaseSuperAdminReport> fetchReport() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final rows = await _client
        .from('bookings')
        .select(
          'ticket_number, entry_time, created_at, estimated_cost, final_cost, status, '
          'parking_lots(name), vehicles(plate_number)',
        )
        .gte('created_at', weekStart.toIso8601String())
        .inFilter('status', ['paid', 'active', 'completed'])
        .order('created_at', ascending: false);

    final transactions = <TransactionRecord>[];
    final chartBuckets = <int, int>{
      for (var index = 0; index < 7; index++) index: 0,
    };
    for (final item in rows) {
      final row = Map<String, dynamic>.from(item as Map);
      final amount =
          (row['final_cost'] as num?)?.toInt() ??
          (row['estimated_cost'] as num?)?.toInt() ??
          0;
      final createdAt = DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal();
      if (createdAt != null) {
        final bucketIndex = createdAt.difference(weekStart).inDays.clamp(0, 6);
        chartBuckets[bucketIndex] = (chartBuckets[bucketIndex] ?? 0) + amount;
      }
      transactions.add(
        TransactionRecord(
          id: row['ticket_number'] as String? ?? '-',
          locationName: _nestedText(row['parking_lots'], 'name'),
          plateNumber: _nestedText(row['vehicles'], 'plate_number'),
          status: _statusLabel(row['status'] as String?),
          total: amount,
          timeLabel: _dateTimeLabel(row['entry_time'] as String?),
        ),
      );
    }

    return SupabaseSuperAdminReport(
      transactions: transactions,
      chartPoints: [
        for (var index = 0; index < 7; index++)
          SupabaseRevenuePoint(
            label: _shortDayLabel(weekStart.add(Duration(days: index))),
            amount: chartBuckets[index] ?? 0,
          ),
      ],
    );
  }

  String _nestedText(dynamic value, String key) {
    if (value is Map && value[key] != null) {
      return value[key] as String;
    }
    return '-';
  }

  String _statusLabel(String? status) => switch (status) {
    'paid' => 'Lunas',
    'active' => 'Aktif',
    'completed' => 'Selesai',
    _ => 'Diproses',
  };

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

  ManagedUserAccount _managedUserFromRow(Map<String, dynamic> row) {
    final accessStatus = row['access_status'] == 'suspended'
        ? UserAccessStatus.suspended
        : UserAccessStatus.active;
    final accountStatus = _accountStatusFromDb(
      row['account_status'] as String?,
    );
    final role = _roleFromDb(row['role'] as String?);

    return ManagedUserAccount(
      id: row['id'] as String? ?? '',
      name: row['full_name'] as String? ?? '-',
      email: row['email'] as String? ?? '-',
      role: role,
      status: accessStatus,
      note:
          row['note'] as String? ??
          (role == AccountMode.provider &&
                  accountStatus == AccountStatus.pending
              ? 'Menunggu verifikasi Super Admin.'
              : null) ??
          (accessStatus == UserAccessStatus.suspended
              ? 'Akun sedang dinonaktifkan.'
              : 'Akun aktif.'),
    );
  }

  RegistrationRequest _registrationRequestFromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] is Map
        ? Map<String, dynamic>.from(row['profiles'] as Map)
        : <String, dynamic>{};
    final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
    return RegistrationRequest(
      id: row['id'] as String? ?? '',
      profileId: profile['id'] as String?,
      fullName: profile['full_name'] as String? ?? 'Penyedia Parkir',
      email: profile['email'] as String? ?? '-',
      phoneNumber: profile['phone_number'] as String? ?? '-',
      role: AccountMode.provider,
      timeLabel: createdAt == null
          ? 'Baru'
          : _dateTimeLabel(row['created_at'] as String?),
      status: _accountStatusFromDb(row['status'] as String?),
      providerApplication: ProviderApplication(
        parkingName: row['parking_name'] as String? ?? 'Lahan parkir',
        address: row['address'] as String? ?? '-',
        photoLabel: row['photo_url'] as String? ?? '-',
        locationLabel: row['location_label'] as String? ?? '-',
        capacity: (row['capacity'] as num?)?.toInt() ?? 0,
        identityLabel: row['identity_document_url'] as String? ?? '-',
      ),
    );
  }

  AccountStatus _accountStatusFromDb(String? status) => switch (status) {
    'verified' => AccountStatus.verified,
    'rejected' => AccountStatus.rejected,
    _ => AccountStatus.pending,
  };

  AccountMode _roleFromDb(String? role) => switch (role) {
    'provider' => AccountMode.provider,
    'parking_guard' => AccountMode.parkingGuard,
    'super_admin' => AccountMode.superAdmin,
    _ => AccountMode.customer,
  };

  String _accessStatusToDb(UserAccessStatus status) => switch (status) {
    UserAccessStatus.active => 'active',
    UserAccessStatus.suspended => 'suspended',
  };
}
