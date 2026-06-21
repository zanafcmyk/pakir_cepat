import 'dart:typed_data';

import 'package:flutter/material.dart';

enum AccountMode { superAdmin, provider, parkingGuard, customer }

enum AccountStatus { pending, verified, rejected }

enum VehicleKind { motor, mobil, truk }

enum ParkingTariffType { hourly, flat, daily }

enum PaymentMethod { qris, ewallet, cash }

enum BookingStatus { pendingPayment, paid, active, completed, cancelled }

enum ComplaintStatus { waiting, answered, closed }

enum UserAccessStatus { active, suspended }

class ParkingLot {
  const ParkingLot({
    required this.id,
    this.providerId = 'provider-main',
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.availableSlots,
    required this.totalSlots,
    required this.distanceKm,
    required this.etaMinutes,
    required this.openHours,
    required this.rating,
    required this.accent,
    required this.mapEmbedUrl,
    required this.latitude,
    required this.longitude,
    this.photoLabel,
    this.photoBytes,
    this.tariffType = ParkingTariffType.hourly,
    this.motorRate,
    this.carRate,
    this.truckRate,
  });

  final String id;
  final String providerId;
  final String name;
  final String address;
  final int pricePerHour;
  final int availableSlots;
  final int totalSlots;
  final double distanceKm;
  final int etaMinutes;
  final String openHours;
  final double rating;
  final Color accent;
  final String mapEmbedUrl;
  final double latitude;
  final double longitude;
  final String? photoLabel;
  final Uint8List? photoBytes;
  final ParkingTariffType tariffType;
  final int? motorRate;
  final int? carRate;
  final int? truckRate;

  bool get isFull => availableSlots <= 0;

  ParkingLot copyWith({
    String? id,
    String? providerId,
    String? name,
    String? address,
    int? pricePerHour,
    int? availableSlots,
    int? totalSlots,
    double? distanceKm,
    int? etaMinutes,
    String? openHours,
    double? rating,
    Color? accent,
    String? mapEmbedUrl,
    double? latitude,
    double? longitude,
    String? photoLabel,
    Uint8List? photoBytes,
    ParkingTariffType? tariffType,
    int? motorRate,
    int? carRate,
    int? truckRate,
  }) {
    return ParkingLot(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      openHours: openHours ?? this.openHours,
      rating: rating ?? this.rating,
      accent: accent ?? this.accent,
      mapEmbedUrl: mapEmbedUrl ?? this.mapEmbedUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoLabel: photoLabel ?? this.photoLabel,
      photoBytes: photoBytes ?? this.photoBytes,
      tariffType: tariffType ?? this.tariffType,
      motorRate: motorRate ?? this.motorRate,
      carRate: carRate ?? this.carRate,
      truckRate: truckRate ?? this.truckRate,
    );
  }
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.kind,
    required this.quantity,
    required this.durationHours,
  });

  final String id;
  final String plateNumber;
  final VehicleKind kind;
  final int quantity;
  final int durationHours;

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    VehicleKind? kind,
    int? quantity,
    int? durationHours,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      durationHours: durationHours ?? this.durationHours,
    );
  }

  String get label => switch (kind) {
    VehicleKind.motor => 'Motor',
    VehicleKind.mobil => 'Mobil',
    VehicleKind.truk => 'Truk',
  };
}

class Booking {
  const Booking({
    required this.ticketNumber,
    required this.slotCode,
    required this.locationName,
    required this.plateNumber,
    required this.vehicleLabel,
    required this.entryTime,
    required this.estimatedCost,
    required this.paymentMethod,
    required this.status,
  });

  final String ticketNumber;
  final String slotCode;
  final String locationName;
  final String plateNumber;
  final String vehicleLabel;
  final DateTime entryTime;
  final int estimatedCost;
  final PaymentMethod paymentMethod;
  final BookingStatus status;

  bool get isPaid =>
      status == BookingStatus.paid ||
      status == BookingStatus.active ||
      status == BookingStatus.completed;

  bool get canShowTicket =>
      status == BookingStatus.paid || status == BookingStatus.active;

  Booking copyWith({
    String? ticketNumber,
    String? slotCode,
    String? locationName,
    String? plateNumber,
    String? vehicleLabel,
    DateTime? entryTime,
    int? estimatedCost,
    PaymentMethod? paymentMethod,
    BookingStatus? status,
  }) {
    return Booking(
      ticketNumber: ticketNumber ?? this.ticketNumber,
      slotCode: slotCode ?? this.slotCode,
      locationName: locationName ?? this.locationName,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      entryTime: entryTime ?? this.entryTime,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.locationName,
    required this.plateNumber,
    required this.status,
    required this.total,
    required this.timeLabel,
  });

