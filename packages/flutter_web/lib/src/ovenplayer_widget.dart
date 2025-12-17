/// Widget for displaying OvenPlayer
library;

import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'ovenplayer_controller.dart';

/// Widget that displays OvenPlayer
class OvenPlayerWidget extends StatefulWidget {
  /// Controller for the player
  final OvenPlayerController controller;

  /// Optional width
  final double? width;

  /// Optional height
  final double? height;

  const OvenPlayerWidget({
    super.key,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  State<OvenPlayerWidget> createState() => _OvenPlayerWidgetState();
}

class _OvenPlayerWidgetState extends State<OvenPlayerWidget> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'ovenplayer-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the view factory for the HTML element
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final element = web.document.createElement('div') as web.HTMLDivElement;
        element.id = _viewId;
        element.style.width = '100%';
        element.style.height = '100%';
        return element;
      },
    );

    // Initialize the player after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initialize(_viewId);
    });
  }

  @override
  void dispose() {
    // Controller disposal is handled by the controller itself
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
