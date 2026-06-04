enum UserRole { customer, provider }
enum VerificationStatus { pending, verified, rejected }
enum BookingStatus { pending, active, completed, cancelled }
enum PaymentStatus { pending, paid, failed }

enum RealtimeEventType { slot, vehicle, payment, stats, booking }

UserRole userRoleFromString(String? value) =>
    value == 'provider' ? UserRole.provider : UserRole.customer;
String userRoleToString(UserRole role) => role.name;
VerificationStatus verificationStatusFromString(String? value) {
  return switch (value) {
    'verified' => VerificationStatus.verified,
    'rejected' => VerificationStatus.rejected,
    _ => VerificationStatus.pending,
  };
}
String verificationStatusToString(VerificationStatus status) => status.name;
BookingStatus bookingStatusFromString(String? value) {
  return switch (value) {
    'active' => BookingStatus.active,
    'completed' => BookingStatus.completed,
    'cancelled' => BookingStatus.cancelled,
    _ => BookingStatus.pending,
  };
}
String bookingStatusToString(BookingStatus status) => status.name;
PaymentStatus paymentStatusFromString(String? value) {
  return switch (value) {
    'paid' => PaymentStatus.paid,
    'failed' => PaymentStatus.failed,
    _ => PaymentStatus.pending,
  };
}
String paymentStatusToString(PaymentStatus status) => status.name;

class AppUser {
  AppUser({required this.id, required this.fullName, required this.email, required this.phone, required this.role, required this.createdAt});
  final String id; final String fullName; final String email; final String phone; final UserRole role; final DateTime createdAt;
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(id: json['id'] as String, fullName: json['full_name'] as String? ?? '', email: json['email'] as String? ?? '', phone: json['phone'] as String? ?? '', role: userRoleFromString(json['role'] as String?), createdAt: DateTime.parse(json['created_at'] as String));
  Map<String, dynamic> toJson() => {'id': id,'full_name': fullName,'email': email,'phone': phone,'role': userRoleToString(role),'created_at': createdAt.toIso8601String()};
}

class ProviderProfile {
  ProviderProfile({required this.id, required this.userId, required this.parkingName, required this.address, required this.latitude, required this.longitude, required this.capacity, required this.parkingPhoto, required this.ktpPhoto, required this.verificationStatus, required this.createdAt});
  final String id; final String userId; final String parkingName; final String address; final double latitude; final double longitude; final int capacity; final String parkingPhoto; final String ktpPhoto; final VerificationStatus verificationStatus; final DateTime createdAt;
  factory ProviderProfile.fromJson(Map<String, dynamic> json) => ProviderProfile(id: json['id'] as String, userId: json['user_id'] as String, parkingName: json['parking_name'] as String? ?? '', address: json['address'] as String? ?? '', latitude: (json['latitude'] as num?)?.toDouble() ?? 0, longitude: (json['longitude'] as num?)?.toDouble() ?? 0, capacity: (json['capacity'] as num?)?.toInt() ?? 0, parkingPhoto: json['parking_photo'] as String? ?? '', ktpPhoto: json['ktp_photo'] as String? ?? '', verificationStatus: verificationStatusFromString(json['verification_status'] as String?), createdAt: DateTime.parse(json['created_at'] as String));
}

class ParkingLocation {
  ParkingLocation({required this.id, required this.providerId, required this.parkingName, required this.address, required this.latitude, required this.longitude, required this.totalSlots, required this.availableSlots, required this.parkingPrice, required this.createdAt});
  final String id; final String providerId; final String parkingName; final String address; final double latitude; final double longitude; final int totalSlots; final int availableSlots; final double parkingPrice; final DateTime createdAt;
  factory ParkingLocation.fromJson(Map<String, dynamic> json) => ParkingLocation(id: json['id'] as String, providerId: json['provider_id'] as String, parkingName: json['parking_name'] as String? ?? '', address: json['address'] as String? ?? '', latitude: (json['latitude'] as num?)?.toDouble() ?? 0, longitude: (json['longitude'] as num?)?.toDouble() ?? 0, totalSlots: (json['total_slots'] as num?)?.toInt() ?? 0, availableSlots: (json['available_slots'] as num?)?.toInt() ?? 0, parkingPrice: (json['parking_price'] as num?)?.toDouble() ?? 0, createdAt: DateTime.parse(json['created_at'] as String));
}

