import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'ovenplayer_config.dart';
import 'ovenplayer_events.dart';

/// Controller for managing OvenPlayer instance
class OvenPlayerController {
  final String _containerId;
  JSObject? _playerInstance;
  bool _isInitialized = false;

  // Event stream controllers
  final _readyController = StreamController<void>.broadcast();
  final _stateChangedController = StreamController<StateChangedEvent>.broadcast();
  final _metaChangedController = StreamController<MetaChangedEvent>.broadcast();
  final _timeController = StreamController<TimeEvent>.broadcast();
  final _bufferChangedController = StreamController<BufferChangedEvent>.broadcast();
  final _volumeChangedController = StreamController<VolumeChangedEvent>.broadcast();
  final _muteController = StreamController<MuteEvent>.broadcast();
  final _qualityLevelChangedController = StreamController<QualityLevelChangedEvent>.broadcast();
  final _sourceChangedController = StreamController<SourceChangedEvent>.broadcast();
  final _playlistChangedController = StreamController<PlaylistChangedEvent>.broadcast();
  final _fullscreenChangedController = StreamController<FullscreenChangedEvent>.broadcast();
  final _errorController = StreamController<ErrorEvent>.broadcast();
  final _seekController = StreamController<SeekEvent>.broadcast();
  final _resizedController = StreamController<ResizedEvent>.broadcast();
  final _playbackRateChangedController = StreamController<PlaybackRateChangedEvent>.broadcast();
  final _contentMetaDataController = StreamController<ContentMetaDataEvent>.broadcast();

  // Public event streams
  Stream<void> get onReady => _readyController.stream;
  Stream<StateChangedEvent> get onStateChanged => _stateChangedController.stream;
  Stream<MetaChangedEvent> get onMetaChanged => _metaChangedController.stream;
  Stream<TimeEvent> get onTime => _timeController.stream;
  Stream<BufferChangedEvent> get onBufferChanged => _bufferChangedController.stream;
  Stream<VolumeChangedEvent> get onVolumeChanged => _volumeChangedController.stream;
  Stream<MuteEvent> get onMute => _muteController.stream;
  Stream<QualityLevelChangedEvent> get onQualityLevelChanged => _qualityLevelChangedController.stream;
  Stream<SourceChangedEvent> get onSourceChanged => _sourceChangedController.stream;
  Stream<PlaylistChangedEvent> get onPlaylistChanged => _playlistChangedController.stream;
  Stream<FullscreenChangedEvent> get onFullscreenChanged => _fullscreenChangedController.stream;
  Stream<ErrorEvent> get onError => _errorController.stream;
  Stream<SeekEvent> get onSeek => _seekController.stream;
  Stream<ResizedEvent> get onResized => _resizedController.stream;
  Stream<PlaybackRateChangedEvent> get onPlaybackRateChanged => _playbackRateChangedController.stream;
  Stream<ContentMetaDataEvent> get onContentMetaData => _contentMetaDataController.stream;

  bool get isInitialized => _isInitialized;

  OvenPlayerController(this._containerId);

  /// Initialize the player with configuration
  void initialize(OvenPlayerConfig config) {
    if (_isInitialized) {
      dispose();
    }

    try {
      // Access the global OvenPlayer object from JavaScript
      final ovenPlayer = _getOvenPlayerGlobal();
      if (ovenPlayer == null) {
        _errorController.add(const ErrorEvent(
          code: 'INIT_ERROR',
          message: 'OvenPlayer JavaScript library not loaded',
        ));
        return;
      }

      // Create player instance
      final configJson = config.toJsonString();
      _playerInstance = _createPlayer(ovenPlayer, _containerId, configJson);

      if (_playerInstance != null) {
        _setupEventListeners();
        _isInitialized = true;
      }
    } catch (e) {
      _errorController.add(ErrorEvent(
        code: 'INIT_ERROR',
        message: 'Failed to initialize OvenPlayer: $e',
        error: e,
      ));
    }
  }

