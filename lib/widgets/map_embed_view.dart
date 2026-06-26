import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapEmbedView extends StatelessWidget {
  const MapEmbedView({
    super.key,
    required this.title,
    required this.embedUrl,
    required this.latitude,
    required this.longitude,
    this.height = 240,
    this.locationQuery,
  });

  final String title;
  final String embedUrl;
  final double latitude;
  final double longitude;
  final double height;
  final String? locationQuery;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags:
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.parkircepat.parkir_cepat',
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 56,
                      height: 56,
                      child: const _MapPin(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF1F6BFF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _locationText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _locationText {
    final query = _mapSearchQuery;
    if (query != null && query.isNotEmpty) {
      return query;
    }
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String? get _mapSearchQuery {
    final explicitQuery = locationQuery?.trim();
    if (explicitQuery != null && explicitQuery.isNotEmpty) {
      return explicitQuery;
    }
    final uri = Uri.tryParse(embedUrl);
    final embeddedQuery = uri?.queryParameters['q']?.trim();
    if (embeddedQuery != null && embeddedQuery.isNotEmpty) {
      return embeddedQuery;
    }
    return null;
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.location_on_rounded,
          color: Color(0xFF10B981),
          size: 34,
        ),
      ),
    );
  }
}
