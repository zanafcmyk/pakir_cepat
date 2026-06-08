import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderMapEmbedView extends StatelessWidget {
  const ProviderMapEmbedView({
    super.key,
    required this.embedUrl,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.onSelected,
    this.isSelected = false,
    this.height = 320,
  });

  final String embedUrl;
  final String locationName;
  final double latitude;
  final double longitude;
  final VoidCallback onSelected;
  final bool isSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: height,
          width: double.infinity,
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_rounded, color: Color(0xFF2563EB), size: 42),
              const SizedBox(height: 14),
              Text(
                locationName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Latitude: $latitude\nLongitude: $longitude',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Buka di Google Maps'),
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                Text(
                  'Titik lokasi dipilih: $locationName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
