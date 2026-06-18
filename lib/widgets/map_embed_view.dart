import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_embed_view_platform.dart';

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
    if (supportsMapIframe && _canEmbedMap(embedUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: buildPlatformMapEmbed(embedUrl),
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.map_rounded, color: Color(0xFF1F6BFF), size: 34),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _fallbackLocationText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openGoogleMaps(latitude, longitude),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Buka di Google Maps'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canEmbedMap(String value) {
    return value.startsWith('https://www.google.com/maps/embed?') ||
        (value.startsWith('https://maps.google.com/maps?') &&
            value.contains('output=embed'));
  }

  String get _fallbackLocationText {
    final query = _mapSearchQuery;
    if (query != null && query.isNotEmpty) {
      return query;
    }
    return 'Latitude: $latitude\nLongitude: $longitude';
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

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final query = _mapSearchQuery;
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query == null || query.isEmpty ? '$latitude,$longitude' : query,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