  /// Setup event listeners for player events
  void _setupEventListeners() {
    if (_playerInstance == null) return;

    _registerEvent('ready', (_) => _readyController.add(null));
    _registerEvent('stateChanged', (data) {
      final event = StateChangedEvent.fromJson(_jsObjectToMap(data));
      _stateChangedController.add(event);
    });
    _registerEvent('metaChanged', (data) {
      final event = MetaChangedEvent.fromJson(_jsObjectToMap(data));
      _metaChangedController.add(event);
    });
    _registerEvent('time', (data) {
      final event = TimeEvent.fromJson(_jsObjectToMap(data));
      _timeController.add(event);
    });
    _registerEvent('bufferChanged', (data) {
      final event = BufferChangedEvent.fromJson(_jsObjectToMap(data));
      _bufferChangedController.add(event);
    });
    _registerEvent('volumeChanged', (data) {
      final event = VolumeChangedEvent.fromJson(_jsObjectToMap(data));
      _volumeChangedController.add(event);
    });
    _registerEvent('mute', (data) {
      final event = MuteEvent.fromJson(_jsObjectToMap(data));
      _muteController.add(event);
    });
    _registerEvent('qualityLevelChanged', (data) {
      final event = QualityLevelChangedEvent.fromJson(_jsObjectToMap(data));
      _qualityLevelChangedController.add(event);
    });
    _registerEvent('sourceChanged', (data) {
      final event = SourceChangedEvent.fromJson(_jsObjectToMap(data));
      _sourceChangedController.add(event);
    });
    _registerEvent('playlistChanged', (data) {
      final event = PlaylistChangedEvent.fromJson(_jsObjectToMap(data));
      _playlistChangedController.add(event);
    });
    _registerEvent('fullscreenChanged', (data) {
      final event = FullscreenChangedEvent.fromJson(_jsObjectToMap(data));
      _fullscreenChangedController.add(event);
    });
    _registerEvent('error', (data) {
      final event = ErrorEvent.fromJson(_jsObjectToMap(data));
      _errorController.add(event);
    });
    _registerEvent('seek', (data) {
      final event = SeekEvent.fromJson(_jsObjectToMap(data));
      _seekController.add(event);
    });
    _registerEvent('resized', (data) {
      final event = ResizedEvent.fromJson(_jsObjectToMap(data));
      _resizedController.add(event);
    });
    _registerEvent('playbackRateChanged', (data) {
      final event = PlaybackRateChangedEvent.fromJson(_jsObjectToMap(data));
      _playbackRateChangedController.add(event);
    });
    _registerEvent('contentMetaData', (data) {
      final event = ContentMetaDataEvent.fromJson(_jsObjectToMap(data));
      _contentMetaDataController.add(event);
    });
  }

  /// Register an event listener
  void _registerEvent(String eventName, Function(JSAny?) callback) {
    if (_playerInstance == null) return;
    
    final jsCallback = (JSAny? data) {
      try {
        callback(data);
      } catch (e) {
        _errorController.add(ErrorEvent(
          code: 'EVENT_ERROR',
          message: 'Error handling $eventName event: $e',
          error: e,
        ));
      }
    }.toJS;

    _callPlayerMethod('on', [eventName.toJS, jsCallback]);
  }

  /// Play the media
  void play() {
    _callPlayerMethod('play', []);
  }

  /// Pause the media
  void pause() {
    _callPlayerMethod('pause', []);
  }

  /// Stop the media
  void stop() {
    _callPlayerMethod('stop', []);
  }

  /// Seek to a specific position (in seconds)
  void seek(double position) {
    _callPlayerMethod('seek', [position.toJS]);
  }

  /// Set volume (0-100)
  void setVolume(int volume) {
    _callPlayerMethod('setVolume', [volume.toJS]);
  }

  /// Get current volume
  int getVolume() {
    final result = _callPlayerMethod('getVolume', []);
    return result != null ? (result as JSNumber).toDartInt : 0;
  }

  /// Mute the player
  void setMute(bool mute) {
    _callPlayerMethod('setMute', [mute.toJS]);
  }

  /// Get mute state
  bool getMute() {
    final result = _callPlayerMethod('getMute', []);
    return result != null ? (result as JSBoolean).toDart : false;
  }

  /// Get current position (in seconds)
  double getPosition() {
    final result = _callPlayerMethod('getPosition', []);
    return result != null ? (result as JSNumber).toDartDouble : 0.0;
  }

  /// Get duration (in seconds)
  double getDuration() {
    final result = _callPlayerMethod('getDuration', []);
    return result != null ? (result as JSNumber).toDartDouble : 0.0;
  }