  final String id;
  final String locationName;
  final String plateNumber;
  final String status;
  final int total;
  final String timeLabel;
}

class NoticeItem {
  const NoticeItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color accent;
}

class ComplaintItem {
  const ComplaintItem({
    required this.id,
    this.senderProfileId,
    required this.senderName,
    required this.senderRole,
    required this.subject,
    required this.message,
    required this.timeLabel,
    required this.status,
    this.reply,
  });

  final String id;
  final String? senderProfileId;
  final String senderName;
  final AccountMode senderRole;
  final String subject;
  final String message;
  final String timeLabel;
  final ComplaintStatus status;
  final String? reply;

  ComplaintItem copyWith({
    String? id,
    String? senderProfileId,
    String? senderName,
    AccountMode? senderRole,
    String? subject,
    String? message,
    String? timeLabel,
    ComplaintStatus? status,
    String? reply,
  }) {
    return ComplaintItem(
      id: id ?? this.id,
      senderProfileId: senderProfileId ?? this.senderProfileId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      status: status ?? this.status,
      reply: reply ?? this.reply,
    );
  }
}

class RegistrationRequest {
  const RegistrationRequest({
    required this.id,
    this.profileId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.timeLabel,
    required this.status,
    this.providerApplication,
  });

  final String id;
  final String? profileId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final AccountMode role;
  final String timeLabel;
  final AccountStatus status;
  final ProviderApplication? providerApplication;

  RegistrationRequest copyWith({
    String? id,
    String? profileId,
    String? fullName,
    String? email,
    String? phoneNumber,
    AccountMode? role,
    String? timeLabel,
    AccountStatus? status,
    ProviderApplication? providerApplication,
  }) {
    return RegistrationRequest(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      timeLabel: timeLabel ?? this.timeLabel,
      status: status ?? this.status,
      providerApplication: providerApplication ?? this.providerApplication,
    );
  }
}

class ManagedUserAccount {
  const ManagedUserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.note,
  });

  final String id;
  final String name;
  final String email;
  final AccountMode role;
  final UserAccessStatus status;
  final String note;

  ManagedUserAccount copyWith({
    String? id,
    String? name,
    String? email,
    AccountMode? role,
    UserAccessStatus? status,
    String? note,
  }) {
    return ManagedUserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}

class ParkingSlot {
  const ParkingSlot({
    required this.id,
    this.lotId,
    required this.label,
    required this.isAvailable,
  });

  final String id;
  final String? lotId;
  final String label;
  final bool isAvailable;

  ParkingSlot copyWith({
    String? id,
    String? lotId,
    String? label,
    bool? isAvailable,
  }) {
    return ParkingSlot(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      label: label ?? this.label,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderRole,
    required this.senderName,
    required this.receiverRole,
    required this.receiverName,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String roomId;
  final String senderRole;
  final String senderName;
  final String receiverRole;
  final String receiverName;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderRole,
    String? senderName,
    String? receiverRole,
    String? receiverName,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderRole: senderRole ?? this.senderRole,
      senderName: senderName ?? this.senderName,
      receiverRole: receiverRole ?? this.receiverRole,
      receiverName: receiverName ?? this.receiverName,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.title,
    required this.participantRole,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final String id;
  final String title;
  final String participantRole;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ChatRoom copyWith({
    String? id,
    String? title,
    String? participantRole,
    String? participantName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      participantRole: participantRole ?? this.participantRole,
      participantName: participantName ?? this.participantName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class Complaint {
  const Complaint({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.title,
    required this.category,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderRole;
  final String senderName;
  final String title;
  final String category;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;
}

class ProviderApplication {
  const ProviderApplication({
    required this.parkingName,
    required this.address,
    required this.photoLabel,
    required this.locationLabel,
    required this.capacity,
    required this.identityLabel,
  });

  final String parkingName;
  final String address;
  final String photoLabel;
  final String locationLabel;
  final int capacity;
  final String identityLabel;

  ProviderApplication copyWith({
    String? parkingName,
    String? address,
    String? photoLabel,
    String? locationLabel,
    int? capacity,
    String? identityLabel,
  }) {
    return ProviderApplication(
      parkingName: parkingName ?? this.parkingName,
      address: address ?? this.address,
      photoLabel: photoLabel ?? this.photoLabel,
      locationLabel: locationLabel ?? this.locationLabel,
      capacity: capacity ?? this.capacity,
      identityLabel: identityLabel ?? this.identityLabel,
    );
  }
}

class ParkingGuardAccount {
  const ParkingGuardAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.providerId,
    required this.assignedLotIds,
    required this.canScanQr,
    required this.canConfirmCash,
    required this.canManageSlots,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String providerId;
  final List<String> assignedLotIds;
  final bool canScanQr;
  final bool canConfirmCash;
  final bool canManageSlots;
}
