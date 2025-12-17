# API Reference

## OvenPlayerController

The main controller class for managing an OvenPlayer instance.

### Constructor

```dart
OvenPlayerController({required OvenPlayerConfig config})
```

### Properties

- `bool isInitialized` - Whether the player is initialized
- `String? containerId` - The container element ID

### Event Callbacks

Set these properties to handle player events:

```dart
VoidCallback? onReady
ValueChanged<OvenPlayerState>? onStateChanged
ValueChanged<OvenPlayerError>? onError
ValueChanged<OvenPlayerMetadata>? onMetaChanged
ValueChanged<OvenPlayerTimeData>? onTime
ValueChanged<OvenPlayerBufferData>? onBufferChanged
ValueChanged<OvenPlayerVolumeData>? onVolumeChanged
ValueChanged<OvenPlayerSourceData>? onSourceChanged
ValueChanged<OvenPlayerQualityData>? onQualityLevelChanged
VoidCallback? onComplete
```

### Methods

#### Playback Control

- `void play()` - Start or resume playback
- `void pause()` - Pause playback
- `void stop()` - Stop playback
- `void seek(double position)` - Seek to position in seconds

#### Information

- `double getPosition()` - Get current playback position in seconds
- `double getDuration()` - Get video duration in seconds
- `String getState()` - Get current player state

#### Volume Control

- `void setVolume(int volume)` - Set volume (0-100)
- `int getVolume()` - Get current volume (0-100)
- `void setMute(bool mute)` - Set mute state
- `bool getMute()` - Get mute state

#### Source Management

- `int getCurrentSource()` - Get current source index
- `void setCurrentSource(int index)` - Switch to different source

#### Quality Management

- `List<OvenPlayerQualityLevel> getQualityLevels()` - Get available quality levels
- `int getCurrentQuality()` - Get current quality index
- `void setCurrentQuality(int index)` - Set quality level (use -1 for auto)

#### Display Control

- `void toggleFullScreen()` - Toggle fullscreen mode
- `bool getFullscreen()` - Check if in fullscreen
- `void showControls()` - Show player controls
- `void hideControls()` - Hide player controls

#### Lifecycle

- `void dispose()` - Clean up and remove player instance

## OvenPlayerWidget

Flutter widget for displaying the OvenPlayer.

### Constructor

```dart
OvenPlayerWidget({
  Key? key,
  required OvenPlayerController controller,
  double? width,
  double? height,
})
```

### Parameters

- `controller` - The OvenPlayerController instance
- `width` - Optional width for the player
- `height` - Optional height for the player

## OvenPlayerConfig

Configuration class for OvenPlayer initialization.

### Constructor

```dart
OvenPlayerConfig({
  required List<OvenPlayerSource> sources,
  bool? autoStart,
  bool? autoFallback,
  bool? mute,
  int? volume,
  bool? controls,
  int? hideControlsTimeout,
  bool? showBigPlayButton,
  bool? disableSeekUI,
  List<double>? playbackRates,
  OvenPlayerWebRTCConfig? webrtcConfig,
  String? title,
  String? image,
  dynamic width,
  dynamic height,
  String? aspectRatio,
})
```

### Parameters

- `sources` - List of video sources (required)
- `autoStart` - Start playback automatically (default: false)
- `autoFallback` - Enable automatic fallback on error (default: false)
- `mute` - Initial mute state (default: false)
- `volume` - Initial volume 0-100 (default: 100)
- `controls` - Show player controls (default: true)
- `hideControlsTimeout` - Time in ms to hide controls (default: 3000)
- `showBigPlayButton` - Show big play button (default: true)
- `disableSeekUI` - Disable seek controls (default: false)
- `playbackRates` - Available playback rates
- `webrtcConfig` - WebRTC specific configuration
- `title` - Playlist title
- `image` - Poster image URL
- `width` - Player width (number or string like "100%")
- `height` - Player height (number or string like "100%")
- `aspectRatio` - Aspect ratio (e.g., "16:9")

