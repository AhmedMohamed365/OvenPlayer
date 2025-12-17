# Getting Started with OvenPlayer Flutter Web

This guide will help you integrate OvenPlayer into your Flutter Web application.

## Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Basic knowledge of Flutter and Dart
- A web browser for testing (Chrome recommended)

## Installation

### 1. Add the Package

Add `ovenplayer_flutter_web` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ovenplayer_flutter_web: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### 2. Include OvenPlayer JavaScript Library

Add the OvenPlayer JavaScript library to your `web/index.html` file:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... other head elements ... -->
  
  <!-- Add OvenPlayer JavaScript library -->
  <script src="https://cdn.jsdelivr.net/npm/ovenplayer@0.10.45/dist/ovenplayer.js"></script>
</head>
<body>
  <!-- ... your app ... -->
</body>
</html>
```

## Basic Usage

### Step 1: Import the Package

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';
```

### Step 2: Create a Controller

```dart
class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late OvenPlayerController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = OvenPlayerController(
      config: OvenPlayerConfig(
        sources: [
          OvenPlayerSource(
            label: 'WebRTC Stream',
            type: 'webrtc',
            file: 'wss://your-server.com/app/stream',
          ),
        ],
        autoStart: true,
      ),
    );

    // Setup event handlers
    _controller.onReady = () {
      print('Player is ready!');
    };

    _controller.onStateChanged = (state) {
      print('Player state: ${state.name}');
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OvenPlayerWidget(controller: _controller),
    );
  }
}
```

## Configuration Options

### Multiple Sources with Fallback

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      label: 'WebRTC',
      type: 'webrtc',
      file: 'wss://server.com/app/stream',
    ),
    OvenPlayerSource(
      label: 'HLS',
      type: 'hls',
      file: 'https://server.com/playlist.m3u8',
    ),
  ],
  autoFallback: true, // Automatically fallback to next source on error
)
```

### WebRTC Configuration

```dart
OvenPlayerConfig(
  sources: [...],
  webrtcConfig: OvenPlayerWebRTCConfig(
    timeoutMaxRetry: 3,
    connectionTimeout: 10000,
    recoverPacketLoss: true,
  ),
)
```

### Player Appearance

```dart
OvenPlayerConfig(
  sources: [...],
  controls: true,
  showBigPlayButton: true,
  hideControlsTimeout: 3000,
  title: 'My Live Stream',
  image: 'https://example.com/poster.jpg', // Poster image
)
```

## Event Handling

### Available Events

```dart
_controller.onReady = () { };
_controller.onStateChanged = (state) { };
_controller.onError = (error) { };
_controller.onMetaChanged = (meta) { };
_controller.onTime = (time) { };
_controller.onBufferChanged = (buffer) { };
_controller.onVolumeChanged = (volume) { };
_controller.onSourceChanged = (source) { };
_controller.onQualityLevelChanged = (quality) { };
_controller.onComplete = () { };
```

### Example: Handling Errors

```dart
_controller.onError = (error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Playback Error'),
      content: Text('Error ${error.code}: ${error.message}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
};
```

## Playback Control

### Basic Controls

```dart
// Play/Pause
_controller.play();
_controller.pause();
_controller.stop();

// Seek
_controller.seek(30.0); // Seek to 30 seconds

// Volume
_controller.setVolume(50); // Set volume to 50%
_controller.setMute(true); // Mute audio
```

### Building Custom Controls

```dart
Row(
  children: [
    IconButton(
      icon: Icon(Icons.play_arrow),
      onPressed: () => _controller.play(),
    ),
    IconButton(
      icon: Icon(Icons.pause),
      onPressed: () => _controller.pause(),
    ),
    Expanded(
      child: Slider(
        value: _controller.getVolume().toDouble(),
        min: 0,
        max: 100,
        onChanged: (value) => _controller.setVolume(value.toInt()),
      ),
    ),
  ],
)
```

## Advanced Features

### Quality Selection

```dart
// Get available quality levels
final qualities = _controller.getQualityLevels();

// Show quality selector
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Select Quality'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Auto'),
          onTap: () {
            _controller.setCurrentQuality(-1);
            Navigator.pop(context);
          },
        ),
        ...qualities.map((quality) => ListTile(
          title: Text(quality.label ?? '${quality.width}x${quality.height}'),
          onTap: () {
            _controller.setCurrentQuality(quality.index);
            Navigator.pop(context);
          },
        )),
      ],
    ),
  ),
);
```

### Source Switching

```dart
// Switch to different source
_controller.setCurrentSource(1); // Switch to second source
```

### Fullscreen

```dart
_controller.toggleFullScreen();
```

## Common Use Cases

### Live Streaming with WebRTC

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'webrtc',
      file: 'wss://live.example.com/app/stream',
    ),
  ],
  autoStart: true,
  mute: false,
  webrtcConfig: OvenPlayerWebRTCConfig(
    connectionTimeout: 10000,
    recoverPacketLoss: true,
  ),
)
```

### VOD with HLS

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'hls',
      file: 'https://vod.example.com/video.m3u8',
    ),
  ],
  autoStart: false,
  controls: true,
  title: 'My Video',
  image: 'https://example.com/thumbnail.jpg',
)
```

### Multi-Protocol with Fallback

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      label: 'WebRTC (Sub-second)',
      type: 'webrtc',
      file: 'wss://server.com/app/stream',
    ),
    OvenPlayerSource(
      label: 'LLHLS (Low Latency)',
      type: 'hls',
      file: 'https://server.com/llhls/playlist.m3u8',
    ),
    OvenPlayerSource(
      label: 'HLS (Standard)',
      type: 'hls',
      file: 'https://server.com/hls/playlist.m3u8',
    ),
  ],
  autoFallback: true,
)
```

## Troubleshooting

### Player Not Loading

1. Verify OvenPlayer JavaScript is included in `web/index.html`
2. Check browser console for JavaScript errors
3. Ensure video source URLs are correct and accessible
4. Check CORS settings for cross-origin resources

### WebRTC Connection Issues

1. Verify WebSocket URL (must use `wss://` for secure connections)
2. Check that OvenMediaEngine server is running
3. Verify SSL/TLS certificates are valid
4. Check firewall and network settings

### No Video Display

1. Ensure the widget has proper dimensions (width/height)
2. Check that the container has space in the widget tree
3. Verify the source format is supported
4. Check browser compatibility

## Next Steps

- Check out the [API Reference](api_reference.md) for detailed documentation
- Explore the [example app](../example/) for complete implementation
- Visit [OvenPlayer documentation](https://airensoft.gitbook.io/ovenplayer) for more details

## Support

For issues and questions:
- [GitHub Issues](https://github.com/AirenSoft/OvenPlayer/issues)
- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer)
- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine)
