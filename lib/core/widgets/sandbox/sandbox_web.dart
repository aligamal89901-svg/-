import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredViews = {};

Widget buildPlatformSandbox({
  required String htmlContent,
  required String uniqueId,
}) {
  final viewType = 'nasaq-sandbox-$uniqueId';

  if (!_registeredViews.contains(viewType)) {
    _registeredViews.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
        iframe.srcdoc = htmlContent.toJS;
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        iframe.style.backgroundColor = 'transparent';
        return iframe;
      },
    );
  }

  return HtmlElementView(viewType: viewType);
}
