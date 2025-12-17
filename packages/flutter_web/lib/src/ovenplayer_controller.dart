/// Controller for OvenPlayer
library;

import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'ovenplayer_config.dart';
import 'ovenplayer_events.dart';
import 'ovenplayer_js_interop.dart';

/// Controller for managing OvenPlayer instance
class OvenPlayerController extends ChangeNotifier {
  /// Configuration for the player
  final OvenPlayerConfig config;

  /// JavaScript player instance
  OvenPlayerInstanceJS? _playerInstance;

  /// Container ID for the player
  String? _containerId;

  /// Whether the player is initialized
  bool _isInitialized = false;

  /// Callback functions for events
  VoidCallback? onReady;
  ValueChanged<OvenPlayerState>? onStateChanged;
  ValueChanged<OvenPlayerError>? onError;
  ValueChanged<OvenPlayerMetadata>? onMetaChanged;
  ValueChanged<OvenPlayerTimeData>? onTime;
  ValueChanged<OvenPlayerBufferData>? onBufferChanged;
  ValueChanged<OvenPlayerVolumeData>? onVolumeChanged;
  ValueChanged<OvenPlayerSourceData>? onSourceChanged;
  ValueChanged<OvenPlayerQualityData>? onQualityLevelChanged;
  VoidCallback? onComplete;

  OvenPlayerController({required this.config});

  /// Whether the player is initialized
  bool get isInitialized => _isInitialized;

  /// Container ID
  String? get containerId => _containerId;

  /// Initialize the player with a container ID
  void initialize(String containerId) {
    if (_isInitialized) {
      debugPrint('OvenPlayer already initialized');
      return;
    }

    _containerId = containerId;

    try {
      // Get the container element
      final element = OvenPlayerJSHelper.getElementById(containerId);
      if (element == null) {
        debugPrint('Container element not found: $containerId');
        return;
      }

      // Convert config to JS object
      final jsConfig = OvenPlayerJSHelper.mapToJSObject(config.toJson());

      // Create player instance
      _playerInstance = OvenPlayerJS.create(element.jsify(), jsConfig);

      // Set up event listeners
      _setupEventListeners();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing OvenPlayer: $e');
      rethrow;
    }
  }

