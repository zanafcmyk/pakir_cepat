import 'dart:typed_data';

import 'package:flutter/material.dart';

enum AccountMode { superAdmin, provider, parkingGuard, customer }

enum AccountStatus { pending, verified, rejected }

enum VehicleKind { motor, mobil, truk }

enum PaymentMethod { qris, ewallet, cash, card }

enum ParkingTariffType { hourly, flat, daily, progressive }

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
    this.mapEmbedUrl,
    this.latitude,
    this.longitude,
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
  final String? mapEmbedUrl;
  final double? latitude;
  final double? longitude;
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
    required this.isPaid,
  });

  final String ticketNumber;
  final String slotCode;
  final String locationName;
  final String plateNumber;
  final String vehicleLabel;
  final DateTime entryTime;
  final int estimatedCost;
  final PaymentMethod paymentMethod;
  final bool isPaid;

  Booking copyWith({
    String? ticketNumber,
    String? slotCode,
    String? locationName,
    String? plateNumber,
    String? vehicleLabel,
    DateTime? entryTime,
    int? estimatedCost,
    PaymentMethod? paymentMethod,
    bool? isPaid,
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
      isPaid: isPaid ?? this.isPaid,
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

class ParkingSlot {
  const ParkingSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
  });

  final String id;
  final String label;
  final bool isAvailable;

  ParkingSlot copyWith({String? id, String? label, bool? isAvailable}) {
    return ParkingSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
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
