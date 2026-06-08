import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ProviderMapEmbedView extends StatefulWidget {
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
  State<ProviderMapEmbedView> createState() => _ProviderMapEmbedViewState();
}

class _ProviderMapEmbedViewState extends State<ProviderMapEmbedView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'provider-map-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return web.HTMLIFrameElement()
        ..src = widget.embedUrl
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..allowFullscreen = true
        ..setAttribute('loading', 'lazy')
        ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                HtmlElementView(viewType: _viewType),
                Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: widget.onSelected),
                ),
              ],
            ),
          ),
        ),
        if (widget.isSelected) ...[
          const SizedBox(height: 10),
          Text(
            'Titik lokasi dipilih: ${widget.locationName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
