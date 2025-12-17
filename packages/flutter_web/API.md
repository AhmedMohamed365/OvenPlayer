# API Reference

Complete API reference for OvenPlayer Flutter Web package.

## Table of Contents

- [OvenPlayer Widget](#ovenplayer-widget)
- [OvenPlayerController](#ovenplayercontroller)
- [OvenPlayerConfig](#ovenplayerconfig)
- [OvenPlayerSource](#ovenplayersource)
- [WebRTCConfig](#webrtcconfig)
- [IceServer](#iceserver)
- [Event Classes](#event-classes)

---

## OvenPlayer Widget

The main Flutter widget for displaying the video player.

### Constructor

```dart
OvenPlayer({
  Key? key,
  required OvenPlayerConfig config,
  OvenPlayerController? controller,
  VoidCallback? onReady,
  Function(dynamic error)? onError,
  double? width,
  double? height,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `config` | `OvenPlayerConfig` | **Required**. Player configuration |
| `controller` | `OvenPlayerController?` | Optional controller for programmatic control |
| `onReady` | `VoidCallback?` | Callback when player is ready |
| `onError` | `Function(dynamic)?` | Callback when an error occurs |
| `width` | `double?` | Player width (defaults to parent width) |
| `height` | `double?` | Player height (defaults to 16:9 ratio) |

### Example

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream',
      ),
    ],
  ),
  onReady: () => print('Player ready'),
  onError: (e) => print('Error: $e'),
  width: 640,
  height: 360,
)
```

---

## OvenPlayerController

Controller for managing player instance and playback.

### Constructor

```dart
OvenPlayerController(String containerId)
```

### Methods

#### Lifecycle

##### initialize
```dart
void initialize(OvenPlayerConfig config)
```
Initialize the player with configuration.

##### dispose
```dart
void dispose()
```
Dispose controller and close all streams.

##### remove
```dart
void remove()
```
Remove/destroy the player instance.

#### Playback Control

##### play
```dart
void play()
```
Start playback.

##### pause
```dart
void pause()
```
Pause playback.

##### stop
```dart
void stop()
```
Stop playback.

##### seek
```dart
void seek(double position)
```
Seek to a specific position in seconds.

**Parameters:**
- `position`: Position in seconds

#### Volume Control

##### setVolume
```dart
void setVolume(int volume)
```
Set volume level.

**Parameters:**
- `volume`: Volume level (0-100)

##### getVolume
```dart
int getVolume()
```
Get current volume level.

**Returns:** Volume level (0-100)

##### setMute
```dart
void setMute(bool mute)
```
Mute or unmute the player.

**Parameters:**
- `mute`: true to mute, false to unmute

##### getMute
```dart
bool getMute()
```
Get mute state.

**Returns:** true if muted, false otherwise

#### State Query

##### getPosition
```dart
double getPosition()
```
Get current playback position in seconds.

**Returns:** Current position in seconds

##### getDuration
```dart
double getDuration()
```
Get media duration in seconds.

**Returns:** Duration in seconds

##### getState
```dart
String getState()
```
Get current player state.

**Returns:** State string ('idle', 'loading', 'playing', 'paused', 'complete', 'error')

#### Quality Control

##### setCurrentQuality
```dart
void setCurrentQuality(int qualityIndex)
```
Set current quality level.

**Parameters:**
- `qualityIndex`: Index of quality level to switch to

##### getQualityLevels
```dart
List<Map<String, dynamic>> getQualityLevels()
```
Get available quality levels.

**Returns:** List of quality level objects

#### Other

##### setFullscreen
```dart
void setFullscreen(bool fullscreen)
```
Enter or exit fullscreen mode.

**Parameters:**
- `fullscreen`: true for fullscreen, false to exit

##### load
```dart
void load(List<OvenPlayerSource> sources)
```
Load new media sources.

**Parameters:**
- `sources`: List of media sources

### Event Streams

All event streams are `Stream<T>` and can be listened to with `.listen()`.

| Stream | Event Type | Description |
|--------|-----------|-------------|
| `onReady` | `void` | Player is ready |
| `onStateChanged` | `StateChangedEvent` | Playback state changed |
| `onMetaChanged` | `MetaChangedEvent` | Metadata changed |
| `onTime` | `TimeEvent` | Playback position updated (frequent) |
| `onBufferChanged` | `BufferChangedEvent` | Buffer status changed |
| `onVolumeChanged` | `VolumeChangedEvent` | Volume changed |
| `onMute` | `MuteEvent` | Mute state changed |
| `onQualityLevelChanged` | `QualityLevelChangedEvent` | Quality level changed |
| `onSourceChanged` | `SourceChangedEvent` | Source changed |
| `onPlaylistChanged` | `PlaylistChangedEvent` | Playlist changed |
| `onFullscreenChanged` | `FullscreenChangedEvent` | Fullscreen state changed |
| `onError` | `ErrorEvent` | Error occurred |
| `onSeek` | `SeekEvent` | Seek performed |
| `onResized` | `ResizedEvent` | Player resized |
| `onPlaybackRateChanged` | `PlaybackRateChangedEvent` | Playback rate changed |
| `onContentMetaData` | `ContentMetaDataEvent` | Content metadata received |

### Example

```dart
final controller = OvenPlayerController('my-player');

// Listen to events
controller.onStateChanged.listen((event) {
  print('State: ${event.newState}');
});

controller.onTime.listen((event) {
  print('Position: ${event.position}s');
});

// Control playback
controller.play();
controller.setVolume(50);
controller.seek(30.0);
```

---

## OvenPlayerConfig

Main configuration class for the player.

### Constructor

```dart
const OvenPlayerConfig({
  required List<OvenPlayerSource> sources,
  WebRTCConfig? webrtcConfig,
  bool? autoFallback,
  bool? autoQuality,
  int? volume,
  bool? muted,
  bool? autoStart,
  bool? controls,
  ParseStreamConfig? parseStream,
  bool? showBigPlayButton,
  bool? disableSeekUI,
  String? image,
  WatermarkConfig? watermark,
  TimecodeConfig? timecode,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `sources` | `List<OvenPlayerSource>` | **Required** | List of media sources |
| `webrtcConfig` | `WebRTCConfig?` | `null` | WebRTC-specific configuration |
| `autoFallback` | `bool?` | `null` | Enable automatic protocol fallback |
| `autoQuality` | `bool?` | `null` | Enable automatic quality switching |
| `volume` | `int?` | `null` | Initial volume (0-100) |
| `muted` | `bool?` | `null` | Start muted |
| `autoStart` | `bool?` | `null` | Auto-play on load |
| `controls` | `bool?` | `null` | Show player controls |
| `parseStream` | `ParseStreamConfig?` | `null` | Enable stream parsing (SEI data) |
| `showBigPlayButton` | `bool?` | `null` | Show big play button |
| `disableSeekUI` | `bool?` | `null` | Disable seek controls |
| `image` | `String?` | `null` | Poster image URL |
| `watermark` | `WatermarkConfig?` | `null` | Watermark configuration |
| `timecode` | `TimecodeConfig?` | `null` | Timecode configuration |

### Example

```dart
OvenPlayerConfig(
  sources: [
    OvenPlayerSource(
      type: 'webrtc',
      file: 'ws://localhost:3333/app/stream',
    ),
  ],
  autoStart: true,
  controls: true,
  volume: 80,
  muted: false,
  autoFallback: true,
)
```

---

## OvenPlayerSource

Media source definition.

### Constructor

```dart
const OvenPlayerSource({
  required String type,
  required String file,
  String? label,
  double? framerate,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | `String` | **Required**. Source type: 'webrtc', 'hls', 'dash', 'mp4', etc. |
| `file` | `String` | **Required**. Source URL or file path |
| `label` | `String?` | Display label for the source |
| `framerate` | `double?` | Video framerate |

### Supported Types

- `webrtc` - WebRTC streaming (OvenMediaEngine)
- `hls` - HTTP Live Streaming
- `llhls` - Low-Latency HLS
- `dash` - MPEG-DASH
- `lldash` - Low-Latency DASH
- `mp4` - MP4 video file
- `webm` - WebM video file

### Example

```dart
OvenPlayerSource(
  type: 'webrtc',
  file: 'ws://localhost:3333/app/stream',
  label: 'Live Stream',
  framerate: 30.0,
)
```

---

## WebRTCConfig

WebRTC-specific configuration.

### Constructor

```dart
const WebRTCConfig({
  int? connectionTimeout,
  int? timeoutMaxRetry,
  List<IceServer>? iceServers,
  String? iceTransportPolicy,
  bool? recoverPacketLoss,
  bool? generatePublicCandidate,
  double? playoutDelayHint,
})
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `connectionTimeout` | `int?` | `10000` | Connection timeout in milliseconds |
| `timeoutMaxRetry` | `int?` | `3` | Max retry attempts on timeout |
| `iceServers` | `List<IceServer>?` | `null` | ICE servers for connection |
| `iceTransportPolicy` | `String?` | `'all'` | 'all' or 'relay' |
| `recoverPacketLoss` | `bool?` | `false` | Enable packet loss recovery |
| `generatePublicCandidate` | `bool?` | `true` | Generate public candidate |
| `playoutDelayHint` | `double?` | `null` | Playout delay in seconds |

### Example

```dart
WebRTCConfig(
  connectionTimeout: 15000,
  timeoutMaxRetry: 5,
  iceServers: [
    IceServer(urls: ['stun:stun.l.google.com:19302']),
    IceServer(
      urls: ['turn:turn.example.com:3478'],
      username: 'user',
      credential: 'pass',
    ),
  ],
  recoverPacketLoss: true,
  playoutDelayHint: 0.5,
)
```

---

## IceServer

ICE server configuration for WebRTC.

### Constructor

```dart
const IceServer({
  required List<String> urls,
  String? username,
  String? credential,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `urls` | `List<String>` | **Required**. ICE server URLs |
| `username` | `String?` | Username for authentication |
| `credential` | `String?` | Credential/password for authentication |

### Example

```dart
// STUN server
IceServer(
  urls: ['stun:stun.l.google.com:19302'],
)

// TURN server with authentication
IceServer(
  urls: [
    'turn:turn.example.com:3478?transport=udp',
    'turn:turn.example.com:3478?transport=tcp',
  ],
  username: 'username',
  credential: 'password',
)
```

---

## Event Classes

### StateChangedEvent

```dart
class StateChangedEvent {
  final String prevState;
  final String newState;
}
```

**States:** 'idle', 'loading', 'playing', 'paused', 'complete', 'error'

### TimeEvent

```dart
class TimeEvent {
  final double position;  // Current position in seconds
  final double duration;  // Total duration in seconds
}
```

### ErrorEvent

```dart
class ErrorEvent {
  final String? code;
  final String? message;
  final dynamic error;
}
```

### MetaChangedEvent

```dart
class MetaChangedEvent {
  final int? duration;
  final String? type;
  final dynamic data;
}
```

### VolumeChangedEvent

```dart
class VolumeChangedEvent {
  final int volume;  // Volume level (0-100)
}
```

### MuteEvent

```dart
class MuteEvent {
  final bool mute;  // true if muted
}
```

### QualityLevelChangedEvent

```dart
class QualityLevelChangedEvent {
  final int currentQuality;
  final String? type;
  final bool? isAuto;
}
```

### FullscreenChangedEvent

```dart
class FullscreenChangedEvent {
  final bool fullscreen;  // true if fullscreen
}
```

### BufferChangedEvent

```dart
class BufferChangedEvent {
  final double buffer;  // Buffer level (0-100)
}
```

### SeekEvent

```dart
class SeekEvent {
  final double position;  // Seek position in seconds
}
```

### ResizedEvent

```dart
class ResizedEvent {
  final int width;
  final int height;
}
```

### ContentMetaDataEvent

```dart
class ContentMetaDataEvent {
  final String type;
  final dynamic data;
}
```

Used for receiving SEI metadata and other content metadata.

---

## Usage Examples

### Basic Usage

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream',
      ),
    ],
  ),
)
```

### With Controller

```dart
class MyPlayer extends StatefulWidget {
  @override
  _MyPlayerState createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  late OvenPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OvenPlayerController('my-player');
    
    _controller.onStateChanged.listen((event) {
      print('State: ${event.newState}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OvenPlayer(
          config: OvenPlayerConfig(
            sources: [...],
          ),
          controller: _controller,
        ),
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
          ],
        ),
      ],
    );
  }
}
```

### Advanced Configuration

```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream/high',
        label: 'High Quality',
      ),
      OvenPlayerSource(
        type: 'hls',
        file: 'https://example.com/stream.m3u8',
        label: 'HLS Fallback',
      ),
    ],
    webrtcConfig: WebRTCConfig(
      connectionTimeout: 15000,
      timeoutMaxRetry: 5,
      iceServers: [
        IceServer(urls: ['stun:stun.l.google.com:19302']),
      ],
      recoverPacketLoss: true,
    ),
    autoStart: true,
    controls: true,
    volume: 80,
    autoFallback: true,
    autoQuality: true,
  ),
  width: 1280,
  height: 720,
)
```
