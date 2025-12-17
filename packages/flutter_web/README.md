# OvenPlayer Flutter Web

A Flutter Web wrapper for [OvenPlayer](https://github.com/AirenSoft/OvenPlayer) that enables sub-second latency streaming with WebRTC and Low Latency HLS (LLHLS) support.

## Features

- **WebRTC Streaming**: Sub-second latency streaming with WebRTC support
- **LLHLS Support**: Low Latency HLS streaming
- **Full Player Control**: Play, pause, seek, volume control, and more
- **Event Handling**: Listen to player events like state changes, errors, and metadata
- **Quality Levels**: Support for adaptive bitrate streaming and manual quality selection
- **Customizable**: Configure player behavior and appearance

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ovenplayer_flutter_web: ^0.1.0
```

## Web Setup

Since OvenPlayer is a JavaScript library, you need to include it in your `web/index.html`:

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

Alternatively, you can host the OvenPlayer library yourself and include it from your assets.

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

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
            label: 'WebRTC',
            type: 'webrtc',
            file: 'wss://your-server.com/app/stream',
          ),
        ],
        autoStart: true,
        autoFallback: true,
        mute: false,
        volume: 100,
      ),
    );

    _controller.onReady = () {
      print('Player is ready');
    };

    _controller.onStateChanged = (state) {
      print('Player state: $state');
    };

    _controller.onError = (error) {
      print('Player error: ${error.message}');
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
      appBar: AppBar(title: Text('OvenPlayer Demo')),
      body: Column(
        children: [
          // The player widget
          Expanded(
            child: OvenPlayerWidget(controller: _controller),
          ),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => _controller.play(),
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: () => _controller.pause(),
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () => _controller.stop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Configuration Options

```dart
OvenPlayerConfig(
  // Source configuration
  sources: [
    OvenPlayerSource(
      label: 'WebRTC',
      type: 'webrtc',
      file: 'wss://your-server.com/app/stream',
    ),
    OvenPlayerSource(
      label: 'HLS',
      type: 'hls',
      file: 'https://your-server.com/playlist.m3u8',
    ),
  ],
  
  // Playback configuration
  autoStart: true,
  autoFallback: true,
  mute: false,
  volume: 100,
  
  // WebRTC specific configuration
  webrtcConfig: OvenPlayerWebRTCConfig(
    timeoutMaxRetry: 3,
    connectionTimeout: 10000,
  ),
  
  // UI configuration
  controls: true,
  hideControlsTimeout: 3000,
  
  // Other options
  playbackRates: [0.5, 1.0, 1.5, 2.0],
  showBigPlayButton: true,
  disableSeekUI: false,
)
```

### Controller Methods

- `play()` - Start or resume playback
- `pause()` - Pause playback
- `stop()` - Stop playback
- `seek(position)` - Seek to a specific position in seconds
- `setVolume(volume)` - Set volume (0-100)
- `setMute(mute)` - Mute or unmute
- `getCurrentSource()` - Get current source index
- `setCurrentSource(index)` - Switch to a different source
- `getQualityLevels()` - Get available quality levels
- `setCurrentQuality(index)` - Set quality level
- `dispose()` - Clean up the player

### Events

```dart
controller.onReady = () { /* Player initialized */ };
controller.onStateChanged = (state) { /* State: playing, paused, idle, etc */ };
controller.onError = (error) { /* Handle errors */ };
controller.onMetaChanged = (meta) { /* Video metadata */ };
controller.onTime = (time) { /* Current playback time */ };
controller.onBufferChanged = (buffer) { /* Buffer percentage */ };
controller.onVolumeChanged = (volume) { /* Volume changed */ };
controller.onSourceChanged = (source) { /* Source switched */ };
controller.onQualityLevelChanged = (quality) { /* Quality changed */ };
```

## Documentation

- [Getting Started Guide](doc/getting_started.md) - Step-by-step tutorial
- [API Reference](doc/api_reference.md) - Complete API documentation
- [WebRTC Setup Guide](doc/webrtc_setup.md) - WebRTC configuration and troubleshooting
- [Docker Setup Guide](DOCKER.md) - Docker deployment and demo
- [Example App](example/) - Complete working example

## Example

Check out the [example](example/) directory for a complete working example.

## Quick Demo with Docker

Run the demo instantly with Docker:

```bash
# Run Flutter demo only (connects to external WebRTC stream)
docker-compose up flutter-demo

# Or run with OvenMediaEngine server included
docker-compose --profile with-ome up
```

Visit **http://localhost:8080** to see the demo.

See [DOCKER.md](DOCKER.md) for detailed Docker setup instructions.

## Requirements

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Web platform only

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [OvenPlayer](https://github.com/AirenSoft/OvenPlayer) - The JavaScript player library
- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine) - Sub-Second Latency Streaming Server
- [OvenLiveKit](https://github.com/AirenSoft/OvenLiveKit-Web) - Live Streaming Encoder

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/AirenSoft/OvenPlayer).
