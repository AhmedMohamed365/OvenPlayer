# Getting Started with OvenPlayer Flutter Web

This guide will help you integrate OvenPlayer Flutter Web into your Flutter web application and start streaming video.

## Prerequisites

- **Flutter SDK** (>= 3.0.0)
- **Dart SDK** (>= 3.0.0)
- **Web browser** (Chrome, Firefox, Safari, or Edge)
- **(Optional)** OvenMediaEngine server for WebRTC streaming

## Installation

### Step 1: Add Dependency

Add the package to your `pubspec.yaml`:

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

### Step 2: Include JavaScript Libraries

Edit your `web/index.html` to include the OvenPlayer JavaScript library:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... other head elements ... -->
  
  <!-- OvenPlayer JavaScript Library (required) -->
  <script src="https://cdn.jsdelivr.net/npm/ovenplayer/dist/ovenplayer.js"></script>
</head>
<body>
  <!-- ... body content ... -->
</body>
</html>
```

### Step 3: (Optional) Add HLS.js or Dash.js

For HLS or DASH support, include the respective libraries **before** OvenPlayer:

```html
<!-- HLS.js for HLS support (optional) -->
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest/dist/hls.min.js"></script>

<!-- Dash.js for DASH support (optional) -->
<script src="https://cdn.jsdelivr.net/npm/dashjs@latest/dist/dash.all.debug.min.js"></script>

<!-- OvenPlayer (required) -->
<script src="https://cdn.jsdelivr.net/npm/ovenplayer/dist/ovenplayer.js"></script>
```

## Quick Start

### Minimal Example

Create a simple player with just a few lines:

```dart
import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('OvenPlayer Demo')),
        body: Center(
          child: OvenPlayer(
            config: OvenPlayerConfig(
              sources: [
                OvenPlayerSource(
                  type: 'webrtc',
                  file: 'ws://localhost:3333/app/stream',
                ),
              ],
              autoStart: true,
              controls: true,
            ),
            width: 640,
            height: 360,
          ),
        ),
      ),
    );
  }
}
```

### Run the App

```bash
flutter run -d chrome
```

## Streaming Protocols

### WebRTC (Sub-second Latency)

For sub-second latency streaming with OvenMediaEngine:

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'webrtc',
      file: 'ws://your-ome-server:3333/app/stream',
      label: 'Live WebRTC',
    ),
  ],
  webrtcConfig: WebRTCConfig(
    connectionTimeout: 10000,
    timeoutMaxRetry: 3,
    recoverPacketLoss: true,
  ),
)
```

**WebRTC URL Format:**
- `ws://hostname:port/app/stream` - for non-SSL
- `wss://hostname:port/app/stream` - for SSL

### HLS (Low Latency)

For HLS streaming:

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'hls',
      file: 'https://your-server/path/stream.m3u8',
      label: 'HLS Stream',
    ),
  ],
)
```

### DASH (MPEG-DASH)

For DASH streaming:

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'dash',
      file: 'https://your-server/path/stream.mpd',
      label: 'DASH Stream',
    ),
  ],
)
```

### Multiple Sources with Fallback

Configure multiple sources for automatic fallback:

```dart
OvenPlayerConfig(
  sources: [
    // Primary: WebRTC for lowest latency
    OvenPlayerSource(
      type: 'webrtc',
      file: 'ws://your-ome-server:3333/app/stream',
      label: 'Ultra Low Latency',
    ),
    // Fallback: HLS for compatibility
    OvenPlayerSource(
      type: 'hls',
      file: 'https://your-server/app/stream/llhls.m3u8',
      label: 'Low Latency',
    ),
  ],
  autoFallback: true,
)
```

## Using the Controller

For programmatic control, use `OvenPlayerController`:

```dart
class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late OvenPlayerController _controller;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    
    // Create controller
    _controller = OvenPlayerController('video-player');
    
    // Listen to events
    _controller.onReady.listen((_) {
      setState(() => _status = 'Ready');
    });
    
    _controller.onStateChanged.listen((event) {
      setState(() => _status = 'State: ${event.newState}');
    });
    
    _controller.onError.listen((error) {
      setState(() => _status = 'Error: ${error.message}');
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
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Column(
        children: [
          // Player
          Expanded(
            child: OvenPlayer(
              config: OvenPlayerConfig(
                sources: [
                  OvenPlayerSource(
                    type: 'webrtc',
                    file: 'ws://localhost:3333/app/stream',
                  ),
                ],
                autoStart: false,
              ),
              controller: _controller,
            ),
          ),
          
          // Status
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(_status),
          ),
          
          // Controls
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

## Common Use Cases

### Live Streaming

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://live-server:3333/live/stream',
      ),
    ],
    autoStart: true,
    controls: true,
    disableSeekUI: true, // Live streams don't support seeking
  ),
)
```