## OvenPlayerSource

Configuration for a video source.

### Constructor

```dart
OvenPlayerSource({
  String? label,
  required String type,
  required String file,
  int? framerate,
})
```

### Parameters

- `label` - Display label for the source
- `type` - Source type: 'webrtc', 'hls', 'dash', 'mp4', etc. (required)
- `file` - URL or path to the media file (required)
- `framerate` - Frame rate for the source

### Supported Types

- `webrtc` - WebRTC streaming (requires wss:// URL)
- `hls` - HLS streaming (requires .m3u8 URL)
- `dash` - DASH streaming (requires .mpd URL)
- `mp4` - MP4 video file
- `webm` - WebM video file

## OvenPlayerWebRTCConfig

WebRTC specific configuration.

### Constructor

```dart
OvenPlayerWebRTCConfig({
  int? timeoutMaxRetry,
  int? connectionTimeout,
  bool? recoverPacketLoss,
  bool? generatePublicCandidate,
})
```

### Parameters

- `timeoutMaxRetry` - Maximum number of timeout retries (default: 0)
- `connectionTimeout` - Connection timeout in milliseconds (default: 10000)
- `recoverPacketLoss` - Enable packet loss recovery (default: false)
- `generatePublicCandidate` - Generate public ICE candidates (default: true)

## OvenPlayerState

Enum representing player states.

### Values

- `idle` - Player is idle
- `loading` - Player is loading
- `playing` - Player is playing
- `paused` - Player is paused
- `error` - Player encountered an error
- `complete` - Playback completed

## Event Data Classes

### OvenPlayerError

```dart
class OvenPlayerError {
  final int code;
  final String message;
}
```

### OvenPlayerMetadata

```dart
class OvenPlayerMetadata {
  final int? duration;
  final int? width;
  final int? height;
  final String? mediaType;
}
```

### OvenPlayerTimeData

```dart
class OvenPlayerTimeData {
  final double position;
  final double duration;
}
```

### OvenPlayerBufferData

```dart
class OvenPlayerBufferData {
  final double buffer;
}
```

### OvenPlayerVolumeData

```dart
class OvenPlayerVolumeData {
  final int volume;
}
```

### OvenPlayerSourceData

```dart
class OvenPlayerSourceData {
  final int currentSource;
}
```

### OvenPlayerQualityLevel

```dart
class OvenPlayerQualityLevel {
  final int? bitrate;
  final int? width;
  final int? height;
  final String? label;
  final int index;
}
```

### OvenPlayerQualityData

```dart
class OvenPlayerQualityData {
  final int currentQuality;
  final bool isAuto;
}
```

## Usage Examples

### Basic Setup

```dart
final controller = OvenPlayerController(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'wss://example.com/stream',
      ),
    ],
    autoStart: true,
  ),
);

// In your widget tree
OvenPlayerWidget(controller: controller)
```

### Handling Events

```dart
controller.onReady = () {
  print('Player ready');
};

controller.onStateChanged = (state) {
  print('State: ${state.name}');
};

controller.onError = (error) {
  print('Error ${error.code}: ${error.message}');
};
```

### Playback Control

```dart
// Play/Pause
controller.play();
controller.pause();

// Seek
controller.seek(30.0); // Seek to 30 seconds

// Volume
controller.setVolume(50); // Set volume to 50%
controller.setMute(true); // Mute
```

### Source Management

```dart
// Get sources
final currentSource = controller.getCurrentSource();

// Switch source
controller.setCurrentSource(1); // Switch to second source
```

### Quality Management

```dart
// Get quality levels
final levels = controller.getQualityLevels();
for (var level in levels) {
  print('${level.label}: ${level.width}x${level.height}');
}

// Set quality
controller.setCurrentQuality(0); // Set to first quality
controller.setCurrentQuality(-1); // Set to auto
```
