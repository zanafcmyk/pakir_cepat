import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../models/app_models.dart';

class CustomerLocationService {
  const CustomerLocationService();

  static const _citySpeedKmh = 24.0;

  Future<List<ParkingLot>> withTravelEstimates(List<ParkingLot> lots) async {
    if (lots.isEmpty) {
      return lots;
    }

    final position = await _currentPosition();
    if (position == null) {
      return lots;
    }

    return [
      for (final lot in lots)
        _withTravelEstimate(
          lot,
          customerLatitude: position.latitude,
          customerLongitude: position.longitude,
        ),
    ];
  }

  Future<Position?> _currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return lastPosition;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
  }

  ParkingLot _withTravelEstimate(
    ParkingLot lot, {
    required double customerLatitude,
    required double customerLongitude,
  }) {
    if (!_hasValidCoordinates(lot.latitude, lot.longitude)) {
      return lot;
    }

    final distanceKm = _distanceKm(
      customerLatitude,
      customerLongitude,
      lot.latitude,
      lot.longitude,
    );
    final etaMinutes = math.max(1, (distanceKm / _citySpeedKmh * 60).round());

    return lot.copyWith(
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      etaMinutes: etaMinutes,
    );
  }

  bool _hasValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  double _distanceKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(endLatitude - startLatitude);
    final dLon = _radians(endLongitude - startLongitude);
    final lat1 = _radians(startLatitude);
    final lat2 = _radians(endLatitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
