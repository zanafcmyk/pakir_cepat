import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

const bool supportsMapIframe = true;

Widget buildPlatformMapEmbed(String embedUrl) {
  final viewType = 'google-map-${embedUrl.hashCode}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = web.HTMLIFrameElement()
      ..src = embedUrl
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..referrerPolicy = 'no-referrer-when-downgrade';
    iframe.setAttribute('loading', 'lazy');
    return iframe;
  });
  return HtmlElementView(viewType: viewType);
}
