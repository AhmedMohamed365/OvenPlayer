# OvenPlayer Flutter Web

A Flutter web package for playing WebRTC and LL-HLS streams optimized for [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine).

## Features

- ✅ **WebRTC Support**: Sub-second latency streaming using WebRTC
- ✅ **LL-HLS Support**: Low-latency HLS streaming
- ✅ **Automatic Fallback**: Automatically switch between protocols
- ✅ **Flutter Widget**: Easy-to-use Flutter widget component
- ✅ **Full Control**: Comprehensive API for controlling playback
- ✅ **Event Streams**: React to player events using Dart streams
- ✅ **Quality Control**: Manual and automatic quality switching
- ✅ **OvenMediaEngine Compatible**: Works seamlessly with OME

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  ovenplayer_flutter_web: ^0.1.0
```

## Setup

### 1. Include OvenPlayer JavaScript Library

Add the OvenPlayer JavaScript library to your `web/index.html` file:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... other head elements ... -->
  
  <!-- OvenPlayer JavaScript Library -->
  <script src="https://cdn.jsdelivr.net/npm/ovenplayer/dist/ovenplayer.js"></script>
</head>
<body>
  <!-- ... -->
</body>
</html>
```

### 2. (Optional) Add HLS.js for HLS Support

If you want to support HLS streams, add HLS.js before OvenPlayer:

```html
<!-- HLS.js for HLS support -->
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest/dist/hls.min.js"></script>

<!-- OvenPlayer -->
<script src="https://cdn.jsdelivr.net/npm/ovenplayer/dist/ovenplayer.js"></script>
```

### 3. (Optional) Add Dash.js for DASH Support

For MPEG-DASH support:

```html
<!-- Dash.js for DASH support -->
<script src="https://cdn.jsdelivr.net/npm/dashjs@latest/dist/dash.all.debug.min.js"></script>

<!-- OvenPlayer -->
<script src="https://cdn.jsdelivr.net/npm/ovenplayer/dist/ovenplayer.js"></script>
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

class VideoPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OvenPlayer Example')),
      body: Center(
        child: OvenPlayer(
          config: OvenPlayerConfig(
            sources: [
              OvenPlayerSource(
                type: 'webrtc',
                file: 'ws://your-ome-server:3333/app/stream',
                label: 'WebRTC Stream',
              ),
            ],
            autoStart: true,
            controls: true,
          ),
          onReady: () {
            print('Player is ready!');
          },
          onError: (error) {
            print('Player error: $error');
          },
          width: 640,
          height: 360,
        ),
      ),
    );
  }
}
```

### Using Controller for Advanced Control

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

class ControlledPlayerPage extends StatefulWidget {
  @override
  _ControlledPlayerPageState createState() => _ControlledPlayerPageState();
}

class _ControlledPlayerPageState extends State<ControlledPlayerPage> {
  late OvenPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OvenPlayerController('my-player');
    
    // Listen to events
    _controller.onStateChanged.listen((event) {
      print('Player state changed: ${event.prevState} -> ${event.newState}');
    });
    
    _controller.onTime.listen((event) {
      print('Current position: ${event.position}s / ${event.duration}s');
    });
    
