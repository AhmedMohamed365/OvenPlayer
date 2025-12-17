# Flutter Web Integration Overview

This document provides an overview of how the Flutter Web package integrates with the OvenPlayer ecosystem.

## Architecture

```
┌─────────────────────────────────────────┐
│         Flutter Web Application          │
│  ┌───────────────────────────────────┐  │
│  │    OvenPlayerWidget (Dart)        │  │
│  │  - Renders HtmlElementView        │  │
│  │  - Creates div container          │  │
│  └───────────────┬───────────────────┘  │
│                  │                       │
│  ┌───────────────▼───────────────────┐  │
│  │  OvenPlayerController (Dart)      │  │
│  │  - Manages player lifecycle       │  │
│  │  - Handles events                 │  │
│  │  - Exposes control methods        │  │
│  └───────────────┬───────────────────┘  │
│                  │                       │
│  ┌───────────────▼───────────────────┐  │
│  │  JavaScript Interop (dart:js)     │  │
│  │  - Bridges Dart ↔ JavaScript      │  │
│  │  - Type conversions               │  │
│  └───────────────┬───────────────────┘  │
└──────────────────┼───────────────────────┘
                   │
        ┌──────────▼──────────┐
        │  OvenPlayer.js      │
        │  - WebRTC handling  │
        │  - HLS/DASH support │
        │  - Media playback   │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │  Browser APIs       │
        │  - WebRTC API       │
        │  - Media Source     │
        │  - Video Element    │
        └─────────────────────┘
```

## Component Overview

### 1. OvenPlayerWidget

- **Purpose**: Renders the player in the Flutter widget tree
- **Implementation**: Uses `HtmlElementView` to embed HTML div
- **Location**: `lib/src/ovenplayer_widget.dart`

Key features:
- Creates unique container ID for each instance
- Registers platform view factory
- Manages widget lifecycle

### 2. OvenPlayerController

- **Purpose**: Manages player instance and provides control API
- **Implementation**: Extends `ChangeNotifier` for state management
- **Location**: `lib/src/ovenplayer_controller.dart`

Key features:
- Initializes JavaScript player instance
- Sets up event listeners
- Provides playback control methods
- Handles player disposal

### 3. JavaScript Interop Layer

- **Purpose**: Bridges Dart and JavaScript
- **Implementation**: Uses `dart:js_interop` package
- **Location**: `lib/src/ovenplayer_js_interop.dart`

Key features:
- Type-safe JavaScript bindings
- Data conversion utilities
- Direct access to OvenPlayer.js API

### 4. Configuration Classes

- **Purpose**: Type-safe configuration
- **Location**: `lib/src/ovenplayer_config.dart`

Classes:
- `OvenPlayerConfig` - Main configuration
- `OvenPlayerSource` - Source definition
- `OvenPlayerWebRTCConfig` - WebRTC settings

### 5. Event Data Classes

- **Purpose**: Structured event data
- **Location**: `lib/src/ovenplayer_events.dart`

Classes:
- `OvenPlayerState` - Player state enum
- `OvenPlayerError` - Error information
- `OvenPlayerMetadata` - Video metadata
- Various event-specific data classes

## Data Flow

### Initialization Flow

```
1. User creates OvenPlayerController with config
2. User adds OvenPlayerWidget to widget tree
3. Widget creates HTML div with unique ID
4. Controller.initialize() is called with div ID
5. JavaScript OvenPlayer.create() is invoked
6. Event listeners are set up
7. Player is ready
```

### Event Flow

```
JavaScript Event → JS Interop → Dart Callback → User Handler

Example:
1. OvenPlayer.js fires 'stateChanged' event
2. JS callback receives event data
3. dart:js converts to Dart types
4. OvenPlayerController processes event
5. User's onStateChanged callback is invoked
```

### Control Flow

```
User Method Call → Controller → JS Interop → OvenPlayer.js

Example:
1. User calls controller.play()
2. Controller method invoked
3. JS interop converts call
4. OvenPlayer.js play() executed
5. Player starts playback
```

## WebRTC Integration

The Flutter Web package fully supports WebRTC streaming through OvenPlayer.js:

1. **Configuration**: WebRTC options passed via `OvenPlayerWebRTCConfig`
2. **Connection**: OvenPlayer.js handles WebSocket signaling
3. **Media**: Native browser WebRTC APIs used for media
4. **Events**: Connection status reported through events

