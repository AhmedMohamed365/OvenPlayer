/// JavaScript interop for OvenPlayer
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

/// JavaScript interop for OvenPlayer instance
@JS('OvenPlayer')
extension type OvenPlayerJS._(JSObject _) implements JSObject {
  /// Create a new OvenPlayer instance
  external static OvenPlayerInstanceJS create(
    JSAny container,
    JSObject config,
  );

  /// Get player instance by container ID
  external static OvenPlayerInstanceJS? getPlayerByContainerId(String id);

  /// Get list of all player instances
  external static JSArray<OvenPlayerInstanceJS> getPlayerList();
}

/// JavaScript interop for OvenPlayer instance methods
@JS()
extension type OvenPlayerInstanceJS._(JSObject _) implements JSObject {
  /// Play the video
  external void play();

  /// Pause the video
  external void pause();

  /// Stop the video
  external void stop();

  /// Seek to a specific position in seconds
  external void seek(JSNumber position);

  /// Get current playback position in seconds
  external JSNumber getPosition();

  /// Get video duration in seconds
  external JSNumber getDuration();

  /// Get current state
  external JSString getState();

  /// Set volume (0-100)
  external void setVolume(JSNumber volume);

  /// Get current volume (0-100)
  external JSNumber getVolume();

  /// Set mute state
  external void setMute(JSBoolean mute);

  /// Get mute state
  external JSBoolean getMute();

  /// Get current source index
  external JSNumber getCurrentSource();

  /// Set current source by index
  external void setCurrentSource(JSNumber index);

  /// Get list of sources
  external JSArray<JSObject> getSources();

  /// Get quality levels
  external JSArray<JSObject> getQualityLevels();

  /// Get current quality index
  external JSNumber getCurrentQuality();

  /// Set current quality by index (use -1 for auto)
  external void setCurrentQuality(JSNumber index);

  /// Add event listener
  external void on(JSString eventName, JSFunction callback);

  /// Remove event listener
  external void off(JSString eventName, JSFunction? callback);

  /// Remove the player
  external void remove();

  /// Get container ID
  external JSString getContainerId();

  /// Show controls
  external void showControls();

  /// Hide controls
  external void hideControls();

  /// Toggle fullscreen
  external void toggleFullScreen();

  /// Check if fullscreen
  external JSBoolean getFullscreen();
}

/// Helper functions for JavaScript interop
class OvenPlayerJSHelper {
  /// Convert Dart Map to JSObject
  static JSObject mapToJSObject(Map<String, dynamic> map) {
    final jsObj = JSObject();
    map.forEach((key, value) {
      jsObj.setProperty(key.toJS, _convertToJSAny(value));
    });
    return jsObj;
  }

  /// Convert Dart value to JSAny
  static JSAny _convertToJSAny(dynamic value) {
    if (value == null) {
      return null as JSAny;
    } else if (value is String) {
      return value.toJS;
    } else if (value is int) {
      return value.toJS;
    } else if (value is double) {
      return value.toJS;
    } else if (value is bool) {
      return value.toJS;
    } else if (value is List) {
      return _listToJSArray(value);
    } else if (value is Map<String, dynamic>) {
      return mapToJSObject(value);
    }
    return value.toString().toJS;
  }

  /// Convert Dart List to JSArray
  static JSArray<JSAny> _listToJSArray(List list) {
    final dartList = <JSAny>[];
    for (var item in list) {
      dartList.add(_convertToJSAny(item));
    }
    return dartList.toJS;
  }

  /// Convert JSAny to Dart value
  static dynamic jsAnyToDart(JSAny? value) {
    if (value == null) return null;
    
    // Try to convert to primitive types
    if (value.typeofEquals('string')) {
      return (value as JSString).toDart;
    } else if (value.typeofEquals('number')) {
      return (value as JSNumber).toDartDouble;
    } else if (value.typeofEquals('boolean')) {
      return (value as JSBoolean).toDart;
    } else if (value.typeofEquals('object')) {
      // Try to convert object to Map
      return jsObjectToMap(value as JSObject);
    }
    
    return null;
  }

  /// Convert JSObject to Dart Map
  static Map<String, dynamic> jsObjectToMap(JSObject obj) {
    final map = <String, dynamic>{};
    final keys = _getObjectKeys(obj).toDart;
    
    for (var i = 0; i < keys.length; i++) {
      final keyStr = (keys[i] as JSString).toDart;
      final value = obj.getProperty(keyStr.toJS);
      map[keyStr] = jsAnyToDart(value);
    }
    
    return map;
  }

  /// Get HTML element by ID
  static web.Element? getElementById(String id) {
    return web.document.getElementById(id);
  }
}

/// Get object keys using Object.keys()
@JS('Object.keys')
external JSArray<JSString> _getObjectKeys(JSObject obj);