class Vehicle { Vehicle({required this.id, required this.userId, required this.plateNumber, required this.vehicleType, required this.createdAt}); final String id; final String userId; final String plateNumber; final String vehicleType; final DateTime createdAt; factory Vehicle.fromJson(Map<String, dynamic> json)=>Vehicle(id: json['id'] as String, userId: json['user_id'] as String, plateNumber: json['plate_number'] as String? ?? '', vehicleType: json['vehicle_type'] as String? ?? '', createdAt: DateTime.parse(json['created_at'] as String)); }
class Booking { Booking({required this.id, required this.userId, required this.vehicleId, required this.parkingLocationId, required this.bookingTime, required this.parkingDuration, required this.status, required this.createdAt}); final String id; final String userId; final String vehicleId; final String parkingLocationId; final DateTime bookingTime; final String parkingDuration; final BookingStatus status; final DateTime createdAt; factory Booking.fromJson(Map<String, dynamic> json)=>Booking(id: json['id'] as String, userId: json['user_id'] as String, vehicleId: json['vehicle_id'] as String, parkingLocationId: json['parking_location_id'] as String, bookingTime: DateTime.parse(json['booking_time'] as String), parkingDuration: json['parking_duration'] as String? ?? '', status: bookingStatusFromString(json['status'] as String?), createdAt: DateTime.parse(json['created_at'] as String)); }
class Ticket { Ticket({required this.id, required this.bookingId, required this.qrCode, required this.paymentStatus, required this.entryTime, required this.exitTime, required this.createdAt}); final String id; final String bookingId; final String qrCode; final PaymentStatus paymentStatus; final DateTime? entryTime; final DateTime? exitTime; final DateTime createdAt; factory Ticket.fromJson(Map<String, dynamic> json)=>Ticket(id: json['id'] as String, bookingId: json['booking_id'] as String, qrCode: json['qr_code'] as String? ?? '', paymentStatus: paymentStatusFromString(json['payment_status'] as String?), entryTime: json['entry_time'] == null ? null : DateTime.parse(json['entry_time'] as String), exitTime: json['exit_time'] == null ? null : DateTime.parse(json['exit_time'] as String), createdAt: DateTime.parse(json['created_at'] as String)); }
class Payment { Payment({required this.id, required this.bookingId, required this.amount, required this.paymentMethod, required this.paymentStatus, required this.paidAt}); final String id; final String bookingId; final double amount; final String paymentMethod; final PaymentStatus paymentStatus; final DateTime? paidAt; factory Payment.fromJson(Map<String, dynamic> json)=>Payment(id: json['id'] as String, bookingId: json['booking_id'] as String, amount: (json['amount'] as num?)?.toDouble() ?? 0, paymentMethod: json['payment_method'] as String? ?? '', paymentStatus: paymentStatusFromString(json['payment_status'] as String?), paidAt: json['paid_at'] == null ? null : DateTime.parse(json['paid_at'] as String)); }
class NotificationItem { NotificationItem({required this.id, required this.userId, required this.title, required this.message, required this.isRead, required this.createdAt}); final String id; final String userId; final String title; final String message; final bool isRead; final DateTime createdAt; factory NotificationItem.fromJson(Map<String, dynamic> json)=>NotificationItem(id: json['id'] as String, userId: json['user_id'] as String, title: json['title'] as String? ?? '', message: json['message'] as String? ?? '', isRead: json['is_read'] as bool? ?? false, createdAt: DateTime.parse(json['created_at'] as String)); }
