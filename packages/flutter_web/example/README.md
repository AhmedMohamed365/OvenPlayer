# OvenPlayer Flutter Web Example

This is an example application demonstrating how to use the `ovenplayer_flutter_web` package to integrate OvenPlayer into a Flutter Web application.

## Features Demonstrated

- Basic player initialization
- WebRTC and HLS source configuration
- Playback controls (play, pause, stop)
- Volume and mute controls
- Event handling (state changes, errors, metadata, time updates)
- Quality level management
- Fullscreen support

## Running the Example

### Prerequisites

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- A web browser (Chrome recommended)

### Steps

1. Navigate to the example directory:
   ```bash
   cd packages/flutter_web/example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the web app:
   ```bash
   flutter run -d chrome
   ```

   Or build for production:
   ```bash
   flutter build web
   ```

## Understanding the Code

The example demonstrates:

### 1. Controller Initialization

```dart
_controller = OvenPlayerController(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        label: 'WebRTC',
        type: 'webrtc',
        file: 'wss://demo.ovenplayer.com/app/stream',
      ),
    ],
    autoStart: false,
    autoFallback: true,
    controls: true,
  ),
);
```

### 2. Event Handling

```dart
_controller.onReady = () {
  print('Player is ready');
};

_controller.onStateChanged = (state) {
  print('State: ${state.name}');
};

_controller.onError = (error) {
  print('Error: ${error.message}');
};
```

### 3. Player Widget

```dart
OvenPlayerWidget(controller: _controller)
```

### 4. Playback Control

```dart
_controller.play();
_controller.pause();
_controller.stop();
_controller.seek(30.0);
```

## Customization

You can customize the example by:

- Changing the video source URLs in the `sources` configuration
- Modifying the UI layout and controls
- Adding additional event handlers
- Implementing custom features like playlists or quality selection UI

## Notes

- Make sure the OvenPlayer JavaScript library is included in `web/index.html`
- WebRTC sources require a WebSocket URL (wss://)
- HLS sources require an m3u8 playlist URL
- The example uses demo URLs which may or may not be available

## Troubleshooting

If the player doesn't load:

1. Check the browser console for JavaScript errors
2. Verify the OvenPlayer library is loaded (check Network tab)
3. Ensure your video source URLs are correct and accessible
4. Check CORS settings if loading from a different domain

For WebRTC issues:

- Verify the WebSocket connection is successful
- Check that the OvenMediaEngine server is running and accessible
- Ensure proper SSL/TLS certificates for wss:// connections

## Learn More

- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer)
- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine)
- [Flutter Web](https://flutter.dev/web)
