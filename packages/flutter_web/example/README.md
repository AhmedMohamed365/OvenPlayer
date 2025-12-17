# OvenPlayer Flutter Web Example

This example demonstrates how to use the OvenPlayer Flutter Web package to play WebRTC and LL-HLS streams.

## Features Demonstrated

- ✅ Basic player setup with WebRTC
- ✅ Player controls (play, pause, stop)
- ✅ Volume control
- ✅ Loading different streams dynamically
- ✅ Event handling (state changes, errors, etc.)
- ✅ Example streams (WebRTC, HLS, DASH)
- ✅ **Docker setup with OvenMediaEngine for testing**

## Quick Start with Docker 🐳

The easiest way to test the example with a real WebRTC stream:

```bash
# Start both the Flutter app and OvenMediaEngine
./start.sh

# Or manually:
docker-compose up -d
```

Then:
1. Open http://localhost:8090 in your browser
2. Push a stream to `rtmp://localhost:1935/app/stream`
3. The WebRTC URL `ws://localhost:3333/app/stream` is ready to use!

**Change the URL anytime** - just edit the "Stream URL" field in the app (no rebuild needed!).

For detailed Docker setup instructions, see [DOCKER_SETUP.md](DOCKER_SETUP.md).

## Running the Example

### Prerequisites

1. **Flutter SDK** (>= 3.0.0)
2. **Web browser** (Chrome, Firefox, Safari, or Edge)
3. **(Optional)** OvenMediaEngine running locally for WebRTC testing

### Steps

1. Navigate to the example directory:
   ```bash
   cd packages/flutter_web/example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome
   ```
   
   Or for other browsers:
   ```bash
   flutter run -d edge
   flutter run -d firefox
   ```

4. The app will open in your browser. You can:
   - Enter a stream URL
   - Select stream type (webrtc, hls, dash, mp4)
   - Click "Load Stream" to play
   - Use the playback controls to control the player
   - Try the example streams provided

## Testing with OvenMediaEngine

### Setting up OvenMediaEngine (for WebRTC testing)

1. Install and run OvenMediaEngine:
   ```bash
   # Using Docker
   docker run -d \
     -p 1935:1935 \
     -p 3333:3333 \
     -p 3478:3478 \
     -p 8080:8080 \
     -p 9000:9000 \
     airensoft/ovenmediaengine:latest
   ```

2. Push a stream to OME:
   ```bash
   # Using FFmpeg
   ffmpeg -re -i input.mp4 -c:v libx264 -c:a aac \
     -f flv rtmp://localhost:1935/app/stream
   ```

3. In the example app, use the WebRTC URL:
   ```
   ws://localhost:3333/app/stream
   ```

## Testing with HLS/DASH

The example includes public test streams:

### HLS Test Stream
- **Type**: hls
- **URL**: https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8

### DASH Test Stream
- **Type**: dash
- **URL**: https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd

## Project Structure

```
example/
├── lib/
│   └── main.dart          # Main application code
├── web/
│   ├── index.html         # HTML with OvenPlayer JS library
│   └── manifest.json      # Web app manifest
├── pubspec.yaml           # Dependencies
└── README.md             # This file
```

## Key Code Sections

### Creating a Player

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream',
      ),
    ],
    autoStart: false,
    controls: true,
  ),
  controller: _playerController,
)
```

### Listening to Events

```dart
_playerController.onStateChanged.listen((event) {
  print('State: ${event.newState}');
});

_playerController.onError.listen((error) {
  print('Error: ${error.message}');
});
```

### Controlling Playback

```dart
// Play
_playerController.play();

// Pause
_playerController.pause();

// Set volume
_playerController.setVolume(50);

// Seek
_playerController.seek(30.0); // Seek to 30 seconds
```

## Troubleshooting

### Player not loading
- Check browser console for errors
- Verify OvenPlayer JavaScript library is loaded (check Network tab)
- Make sure the stream URL is correct and accessible

### WebRTC connection fails
- Verify OvenMediaEngine is running
- Check that the signaling port (3333) is accessible
- Try using ICE servers if behind NAT

### HLS/DASH not working
- Make sure hls.js or dash.js is loaded in index.html
- Check browser compatibility
- Verify the stream URL is valid

## Browser Support

- ✅ Chrome/Chromium (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ⚠️ IE11 (not supported)

## Related Documentation

- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [OvenMediaEngine Documentation](https://airensoft.gitbook.io/ovenmediaengine/)
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)

## License

MIT License
