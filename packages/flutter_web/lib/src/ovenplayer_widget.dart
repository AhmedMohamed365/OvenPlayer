import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'ovenplayer_config.dart';
import 'ovenplayer_controller.dart';

/// Flutter widget for OvenPlayer
class OvenPlayer extends StatefulWidget {
  /// Player configuration
  final OvenPlayerConfig config;

  /// Player controller for controlling playback
  final OvenPlayerController? controller;

  /// Callback when player is ready
  final VoidCallback? onReady;

  /// Callback when an error occurs
  final Function(dynamic error)? onError;

  /// Width of the player (defaults to parent width)
  final double? width;

  /// Height of the player (defaults to 16:9 aspect ratio)
  final double? height;

  const OvenPlayer({
    Key? key,
    required this.config,
    this.controller,
    this.onReady,
    this.onError,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<OvenPlayer> createState() => _OvenPlayerState();
}

class _OvenPlayerState extends State<OvenPlayer> {
  late final OvenPlayerController _controller;
  late final String _viewId;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    
    // Use provided controller or create a new one
    _viewId = 'ovenplayer-${DateTime.now().millisecondsSinceEpoch}';
    _controller = widget.controller ?? OvenPlayerController(_viewId);
    
    // Register the view type
    _registerViewFactory();
    
    // Initialize player after a short delay to ensure DOM is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.initialize(widget.config);
        _setupListeners();
      }
    });
  }

  void _registerViewFactory() {
    if (_isRegistered) return;
    
    // Register a platform view factory for the player container
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        return _createPlayerContainer();
      },
    );
    
    _isRegistered = true;
  }

  web.HTMLDivElement _createPlayerContainer() {
    // Create a div element for the player using web package
    final element = web.document.createElement('div') as web.HTMLDivElement;
    element.id = _viewId;
    element.style.width = '100%';
    element.style.height = '100%';
    element.style.position = 'relative';
    return element;
  }

  void _setupListeners() {
    _controller.onReady.listen((_) {
      if (mounted && widget.onReady != null) {
        widget.onReady!();
      }
    });

    _controller.onError.listen((error) {
      if (mounted && widget.onError != null) {
        widget.onError!(error);
      }
    });
  }

  @override
  void didUpdateWidget(OvenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reinitialize if config changes
    if (oldWidget.config != widget.config) {
      _controller.initialize(widget.config);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // Only dispose if we created the controller
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? _calculateDefaultHeight(),
      child: HtmlElementView(
        viewType: _viewId,
      ),
    );
  }

  double _calculateDefaultHeight() {
    // Default to 16:9 aspect ratio
    if (widget.width != null) {
      return widget.width! * 9 / 16;
    }
    // If no width is specified, use a reasonable default
    return 400.0;
  }
}
