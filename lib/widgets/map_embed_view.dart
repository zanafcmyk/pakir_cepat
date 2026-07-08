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
    this.markers = const [],
  });

  final String title;
  final String embedUrl;
  final double latitude;
  final double longitude;
  final double height;
  final String? locationQuery;
  final List<MapEmbedMarker> markers;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);
    final mapMarkers = markers.isEmpty
        ? [
            MapEmbedMarker(
              id: 'active',
              title: title,
              latitude: latitude,
              longitude: longitude,
              isSelected: true,
            ),
          ]
        : markers;
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
                  userAgentPackageName: 'com.ti23a4.parkircepat',
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                MarkerLayer(
                  markers: mapMarkers
                      .map(
                        (marker) => Marker(
                          point: LatLng(marker.latitude, marker.longitude),
                          width: marker.isSelected ? 68 : 56,
                          height: marker.isSelected ? 68 : 56,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: marker.onTap,
                            child: _MapPin(
                              color: marker.color,
                              isSelected: marker.isSelected,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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
                        _primaryLocationText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _coordinateText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF0F766E),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
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

  String get _primaryLocationText {
    final query = _mapSearchQuery;
    if (query != null && query.isNotEmpty) {
      return query;
    }
    return 'Koordinat titik parkir';
  }

  String get _coordinateText {
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

class MapEmbedMarker {
  const MapEmbedMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.color = const Color(0xFF10B981),
    this.isSelected = false,
    this.onTap,
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.isSelected});

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isSelected ? 0.36 : 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.location_on_rounded,
          color: isSelected ? Colors.white : color,
          size: isSelected ? 38 : 34,
        ),
      ),
    );
  }
}