  /// Set current quality level
  void setCurrentQuality(int qualityIndex) {
    _callPlayerMethod('setCurrentQuality', [qualityIndex.toJS]);
  }

  /// Get quality levels
  List<Map<String, dynamic>> getQualityLevels() {
    final result = _callPlayerMethod('getQualityLevels', []);
    if (result == null) return [];
    
    // Convert JSArray to Dart List
    final jsArray = result as JSArray;
    final list = <Map<String, dynamic>>[];
    
    for (var i = 0; i < jsArray.length.toDartInt; i++) {
      final item = jsArray[i.toJS];
      if (item != null) {
        list.add(_jsObjectToMap(item));
      }
    }
    
    return list;
  }

  /// Enter fullscreen mode
  void setFullscreen(bool fullscreen) {
    _callPlayerMethod('setFullscreen', [fullscreen.toJS]);
  }

  /// Get player state
  String getState() {
    final result = _callPlayerMethod('getState', []);
    return result != null ? (result as JSString).toDart : 'idle';
  }

  /// Load a new source
  void load(List<OvenPlayerSource> sources) {
    final sourcesJson = sources.map((s) => s.toJson()).toList();
    _callPlayerMethod('load', [sourcesJson.jsify()]);
  }

  /// Remove/destroy the player
  void remove() {
    _callPlayerMethod('remove', []);
    dispose();
  }

  /// Call a method on the player instance
  JSAny? _callPlayerMethod(String methodName, List<JSAny?> args) {
    if (_playerInstance == null) return null;

    try {
      final method = _playerInstance!.getProperty(methodName.toJS);
      if (method != null && method is JSFunction) {
        return method.callAsFunction(_playerInstance, args.toJS);
      }
    } catch (e) {
      _errorController.add(ErrorEvent(
        code: 'METHOD_ERROR',
        message: 'Error calling $methodName: $e',
        error: e,
      ));
    }
    return null;
  }

  /// Get the global OvenPlayer object
  JSObject? _getOvenPlayerGlobal() {
    try {
      final global = web.window.getProperty('OvenPlayer'.toJS);
      return global as JSObject?;
    } catch (e) {
      return null;
    }
  }

  /// Create a player instance
  JSObject? _createPlayer(JSObject ovenPlayer, String containerId, String configJson) {
    try {
      final createMethod = ovenPlayer.getProperty('create'.toJS) as JSFunction?;
      if (createMethod == null) return null;

      final config = _parseJson(configJson);
      final result = createMethod.callAsFunction(
        ovenPlayer,
        [containerId.toJS, config].toJS,
      );
      
      return result as JSObject?;
    } catch (e) {
      return null;
    }
  }

  /// Parse JSON string to JSObject
  JSObject _parseJson(String jsonString) {
    final json = web.window.getProperty('JSON'.toJS) as JSObject;
    final parseMethod = json.getProperty('parse'.toJS) as JSFunction;
    return parseMethod.callAsFunction(json, [jsonString.toJS].toJS) as JSObject;
  }

  /// Convert JSObject to Dart Map
  Map<String, dynamic> _jsObjectToMap(JSAny? jsObject) {
    if (jsObject == null) return {};
    
    try {
      // Convert to JSON string using JavaScript JSON.stringify
      final json = web.window.getProperty('JSON'.toJS) as JSObject;
      final stringifyMethod = json.getProperty('stringify'.toJS) as JSFunction;
      final jsonString = (stringifyMethod.callAsFunction(json, [jsObject].toJS) as JSString).toDart;
      
      // Parse using Dart's built-in JSON decoder
      final parsed = jsonDecode(jsonString);
      
      // Ensure we return a Map<String, dynamic>
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else if (parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      }
      
      return {};
    } catch (e) {
      // Return empty map on error
      return {};
    }
  }

  /// Dispose the controller and close streams
  void dispose() {
    _isInitialized = false;
    _playerInstance = null;
    
    _readyController.close();
    _stateChangedController.close();
    _metaChangedController.close();
    _timeController.close();
    _bufferChangedController.close();
    _volumeChangedController.close();
    _muteController.close();
    _qualityLevelChangedController.close();
    _sourceChangedController.close();
    _playlistChangedController.close();
    _fullscreenChangedController.close();
    _errorController.close();
    _seekController.close();
    _resizedController.close();
    _playbackRateChangedController.close();
    _contentMetaDataController.close();
  }
}
