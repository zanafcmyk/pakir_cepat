import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapEmbedView extends StatelessWidget {
  const MapEmbedView({
    super.key,
    required this.title,
    required this.embedUrl,
    required this.latitude,
    required this.longitude,
    this.height = 220,
  });

  final String title;
  final String embedUrl;
  final double latitude;
  final double longitude;
  final double height;

  Uri get _mapsUri => Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

  Future<void> _openMaps() async {
    await launchUrl(_mapsUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(color: Color(0xFFF4F7FB)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.map_rounded, color: Color(0xFF1F6BFF), size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Latitude: $latitude\nLongitude: $longitude',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.45,
                  ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Buka di Google Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