  /// Set up event listeners for player events
  void _setupEventListeners() {
    if (_playerInstance == null) return;

    // Ready event
    _playerInstance!.on(
      'ready'.toJS,
      (() {
        onReady?.call();
      }).toJS,
    );

    // State changed event
    _playerInstance!.on(
      'stateChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onStateChanged != null) {
          final state = _parseState((data as JSString).toDart);
          onStateChanged?.call(state);
        }
      }).toJS,
    );

    // Error event
    _playerInstance!.on(
      'error'.toJS,
      ((JSAny? data) {
        if (data != null && onError != null) {
          final errorData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (errorData is Map<String, dynamic>) {
            onError?.call(OvenPlayerError.fromJson(errorData));
          }
        }
      }).toJS,
    );

    // Meta changed event
    _playerInstance!.on(
      'metaChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onMetaChanged != null) {
          final metaData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (metaData is Map<String, dynamic>) {
            onMetaChanged?.call(OvenPlayerMetadata.fromJson(metaData));
          }
        }
      }).toJS,
    );

    // Time event
    _playerInstance!.on(
      'time'.toJS,
      ((JSAny? data) {
        if (data != null && onTime != null) {
          final timeData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (timeData is Map<String, dynamic>) {
            onTime?.call(OvenPlayerTimeData.fromJson(timeData));
          }
        }
      }).toJS,
    );

    // Buffer changed event
    _playerInstance!.on(
      'bufferChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onBufferChanged != null) {
          final bufferData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (bufferData is Map<String, dynamic>) {
            onBufferChanged?.call(OvenPlayerBufferData.fromJson(bufferData));
          }
        }
      }).toJS,
    );

    // Volume changed event
    _playerInstance!.on(
      'volumeChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onVolumeChanged != null) {
          final volumeData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (volumeData is Map<String, dynamic>) {
            onVolumeChanged?.call(OvenPlayerVolumeData.fromJson(volumeData));
          }
        }
      }).toJS,
    );

    // Source changed event
    _playerInstance!.on(
      'sourceChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onSourceChanged != null) {
          final sourceData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (sourceData is Map<String, dynamic>) {
            onSourceChanged?.call(OvenPlayerSourceData.fromJson(sourceData));
          }
        }
      }).toJS,
    );

    // Quality level changed event
    _playerInstance!.on(
      'qualityLevelChanged'.toJS,
      ((JSAny? data) {
        if (data != null && onQualityLevelChanged != null) {
          final qualityData = OvenPlayerJSHelper.jsAnyToDart(data);
          if (qualityData is Map<String, dynamic>) {
            onQualityLevelChanged?.call(OvenPlayerQualityData.fromJson(qualityData));
          }
        }
      }).toJS,
    );

    // Complete event
    _playerInstance!.on(
      'complete'.toJS,
      (() {
        onComplete?.call();
      }).toJS,
    );
  }

  /// Parse state string to enum
  OvenPlayerState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'idle':
        return OvenPlayerState.idle;
      case 'loading':
        return OvenPlayerState.loading;
      case 'playing':
        return OvenPlayerState.playing;
      case 'paused':
        return OvenPlayerState.paused;
      case 'error':
        return OvenPlayerState.error;
      case 'complete':
        return OvenPlayerState.complete;
      default:
        return OvenPlayerState.idle;
    }
  }

  /// Play the video
  void play() {
    _playerInstance?.play();
  }

  /// Pause the video
  void pause() {
    _playerInstance?.pause();
  }

  /// Stop the video
  void stop() {
    _playerInstance?.stop();
  }

  /// Seek to a specific position in seconds
  void seek(double position) {
    _playerInstance?.seek(position.toJS);
  }

  /// Get current playback position in seconds
  double getPosition() {
    return _playerInstance?.getPosition().toDartDouble ?? 0.0;
  }

  /// Get video duration in seconds
  double getDuration() {
    return _playerInstance?.getDuration().toDartDouble ?? 0.0;
  }

  /// Get current state
  String getState() {
    return _playerInstance?.getState().toDart ?? 'idle';
  }

  /// Set volume (0-100)
  void setVolume(int volume) {
    _playerInstance?.setVolume(volume.toJS);
  }

  /// Get current volume (0-100)
  int getVolume() {
    return _playerInstance?.getVolume().toDartInt ?? 100;
  }

  /// Set mute state
  void setMute(bool mute) {
    _playerInstance?.setMute(mute.toJS);
  }

  /// Get mute state
  bool getMute() {
    return _playerInstance?.getMute().toDart ?? false;
  }

  /// Get current source index
  int getCurrentSource() {
    return _playerInstance?.getCurrentSource().toDartInt ?? 0;
  }

  /// Set current source by index
  void setCurrentSource(int index) {
    _playerInstance?.setCurrentSource(index.toJS);
  }

  /// Get list of quality levels
  List<OvenPlayerQualityLevel> getQualityLevels() {
    final levels = <OvenPlayerQualityLevel>[];
    final jsLevels = _playerInstance?.getQualityLevels();
    
    if (jsLevels != null) {
      for (var i = 0; i < jsLevels.length; i++) {
        final jsLevel = jsLevels.getProperty(i.toJS);
        if (jsLevel != null) {
          final levelData = OvenPlayerJSHelper.jsObjectToMap(jsLevel as JSObject);
          levels.add(OvenPlayerQualityLevel.fromJson(levelData));
        }
      }
    }
    
    return levels;
  }

  /// Get current quality index
  int getCurrentQuality() {
    return _playerInstance?.getCurrentQuality().toDartInt ?? 0;
  }

  /// Set current quality by index (use -1 for auto)
  void setCurrentQuality(int index) {
    _playerInstance?.setCurrentQuality(index.toJS);
  }

  /// Toggle fullscreen
  void toggleFullScreen() {
    _playerInstance?.toggleFullScreen();
  }

  /// Check if fullscreen
  bool getFullscreen() {
    return _playerInstance?.getFullscreen().toDart ?? false;
  }

  /// Show controls
  void showControls() {
    _playerInstance?.showControls();
  }

  /// Hide controls
  void hideControls() {
    _playerInstance?.hideControls();
  }

  @override
  void dispose() {
    _playerInstance?.remove();
    _playerInstance = null;
    _isInitialized = false;
    super.dispose();
  }
}
