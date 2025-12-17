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
  web.HTMLDivElement? _element;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'ovenplayer-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the view factory for the HTML element
    if (!_isRegistered) {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) {
          _element = web.document.createElement('div') as web.HTMLDivElement;
          _element!.id = _viewId;
          _element!.style.width = '100%';
          _element!.style.height = '100%';
          _element!.style.backgroundColor = 'black';
          
          // Initialize player after element is created
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_element != null) {
              widget.controller.initializeWithElement(_element!);
            }
          });
          
          return _element!;
        },
      );
      _isRegistered = true;
    }
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
