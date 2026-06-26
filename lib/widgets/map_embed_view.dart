import 'package:flutter/material.dart';

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
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _InlineMapPreviewPainter()),
          const Center(
            child: Icon(
              Icons.location_on_rounded,
              color: Color(0xFF10B981),
              size: 58,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                    const SizedBox(height: 6),
                    Text(
                      _fallbackLocationText,
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
    );
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
}

class _InlineMapPreviewPainter extends StatelessWidget {
  const _InlineMapPreviewPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _InlineMapPainter());
  }
}

class _InlineMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEFF6FF);
    canvas.drawRect(Offset.zero & size, background);

    final parkPaint = Paint()..color = const Color(0xFFDDF7EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          -20,
          size.width * 0.28,
          size.height * 0.62,
        ),
        const Radius.circular(36),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -20,
          size.height * 0.2,
          size.width * 0.34,
          size.height * 0.5,
        ),
        const Radius.circular(34),
      ),
      Paint()..color = const Color(0xFFE4ECFB),
    );

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final mainPath = Path()
      ..moveTo(-20, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.55,
        size.width * 0.54,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.68,
        size.width + 20,
        size.height * 0.36,
      );
    canvas.drawPath(mainPath, roadPaint);

    canvas.drawLine(
      Offset(size.width * 0.14, -10),
      Offset(size.width * 0.38, size.height + 10),
      smallRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, -10),
      Offset(size.width * 0.44, size.height + 10),
      smallRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