### VOD (Video on Demand)

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'mp4',
        file: 'https://example.com/video.mp4',
      ),
    ],
    autoStart: false,
    controls: true,
    image: 'https://example.com/thumbnail.jpg', // Poster image
  ),
)
```

### Multi-Quality Streaming

```dart
// OvenMediaEngine handles quality switching automatically
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://server:3333/app/stream',
      ),
    ],
    autoQuality: true, // Enable automatic quality switching
    controls: true,
  ),
)
```

## Setting Up OvenMediaEngine (Optional)

If you want to test WebRTC streaming locally:

### Using Docker

```bash
docker run -d \
  --name ome \
  -p 1935:1935 \
  -p 3333:3333 \
  -p 3478:3478 \
  -p 8080:8080 \
  -p 9000:9000 \
  airensoft/ovenmediaengine:latest
```

### Push a Test Stream

Using FFmpeg to push a stream:

```bash
ffmpeg -re -i input.mp4 \
  -c:v libx264 -preset veryfast \
  -b:v 2000k -maxrate 2000k -bufsize 4000k \
  -c:a aac -b:a 128k \
  -f flv rtmp://localhost:1935/app/stream
```

### Play the Stream

```dart
OvenPlayerSource(
  type: 'webrtc',
  file: 'ws://localhost:3333/app/stream',
)
```

## WebRTC Configuration

### Using STUN Servers

```dart
WebRTCConfig(
  iceServers: [
    IceServer(
      urls: ['stun:stun.l.google.com:19302'],
    ),
  ],
)
```

### Using TURN Servers

For networks behind NAT or firewall:

```dart
WebRTCConfig(
  iceServers: [
    IceServer(
      urls: ['stun:stun.l.google.com:19302'],
    ),
    IceServer(
      urls: [
        'turn:your-turn-server:3478?transport=udp',
        'turn:your-turn-server:3478?transport=tcp',
      ],
      username: 'your-username',
      credential: 'your-password',
    ),
  ],
  iceTransportPolicy: 'relay', // Force TURN
)
```

## Handling Events

### Listening to Playback Position

```dart
_controller.onTime.listen((event) {
  print('Position: ${event.position}s / ${event.duration}s');
  
  // Update progress bar
  setState(() {
    progress = event.position / event.duration;
  });
});
```

### Handling Errors

```dart
_controller.onError.listen((error) {
  // Show error dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(error.message ?? 'Unknown error'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
});
```

### Detecting State Changes

```dart
_controller.onStateChanged.listen((event) {
  switch (event.newState) {
    case 'loading':
      // Show loading indicator
      break;
    case 'playing':
      // Hide loading, show pause button
      break;
    case 'paused':
      // Show play button
      break;
    case 'error':
      // Show error state
      break;
  }
});
```

## Troubleshooting

### Player not loading

**Problem:** Player doesn't appear or shows error.

**Solutions:**
1. Check browser console for JavaScript errors
2. Verify OvenPlayer library is loaded: Open browser DevTools → Network tab
3. Make sure Flutter app is running in web mode
4. Check that the HTML element is created correctly

### WebRTC connection fails

**Problem:** WebRTC stream doesn't connect.

**Solutions:**
1. Verify OvenMediaEngine is running: `http://localhost:9000/`
2. Check WebSocket port (default 3333) is accessible
3. Verify stream name matches: `/app/stream`
4. Check browser console for WebRTC errors
5. Try with STUN/TURN servers if behind NAT

### Stream URL format

Make sure you're using the correct URL format:
- WebRTC: `ws://` or `wss://` (WebSocket)
- HLS: `http://` or `https://` (ends with `.m3u8`)
- DASH: `http://` or `https://` (ends with `.mpd`)
- MP4: `http://` or `https://` (ends with `.mp4`)

### CORS issues

If streaming from a different domain, make sure CORS is enabled on the server.

## Next Steps

- [API Reference](API.md) - Complete API documentation
- [Architecture](ARCHITECTURE.md) - Technical architecture details
- [Example App](example/) - Full-featured example application
- [OvenPlayer Docs](https://airensoft.gitbook.io/ovenplayer/) - JavaScript library docs
- [OvenMediaEngine](https://airensoft.gitbook.io/ovenmediaengine/) - Streaming server docs

## Support

For issues and questions:
- [GitHub Issues](https://github.com/AirenSoft/OvenPlayer/issues)
- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [Community Forum](https://airensoft.com/community)

## License

MIT License - see [LICENSE](LICENSE) file for details.
