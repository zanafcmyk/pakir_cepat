import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

class SupabaseComplaintService {
  SupabaseComplaintService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Complaint?> submitComplaint({
    required AccountMode senderMode,
    required String senderName,
    required String title,
    required String category,
    required String description,
    required String priority,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final row = await _client
        .from('complaints')
        .insert({
          'sender_profile_id': user.id,
          'sender_role': _roleToDb(senderMode),
          'title': title,
          'category': category,
          'description': description,
          'priority': _priorityToDb(priority),
          'status': 'waiting',
        })
        .select('id, created_at, status')
        .single();

    return Complaint(
      id: row['id'] as String,
      senderRole: _roleLabel(senderMode),
      senderName: senderName,
      title: title,
      category: category,
      description: description,
      priority: priority,
      status: _statusText(row['status'] as String?),
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      reply: null,
    );
  }

  Future<List<ComplaintItem>> fetchComplaintsForAdmin() async {
    final rows = await _client
        .from('complaints')
        .select(
          'id, sender_profile_id, sender_role, title, category, description, status, reply, created_at, profiles(full_name)',
        )
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        _complaintItemFromRow(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<List<Complaint>> fetchCurrentUserComplaints() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final rows = await _client
        .from('complaints')
        .select(
          'id, sender_role, title, category, description, priority, status, reply, created_at, profiles(full_name)',
        )
        .eq('sender_profile_id', user.id)
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        _complaintFromRow(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<void> answerComplaint({
    required String id,
    required String reply,
  }) async {
    await _client
        .from('complaints')
        .update({
          'status': 'answered',
          'reply': reply,
          'replied_by': _client.auth.currentUser?.id,
          'replied_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  Future<void> closeComplaint(String id) async {
    await _client.from('complaints').update({'status': 'closed'}).eq('id', id);
  }

  ComplaintItem _complaintItemFromRow(Map<String, dynamic> row) {
    final createdAt =
        DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now();
    final profile = row['profiles'];
    final senderRole = _roleFromDb(row['sender_role'] as String?);
    final senderName = _displaySenderName(profile, senderRole);

    return ComplaintItem(
      id: row['id'] as String,
      senderProfileId: row['sender_profile_id'] as String?,
      senderName: senderName,
      senderRole: senderRole,
      subject: _displayComplaintTitle(
        row['title'] as String?,
        row['category'] as String?,
        senderName,
      ),
      message: row['description'] as String? ?? '-',
      timeLabel: _formatDateTime(createdAt),
      status: _statusFromDb(row['status'] as String?),
      reply: row['reply'] as String?,
    );
  }

  Complaint _complaintFromRow(Map<String, dynamic> row) {
    final createdAt =
        DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now();
    final profile = row['profiles'];
    final senderRole = _roleFromDb(row['sender_role'] as String?);
    final senderName = _displaySenderName(profile, senderRole);

    return Complaint(
      id: row['id'] as String,
      senderRole: _roleLabel(senderRole),
      senderName: senderName,
      title: _displayComplaintTitle(
        row['title'] as String?,
        row['category'] as String?,
        senderName,
      ),
      category: row['category'] as String? ?? '-',
      description: row['description'] as String? ?? '-',
      priority: _priorityText(row['priority'] as String?),
      status: _statusText(row['status'] as String?),
      createdAt: createdAt,
      reply: row['reply'] as String?,
    );
  }

  String _roleToDb(AccountMode mode) => switch (mode) {
    AccountMode.superAdmin => 'super_admin',
    AccountMode.provider => 'provider',
    AccountMode.parkingGuard => 'parking_guard',
    AccountMode.customer => 'customer',
  };

  AccountMode _roleFromDb(String? value) => switch (value) {
    'provider' => AccountMode.provider,
    'parking_guard' => AccountMode.parkingGuard,
    'super_admin' => AccountMode.superAdmin,
    _ => AccountMode.customer,
  };

  String _roleLabel(AccountMode mode) => switch (mode) {
    AccountMode.superAdmin => 'Super Admin',
    AccountMode.provider => 'Penyedia Parkir',
    AccountMode.parkingGuard => 'Penjaga Parkir',
    AccountMode.customer => 'Customer',
  };

  String _priorityToDb(String priority) {
    final normalized = priority.toLowerCase();
    if (normalized.contains('rendah')) return 'low';
    if (normalized.contains('tinggi')) return 'high';
    if (normalized.contains('urgent')) return 'urgent';
    return 'normal';
  }

  String _priorityText(String? priority) => switch (priority) {
    'low' => 'Rendah',
    'high' => 'Tinggi',
    'urgent' => 'Urgent',
    _ => 'Sedang',
  };

  String _displaySenderName(Object? profile, AccountMode senderRole) {
    final name = profile is Map ? profile['full_name'] as String? : null;
    final trimmed = name?.trim() ?? '';
    if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'pengguna') {
      return trimmed;
    }
    return switch (senderRole) {
      AccountMode.customer => 'Customer Parkir',
      AccountMode.provider => 'Penyedia Parkir',
      AccountMode.parkingGuard => 'Penjaga Parkir',
      AccountMode.superAdmin => 'Admin Aplikasi',
    };
  }

  String _displayComplaintTitle(
    String? title,
    String? category,
    String senderName,
  ) {
    final trimmed = title?.trim() ?? '';
    final normalized = trimmed.toLowerCase();
    final looksLikeSystemCode =
        trimmed.isEmpty ||
        normalized.startsWith('cmp-') ||
        normalized.startsWith('cus-cmp-') ||
        RegExp(r'^[0-9a-f]{8}-[0-9a-f-]{27,}$').hasMatch(normalized);
    if (!looksLikeSystemCode) {
      return trimmed;
    }

    final label = (category?.trim().isNotEmpty ?? false)
        ? category!.trim()
        : 'kendala aplikasi';
    return label;
  }

  ComplaintStatus _statusFromDb(String? status) => switch (status) {
    'answered' => ComplaintStatus.answered,
    'closed' => ComplaintStatus.closed,
    _ => ComplaintStatus.waiting,
  };

  String _statusText(String? status) => switch (status) {
    'answered' => 'Dijawab',
    'closed' => 'Ditutup',
    _ => 'Terkirim',
  };

  String _formatDateTime(DateTime value) {
    final date =
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date, $time';
  }
}
