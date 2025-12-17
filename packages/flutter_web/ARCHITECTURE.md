# OvenPlayer Flutter Web Architecture

This document describes the architecture and design decisions for the OvenPlayer Flutter Web package.

## Overview

The OvenPlayer Flutter Web package is a wrapper around the OvenPlayer JavaScript library, enabling Flutter web applications to play WebRTC and LL-HLS streams optimized for OvenMediaEngine.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
│  (User's Dart code using OvenPlayer widget and controller) │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Dart API
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              OvenPlayer Flutter Package                     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Config     │  │  Controller  │  │    Widget    │     │
│  │  (Dart)      │  │   (Dart)     │  │   (Dart)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
│                   JS Interop Layer                          │
│                      (dart:js)                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ JavaScript API
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              OvenPlayer JavaScript Library                  │
│  (Loaded via <script> tag in index.html)                   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  WebRTC      │  │    HLS       │  │    DASH      │     │
│  │  Provider    │  │  Provider    │  │  Provider    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Browser APIs
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Browser Platform                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  WebRTC API  │  │  Media API   │  │  WebSocket   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Component Description

### 1. Flutter Application Layer

The top layer where developers use the package. They interact with:
- **OvenPlayer Widget**: A StatefulWidget that renders the player
- **OvenPlayerController**: Controls playback and listens to events
- **OvenPlayerConfig**: Configuration for sources, WebRTC settings, etc.

### 2. OvenPlayer Flutter Package

#### Core Components

**a. Configuration (`ovenplayer_config.dart`)**
- `OvenPlayerConfig`: Main configuration class
- `OvenPlayerSource`: Media source definition (type, file, label)
- `WebRTCConfig`: WebRTC-specific settings (ICE servers, timeout, etc.)
- `IceServer`: ICE server configuration
- Helper classes: `ParseStreamConfig`, `WatermarkConfig`, `TimecodeConfig`

**b. Controller (`ovenplayer_controller.dart`)**
- `OvenPlayerController`: Main controller class
- Manages player instance lifecycle
- Provides methods for playback control (play, pause, stop, seek)
- Provides methods for volume control
- Provides methods for quality control
- Exposes event streams using Dart `Stream` API
- Handles JavaScript interop for calling OvenPlayer methods

**c. Widget (`ovenplayer_widget.dart`)**
- `OvenPlayer`: StatefulWidget component
- Uses `HtmlElementView` to embed HTML container
- Registers a platform view factory
- Creates a DOM element for the player
- Initializes the controller with configuration
- Manages widget lifecycle

**d. Events (`ovenplayer_events.dart`)**
- Defines event data classes for all player events
- Provides type-safe event data structures
- Includes factory methods for parsing JavaScript events
- Event types: StateChanged, MetaChanged, Time, Error, etc.

**e. WebRTC Loader (`webrtc/webrtc_loader.dart`)**
- Placeholder for direct WebRTC access (optional)
- In practice, WebRTC is handled by OvenPlayer JS library
- Provided for future enhancements or advanced use cases

#### JS Interop Layer

The package uses `dart:js_interop` and `package:web` to communicate with JavaScript:

1. **Accessing OvenPlayer Global Object**
   ```dart
   final ovenPlayer = web.window.getProperty('OvenPlayer'.toJS);
   ```

2. **Creating Player Instance**
   ```dart
   final instance = createMethod.callAsFunction(
     ovenPlayer,
     [containerId.toJS, config].toJS,
   );
   ```

3. **Registering Event Listeners**
   ```dart
   _callPlayerMethod('on', [eventName.toJS, jsCallback]);
   ```

4. **Calling Player Methods**
   ```dart
   _callPlayerMethod('play', []);
   _callPlayerMethod('seek', [position.toJS]);
   ```

### 3. OvenPlayer JavaScript Library

The core JavaScript library that handles:
- **WebRTC Provider**: Manages WebRTC connections, signaling, ICE candidates
- **HLS Provider**: Uses hls.js for HLS playback
- **DASH Provider**: Uses dash.js for DASH playback
- **HTML5 Provider**: Native HTML5 video playback
- **UI Components**: Player controls, quality selector, etc.

Key features:
- Protocol negotiation and fallback
- Quality level management
- Buffering and error handling
- SEI metadata extraction
- Packet loss recovery

### 4. Browser Platform

Native browser APIs:
- **WebRTC API**: RTCPeerConnection, MediaStream, ICE
- **Media API**: HTMLVideoElement, MediaSource, etc.
- **WebSocket**: For signaling communication with OvenMediaEngine
- **DOM API**: For UI rendering and interaction

## Data Flow

### Initialization Flow

1. User creates `OvenPlayer` widget with `OvenPlayerConfig`
2. Widget registers a platform view factory with unique ID
3. Widget creates `OvenPlayerController` (or uses provided one)
4. Widget creates a `<div>` element in the DOM
5. Controller calls `OvenPlayer.create()` via JS interop
6. OvenPlayer JS library initializes and binds to the div
7. Controller registers event listeners
8. Player emits 'ready' event when initialized
9. Controller forwards events to Dart streams

### Playback Flow (WebRTC)

1. User calls `controller.play()` or sets `autoStart: true`
2. Controller calls JavaScript `player.play()`
3. OvenPlayer JS loads WebRTC provider
4. WebRTC provider opens WebSocket to signaling server
5. Signaling exchange: offer, answer, ICE candidates
6. RTCPeerConnection established
7. MediaStream received and attached to video element
8. Player emits 'stateChanged' event with state='playing'
9. Controller receives event and forwards to stream
10. User's app updates UI based on stream events

### Control Flow

```
User Action → Controller Method → JS Interop → OvenPlayer JS → Browser API
     ↓                                                              ↓
State Update ← Dart Stream ← Event Handler ← JS Event ← Media Event
```

## Design Decisions

### 1. Why Wrapper Instead of Native Implementation?

**Pros:**
- Leverage mature JavaScript library with all features
- No need to reimplement complex WebRTC signaling
- Automatic compatibility with OvenMediaEngine protocol
- Smaller codebase, easier to maintain
- Inherit bug fixes and new features from JS library

**Cons:**
- Requires JavaScript library to be loaded
- Limited to web platform
- Some overhead from JS interop

**Decision**: Wrapper approach is best for web platform. For native mobile, a different approach using `flutter_webrtc` would be needed.

### 2. Controller Pattern

We use a controller pattern similar to Flutter's `TextEditingController`:

**Benefits:**
- Familiar pattern for Flutter developers
- Separates widget from business logic
- Allows programmatic control
- Can be shared between widgets
- Easy to test

### 3. Stream-Based Events

We use Dart `Stream` for events instead of callbacks:

**Benefits:**
- Idiomatic Dart/Flutter approach
- Composable with stream operators
- Automatic cleanup with `StreamController`
- Can have multiple listeners
- Better for reactive programming

### 4. Configuration via Data Classes

All configuration uses immutable data classes:

**Benefits:**
- Type safety
- IDE autocomplete
- Easy to serialize/deserialize
- Immutability prevents accidental changes
- Clear API surface

## WebRTC Signaling Protocol

The package follows the OvenMediaEngine WebRTC signaling protocol:

### Connection Sequence

```
Client                      OME Signaling Server
  │                               │
  │───── WebSocket Connect ──────>│
  │                               │
  │───── request_offer ──────────>│
  │                               │
  │<────── offer ─────────────────│
  │      (SDP + candidates)       │
  │                               │
  │───── answer ─────────────────>│
  │      (SDP)                    │
  │                               │
  │<────── candidate ─────────────│
  │───── candidate ──────────────>│
  │      (ICE candidates)         │
  │                               │
  │<────── ping ──────────────────│
  │───── pong ───────────────────>│
  │                               │
  │      [Media streaming]        │
  │<──────────────────────────────│
  │                               │
  │───── stop ───────────────────>│
  │<────── stop ──────────────────│
  │                               │
```

### Message Format

**request_offer**
```json
{
  "command": "request_offer"
}
```

**offer**
```json
{
  "command": "offer",
  "id": "unique_id",
  "peer_id": 0,
  "sdp": {
    "type": "offer",
    "sdp": "v=0\r\no=- ... "
  },
  "candidates": [...],
  "ice_servers": [...]
}
```

**answer**
```json
{
  "command": "answer",
  "id": "unique_id",
  "peer_id": 0,
  "sdp": {
    "type": "answer",
    "sdp": "v=0\r\na=... "
  }
}
```

**candidate**
```json
{
  "command": "candidate",
  "id": "unique_id",
  "peer_id": 0,
  "candidates": [
    {
      "candidate": "...",
      "sdpMLineIndex": 0,
      "sdpMid": "video"
    }
  ]
}
```

## Error Handling

The package implements multiple levels of error handling:

1. **Initialization Errors**: Caught when creating player instance
2. **Connection Errors**: WebRTC/WebSocket connection failures
3. **Playback Errors**: Media loading/decoding errors
4. **API Errors**: Invalid method calls or parameters

All errors are forwarded to the `onError` stream with structured `ErrorEvent` data.

## Performance Considerations

1. **Lazy Initialization**: Player is initialized only when widget is mounted
2. **Event Throttling**: Some events (like 'time') fire frequently; consider throttling in app code
3. **Memory Management**: Controller and streams are properly disposed
4. **DOM Cleanup**: HTML elements are removed when widget is disposed

## Testing Strategy

1. **Unit Tests**: Test configuration classes, data conversion
2. **Widget Tests**: Test widget lifecycle, controller interaction
3. **Integration Tests**: Test with mock JavaScript environment
4. **Manual Tests**: Test with real OvenMediaEngine server

## Future Enhancements

1. **Native Mobile Support**: Use `flutter_webrtc` for iOS/Android
2. **Offline Caching**: Support for offline playback
3. **Advanced UI**: Custom player controls widget
4. **Analytics**: Built-in analytics integration
5. **Accessibility**: ARIA labels, screen reader support
6. **Performance**: Reduce interop overhead
7. **Types**: Better type safety with code generation

## References

- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [OvenMediaEngine WebRTC](https://airensoft.gitbook.io/ovenmediaengine/streaming/webrtc-publishing)
- [Flutter Web Platform Views](https://docs.flutter.dev/platform-integration/web/web-platform-views)
- [Dart JS Interop](https://dart.dev/web/js-interop)
- [WebRTC Specification](https://www.w3.org/TR/webrtc/)
