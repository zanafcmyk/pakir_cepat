import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class MapEmbedView extends StatefulWidget {
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

  @override
  State<MapEmbedView> createState() => _MapEmbedViewState();
}

class _MapEmbedViewState extends State<MapEmbedView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'google-map-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = widget.embedUrl
        ..referrerPolicy = 'no-referrer-when-downgrade';
      iframe.style
        ..border = '0'
        ..width = '100%'
        ..height = '100%';
      iframe.setAttribute('loading', 'lazy');
      iframe.setAttribute('allowfullscreen', 'true');
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedUrl.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(child: Text(widget.title)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