    _controller.onError.listen((error) {
      print('Error: ${error.message}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Controlled Player')),
      body: Column(
        children: [
          // Player widget
          Expanded(
            child: OvenPlayer(
              config: OvenPlayerConfig(
                sources: [
                  OvenPlayerSource(
                    type: 'webrtc',
                    file: 'ws://your-ome-server:3333/app/stream',
                  ),
                ],
                autoStart: false,
              ),
              controller: _controller,
            ),
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
              IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () => _controller.setVolume(100),
              ),
              IconButton(
                icon: Icon(Icons.volume_off),
                onPressed: () => _controller.setMute(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### WebRTC with Multiple Quality Levels

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://your-ome-server:3333/app/stream',
        label: 'WebRTC',
      ),
    ],
    webrtcConfig: WebRTCConfig(
      connectionTimeout: 10000,
      timeoutMaxRetry: 3,
      recoverPacketLoss: true,
      playoutDelayHint: 0.5,
    ),
    autoQuality: true,
  ),
)
```

### Automatic Fallback (WebRTC → HLS)

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://your-ome-server:3333/app/stream',
        label: 'WebRTC (Sub-second)',
      ),
      OvenPlayerSource(
        type: 'hls',
        file: 'https://your-ome-server:8080/app/stream/llhls.m3u8',
        label: 'HLS (Low-latency)',
      ),
    ],
    autoFallback: true,
  ),
)
```

### Using Custom ICE Servers

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://your-ome-server:3333/app/stream',
      ),
    ],
    webrtcConfig: WebRTCConfig(
      iceServers: [
        IceServer(
          urls: ['stun:stun.l.google.com:19302'],
        ),
        IceServer(
          urls: ['turn:your-turn-server:3478'],
          username: 'username',
          credential: 'password',
        ),
      ],
    ),
  ),
)
```

## Configuration Options

### OvenPlayerConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| `sources` | `List<OvenPlayerSource>` | List of media sources |
| `webrtcConfig` | `WebRTCConfig?` | WebRTC-specific configuration |
| `autoFallback` | `bool?` | Enable automatic fallback |
| `autoQuality` | `bool?` | Enable automatic quality switching |
| `volume` | `int?` | Initial volume (0-100) |
| `muted` | `bool?` | Start muted |
| `autoStart` | `bool?` | Auto-play on load |
| `controls` | `bool?` | Show player controls |

### OvenPlayerSource

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `String` | Source type: 'webrtc', 'hls', 'dash', 'mp4', etc. |
| `file` | `String` | Source URL |
| `label` | `String?` | Display label |
| `framerate` | `double?` | Video framerate |

### WebRTCConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| `connectionTimeout` | `int?` | Connection timeout in milliseconds |
| `timeoutMaxRetry` | `int?` | Max retry attempts on timeout |
| `iceServers` | `List<IceServer>?` | ICE servers for connection |
| `iceTransportPolicy` | `String?` | 'all' or 'relay' |
| `recoverPacketLoss` | `bool?` | Enable packet loss recovery |
| `playoutDelayHint` | `double?` | Playout delay in seconds |

## Controller API

### Playback Control

- `play()` - Start playback
- `pause()` - Pause playback
- `stop()` - Stop playback
- `seek(double position)` - Seek to position (seconds)

### Volume Control

- `setVolume(int volume)` - Set volume (0-100)
- `getVolume()` - Get current volume
- `setMute(bool mute)` - Mute/unmute
- `getMute()` - Get mute state

### Quality Control

- `setCurrentQuality(int index)` - Set quality level
- `getQualityLevels()` - Get available quality levels

### State Query

- `getPosition()` - Get current position (seconds)
- `getDuration()` - Get duration (seconds)
- `getState()` - Get player state

### Other

- `setFullscreen(bool fullscreen)` - Toggle fullscreen
- `load(List<OvenPlayerSource> sources)` - Load new sources
- `remove()` - Destroy player instance

## Events

The controller provides the following event streams:

- `onReady` - Player is ready
- `onStateChanged` - Playback state changed
- `onMetaChanged` - Metadata changed
- `onTime` - Playback position updated
- `onBufferChanged` - Buffer status changed
- `onVolumeChanged` - Volume changed
- `onMute` - Mute state changed
- `onQualityLevelChanged` - Quality level changed
- `onSourceChanged` - Source changed
- `onFullscreenChanged` - Fullscreen state changed
- `onError` - Error occurred
- `onSeek` - Seek performed
- `onResized` - Player resized
- `onContentMetaData` - Content metadata received (e.g., SEI data)

## Example App

See the `example/` directory for a complete working example.

## Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- OvenPlayer JavaScript library loaded in HTML

## Compatibility

This package is designed for **Flutter Web only**. It uses platform views and JavaScript interop to integrate with the OvenPlayer JavaScript library.

For native mobile platforms (iOS/Android), consider using:
- [flutter_webrtc](https://pub.dev/packages/flutter_webrtc) for WebRTC
- [video_player](https://pub.dev/packages/video_player) for HLS

## Related Projects

- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine) - Open-source streaming server
- [OvenPlayer](https://github.com/AirenSoft/OvenPlayer) - JavaScript player library
- [OvenLiveKit](https://github.com/AirenSoft/OvenLiveKit-Web) - Live streaming encoder

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
- [GitHub Issues](https://github.com/AirenSoft/OvenPlayer/issues)
- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [OvenMediaEngine Documentation](https://airensoft.gitbook.io/ovenmediaengine/)
