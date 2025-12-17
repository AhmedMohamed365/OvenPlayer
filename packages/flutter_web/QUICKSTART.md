# OvenPlayer Flutter Web - Quick Start

## Installation (30 seconds)

### 1. Add to pubspec.yaml
```yaml
dependencies:
  ovenplayer_flutter_web: ^0.1.0
```

### 2. Add to web/index.html
```html
<script src="https://cdn.jsdelivr.net/npm/ovenplayer@0.10.45/dist/ovenplayer.js"></script>
```

### 3. Run
```bash
flutter pub get
```

## Basic Usage (2 minutes)

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late OvenPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OvenPlayerController(
      config: OvenPlayerConfig(
        sources: [
          OvenPlayerSource(
            type: 'webrtc',
            file: 'wss://your-server.com/app/stream',
          ),
        ],
        autoStart: true,
      ),
    );
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

## Common Configurations

### WebRTC Live Stream
```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'webrtc',
      file: 'wss://server.com:3334/app/stream',
    ),
  ],
  autoStart: true,
  webrtcConfig: OvenPlayerWebRTCConfig(
    connectionTimeout: 10000,
  ),
)
```

### HLS Video
```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'hls',
      file: 'https://server.com/video.m3u8',
    ),
  ],
  controls: true,
)
```

### Multiple Sources with Fallback
```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(label: 'WebRTC', type: 'webrtc', file: 'wss://...'),
    OvenPlayerSource(label: 'HLS', type: 'hls', file: 'https://...'),
  ],
  autoFallback: true,
)
```

## Essential Methods

```dart
// Playback
_controller.play();
_controller.pause();
_controller.stop();
_controller.seek(30.0);

// Volume
_controller.setVolume(50);
_controller.setMute(true);

// Info
double position = _controller.getPosition();
double duration = _controller.getDuration();
String state = _controller.getState();
```

## Essential Events

```dart
_controller.onReady = () {
  print('Player ready');
};

_controller.onStateChanged = (state) {
  print('State: ${state.name}');
};

_controller.onError = (error) {
  print('Error: ${error.message}');
};

_controller.onTime = (time) {
  print('${time.position} / ${time.duration}');
};
```

## Troubleshooting

### "OvenPlayer is not defined"
✅ Add script to web/index.html before Flutter app loads

### Player not visible
✅ Give widget explicit dimensions or use Expanded/Flexible

### WebRTC not connecting
✅ Check URL format: `wss://domain:port/app/stream`
✅ Verify SSL certificate is valid
✅ Ensure OvenMediaEngine is running

### Need help?
📖 [Full Documentation](README.md)
🚀 [Getting Started Guide](doc/getting_started.md)
📚 [API Reference](doc/api_reference.md)
🔧 [WebRTC Setup](doc/webrtc_setup.md)

## Next Steps

1. Check [example/](example/) for complete working app
2. Read [Getting Started Guide](doc/getting_started.md) for detailed tutorial
3. Explore [API Reference](doc/api_reference.md) for all features
4. Configure [WebRTC](doc/webrtc_setup.md) for live streaming

## Support

- 📦 [GitHub Issues](https://github.com/AirenSoft/OvenPlayer/issues)
- 📖 [OvenPlayer Docs](https://airensoft.gitbook.io/ovenplayer)
- 🏢 [AirenSoft](https://airensoft.com)