## Comparison with Other Packages

### React Package (packages/react)

**Similarities:**
- Both wrap OvenPlayer.js
- Similar event handling approach
- Same configuration options

**Differences:**
- React uses JSX, Flutter uses Widgets
- React uses hooks, Flutter uses StatefulWidget
- Different platform view mechanisms

### Vue3 Package (packages/vue3)

**Similarities:**
- Component-based approach
- Reactive state management
- Event emission patterns

**Differences:**
- Vue uses template syntax, Flutter uses widget composition
- Vue's reactivity vs Flutter's ChangeNotifier
- Different lifecycle management

## Platform Requirements

### Web Platform

- **Required**: Web target (flutter run -d chrome)
- **Browser Support**: Modern browsers with WebRTC support
  - Chrome 80+
  - Firefox 75+
  - Safari 14+
  - Edge 80+

### OvenPlayer.js

- **Version**: 0.10.45 or compatible
- **Loading**: Must be included in web/index.html
- **CDN**: https://cdn.jsdelivr.net/npm/ovenplayer@0.10.45/dist/ovenplayer.js

## Best Practices

### 1. Resource Management

```dart
@override
void dispose() {
  _controller.dispose(); // Always dispose controller
  super.dispose();
}
```

### 2. Error Handling

```dart
_controller.onError = (error) {
  // Log errors
  debugPrint('Player error: ${error.message}');
  
  // Show user feedback
  // Handle gracefully
};
```

### 3. State Management

```dart
// Use controller's ChangeNotifier for state
// Or integrate with your state management solution
```

### 4. Multiple Instances

```dart
// Each controller manages one player instance
// Safe to have multiple controllers
final controller1 = OvenPlayerController(config: config1);
final controller2 = OvenPlayerController(config: config2);
```

## Testing

### Unit Testing

- Configuration classes can be unit tested
- Event data parsing can be unit tested
- Helper functions can be unit tested

### Widget Testing

- Widget rendering can be tested
- Lifecycle can be tested
- Note: JavaScript interop requires integration tests

### Integration Testing

- Full player functionality requires web browser
- Use `flutter drive` for integration tests
- Test on multiple browsers

## Performance Considerations

### Memory

- Each player instance creates HTML element
- Dispose controllers when not needed
- Monitor memory in long-running apps

### CPU

- Video decoding handled by browser
- Minimal Flutter overhead
- WebRTC can be CPU intensive

### Network

- Bandwidth determined by video quality
- WebRTC: ~1-5 Mbps typical
- HLS: Variable based on ABR

## Debugging

### Enabling Debug Logs

```dart
// Flutter debug messages
debugPrint('Player state: ${_controller.getState()}');
```

### Browser Console

```javascript
// Check OvenPlayer availability
console.log(typeof OvenPlayer);

// Check player instance
console.log(OvenPlayer.getPlayerList());
```

### Common Issues

1. **"OvenPlayer is not defined"**
   - Check web/index.html includes OvenPlayer.js
   - Verify script loads before Flutter app

2. **Player not rendering**
   - Check widget has dimensions
   - Verify container ID is unique
   - Check browser console for errors

3. **WebRTC not connecting**
   - Verify wss:// URL
   - Check server is running
   - Verify SSL certificates

## Future Enhancements

Potential improvements:

1. **Platform Support**
   - Mobile support via platform channels
   - Desktop support investigation

2. **Features**
   - Playlist support
   - Advanced analytics
   - Custom UI components

3. **Performance**
   - Optimize event handling
   - Reduce JavaScript overhead
   - Better memory management

4. **Developer Experience**
   - More examples
   - Better error messages
   - Development tools

## Contributing

When contributing to the Flutter Web package:

1. Follow Flutter style guidelines
2. Add tests for new features
3. Update documentation
4. Test on multiple browsers
5. Consider backwards compatibility

## Resources

- [Flutter Web](https://flutter.dev/web)
- [dart:js_interop](https://dart.dev/interop/js-interop)
- [OvenPlayer.js](https://github.com/AirenSoft/OvenPlayer)
- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine)
- [WebRTC Specification](https://www.w3.org/TR/webrtc/)
