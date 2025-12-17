/// Controller for OvenPlayer
library;

import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
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

  /// Initialize the player with a container ID (looks up element in DOM)
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
        final errorMsg = 'Container element not found: $containerId';
        debugPrint(errorMsg);
        onError?.call(OvenPlayerError(
          code: -1,
          message: errorMsg,
        ));
        return;
      }

      _initializeWithElementInternal(element);
    } catch (e) {
      final errorMsg = 'Error initializing OvenPlayer: $e';
      debugPrint(errorMsg);
      onError?.call(OvenPlayerError(
        code: -2,
        message: errorMsg,
      ));
      rethrow;
    }
  }

  /// Initialize the player with a direct element reference
  void initializeWithElement(web.Element element) {
    if (_isInitialized) {
      debugPrint('OvenPlayer already initialized');
      return;
    }

    _containerId = element.id;

    try {
      _initializeWithElementInternal(element);
    } catch (e) {
      final errorMsg = 'Error initializing OvenPlayer: $e';
      debugPrint(errorMsg);
      onError?.call(OvenPlayerError(
        code: -2,
        message: errorMsg,
      ));
      rethrow;
    }
  }

  /// Internal initialization with element
  void _initializeWithElementInternal(web.Element element) {
    // Convert config to JS object
    final jsConfig = OvenPlayerJSHelper.mapToJSObject(config.toJson());

    // Create player instance
    _playerInstance = OvenPlayerJS.create(element.jsify()!, jsConfig);

    // Set up event listeners
    _setupEventListeners();

    _isInitialized = true;
    notifyListeners();
  }

  /// Reinitialize the player (useful for recovering from errors)
  Future<void> reinitialize() async {
    if (_containerId == null) {
      debugPrint('Cannot reinitialize: no container ID');
      return;
    }
    
    final containerId = _containerId!;
    dispose();
    
    // Wait a bit for cleanup
    await Future.delayed(const Duration(milliseconds: 100));
    
    initialize(containerId);
  }

  /// Store event listener references for cleanup
  final Map<String, JSFunction> _eventListeners = {};

  /// Set up event listeners for player events
  void _setupEventListeners() {
    if (_playerInstance == null) return;

    // Ready event
    final readyListener = (() {
      onReady?.call();
    }).toJS;
    _eventListeners['ready'] = readyListener;
    _playerInstance!.on('ready'.toJS, readyListener);

    // State changed event
    final stateChangedListener = ((JSAny? data) {
      if (data != null && onStateChanged != null) {
        try {
          String stateStr;
          if (data.typeofEquals('string')) {
            stateStr = (data as JSString).toDart;
          } else {
            // It might be a JSObject with a state property or the state itself
            final dartData = OvenPlayerJSHelper.jsAnyToDart(data);
            if (dartData is String) {
              stateStr = dartData;
            } else if (dartData is Map<String, dynamic> && dartData.containsKey('state')) {
              stateStr = dartData['state'].toString();
            } else {
              stateStr = dartData.toString();
            }
          }
          final state = _parseState(stateStr);
          onStateChanged?.call(state);
        } catch (e) {
          debugPrint('Error parsing state: $e');
        }
      }
    }).toJS;
    _eventListeners['stateChanged'] = stateChangedListener;
    _playerInstance!.on('stateChanged'.toJS, stateChangedListener);

    // Error event
    final errorListener = ((JSAny? data) {
      if (data != null && onError != null) {
        final errorData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (errorData is Map<String, dynamic>) {
          onError?.call(OvenPlayerError.fromJson(errorData));
        }
      }
    }).toJS;
    _eventListeners['error'] = errorListener;
    _playerInstance!.on('error'.toJS, errorListener);

    // Meta changed event
    final metaChangedListener = ((JSAny? data) {
      if (data != null && onMetaChanged != null) {
        final metaData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (metaData is Map<String, dynamic>) {
          onMetaChanged?.call(OvenPlayerMetadata.fromJson(metaData));
        }
      }
    }).toJS;
    _eventListeners['metaChanged'] = metaChangedListener;
    _playerInstance!.on('metaChanged'.toJS, metaChangedListener);

    // Time event
    final timeListener = ((JSAny? data) {
      if (data != null && onTime != null) {
        final timeData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (timeData is Map<String, dynamic>) {
          onTime?.call(OvenPlayerTimeData.fromJson(timeData));
        }
      }
    }).toJS;
    _eventListeners['time'] = timeListener;
    _playerInstance!.on('time'.toJS, timeListener);

    // Buffer changed event
    final bufferChangedListener = ((JSAny? data) {
      if (data != null && onBufferChanged != null) {
        final bufferData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (bufferData is Map<String, dynamic>) {
          onBufferChanged?.call(OvenPlayerBufferData.fromJson(bufferData));
        }
      }
    }).toJS;
    _eventListeners['bufferChanged'] = bufferChangedListener;
    _playerInstance!.on('bufferChanged'.toJS, bufferChangedListener);

    // Volume changed event
    final volumeChangedListener = ((JSAny? data) {
      if (data != null && onVolumeChanged != null) {
        final volumeData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (volumeData is Map<String, dynamic>) {
          onVolumeChanged?.call(OvenPlayerVolumeData.fromJson(volumeData));
        }
      }
    }).toJS;
    _eventListeners['volumeChanged'] = volumeChangedListener;
    _playerInstance!.on('volumeChanged'.toJS, volumeChangedListener);

    // Source changed event
    final sourceChangedListener = ((JSAny? data) {
      if (data != null && onSourceChanged != null) {
        final sourceData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (sourceData is Map<String, dynamic>) {
          onSourceChanged?.call(OvenPlayerSourceData.fromJson(sourceData));
        }
      }
    }).toJS;
    _eventListeners['sourceChanged'] = sourceChangedListener;
    _playerInstance!.on('sourceChanged'.toJS, sourceChangedListener);

    // Quality level changed event
    final qualityLevelChangedListener = ((JSAny? data) {
      if (data != null && onQualityLevelChanged != null) {
        final qualityData = OvenPlayerJSHelper.jsAnyToDart(data);
        if (qualityData is Map<String, dynamic>) {
          onQualityLevelChanged?.call(OvenPlayerQualityData.fromJson(qualityData));
        }
      }
    }).toJS;
    _eventListeners['qualityLevelChanged'] = qualityLevelChangedListener;
    _playerInstance!.on('qualityLevelChanged'.toJS, qualityLevelChangedListener);

    // Complete event
    final completeListener = (() {
      onComplete?.call();
    }).toJS;
    _eventListeners['complete'] = completeListener;
    _playerInstance!.on('complete'.toJS, completeListener);
  }

  /// Clean up event listeners
  void _cleanupEventListeners() {
    if (_playerInstance == null) return;
    
    _eventListeners.forEach((eventName, listener) {
      _playerInstance!.off(eventName.toJS, listener);
    });
    _eventListeners.clear();
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
      final levelsList = jsLevels.toDart;
      for (var i = 0; i < levelsList.length; i++) {
        final jsLevel = levelsList[i];
        final levelData = OvenPlayerJSHelper.jsObjectToMap(jsLevel);
        levels.add(OvenPlayerQualityLevel.fromJson(levelData));
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

  /// Check if player is playing
  bool get isPlaying => getState().toLowerCase() == 'playing';

  /// Check if player is paused
  bool get isPaused => getState().toLowerCase() == 'paused';

  /// Check if player is in loading state
  bool get isLoading => getState().toLowerCase() == 'loading';

  /// Check if player has error
  bool get hasError => getState().toLowerCase() == 'error';

  /// Toggle play/pause
  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Get or set playback rate
  double get playbackRate {
    // OvenPlayer doesn't expose this directly, return 1.0 as default
    return 1.0;
  }

  /// Set playback rate (if supported by underlying video element)
  set playbackRate(double rate) {
    // Note: This would require additional JS interop to access video element
    debugPrint('Playback rate control not yet implemented in JS interop');
  }

  @override
  void dispose() {
    _cleanupEventListeners();
    _playerInstance?.remove();
    _playerInstance = null;
    _isInitialized = false;
    super.dispose();
  }
}
