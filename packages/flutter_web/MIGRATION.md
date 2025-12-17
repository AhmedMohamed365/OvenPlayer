# Migration Guide

Guide for developers migrating from React, Vue, or JavaScript implementations to Flutter Web.

## From React

If you're familiar with the React component, here's how to migrate:

### React Component

```jsx
import OvenPlayer from 'ovenplayer-react';

function App() {
  const config = {
    sources: [
      {
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream',
      },
    ],
  };

  const handleReady = () => {
    console.log('Player ready');
  };

  return (
    <OvenPlayer
      config={config}
      onReady={handleReady}
    />
  );
}
```

### Flutter Equivalent

```dart
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = OvenPlayerConfig(
      sources: [
        OvenPlayerSource(
          type: 'webrtc',
          file: 'ws://localhost:3333/app/stream',
        ),
      ],
    );

    return OvenPlayer(
      config: config,
      onReady: () {
        print('Player ready');
      },
    );
  }
}
```

### Key Differences

| React | Flutter | Notes |
|-------|---------|-------|
| JSX syntax | Widget tree | Use Flutter widgets |
| Hooks (useState, useEffect) | StatefulWidget | State management differs |
| Props | Constructor parameters | Similar concept |
| Callbacks | Callbacks or Streams | Flutter provides both |
| JavaScript | Dart | Different language |

## From Vue.js

If you're familiar with the Vue component:

### Vue Component

```vue
<template>
  <OvenPlayerVue3
    :config="playerConfig"
    @ready="handleReady"
  />
</template>

<script setup>
import OvenPlayerVue3 from "ovenplayer-vue3";

const playerConfig = {
  sources: [
    {
      type: 'webrtc',
      file: 'ws://localhost:3333/app/stream',
    },
  ],
};

const handleReady = () => {
  console.log('Player ready');
};
</script>
```

### Flutter Equivalent

```dart
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

class VideoPlayer extends StatelessWidget {
  final playerConfig = OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        type: 'webrtc',
        file: 'ws://localhost:3333/app/stream',
      ),
    ],
  );

  void handleReady() {
    print('Player ready');
  }

  @override
  Widget build(BuildContext context) {
    return OvenPlayer(
      config: playerConfig,
      onReady: handleReady,
    );
  }
}
```

## From JavaScript

If you're using the vanilla JavaScript library:

### JavaScript

```javascript
const player = OvenPlayer.create('player', {
  sources: [
    {
      type: 'webrtc',
      file: 'ws://localhost:3333/app/stream',
    },
  ],
});

player.on('ready', () => {
  console.log('Player ready');
});

player.play();
```

### Flutter Equivalent

```dart
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
    
    _controller = OvenPlayerController('player');
    
    _controller.onReady.listen((_) {
      print('Player ready');
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OvenPlayer(
      config: OvenPlayerConfig(
        sources: [
          OvenPlayerSource(
            type: 'webrtc',
            file: 'ws://localhost:3333/app/stream',
          ),
        ],
      ),
      controller: _controller,
    );
  }
}
```

## API Comparison

### Configuration

| JavaScript/React/Vue | Flutter |
|---------------------|---------|
| `config.sources` | `OvenPlayerConfig.sources` |
| `config.autoStart` | `OvenPlayerConfig.autoStart` |
| `config.controls` | `OvenPlayerConfig.controls` |
| `config.webrtcConfig` | `OvenPlayerConfig.webrtcConfig` |

### Methods

| JavaScript | Flutter |
|-----------|---------|
| `player.play()` | `controller.play()` |
| `player.pause()` | `controller.pause()` |
| `player.stop()` | `controller.stop()` |
| `player.seek(position)` | `controller.seek(position)` |
| `player.setVolume(volume)` | `controller.setVolume(volume)` |
| `player.getVolume()` | `controller.getVolume()` |
| `player.setMute(mute)` | `controller.setMute(mute)` |
| `player.getMute()` | `controller.getMute()` |
| `player.setCurrentQuality(index)` | `controller.setCurrentQuality(index)` |
| `player.getQualityLevels()` | `controller.getQualityLevels()` |

### Events

| JavaScript | Flutter |
|-----------|---------|
| `player.on('ready', callback)` | `controller.onReady.listen(callback)` |
| `player.on('stateChanged', callback)` | `controller.onStateChanged.listen(callback)` |
| `player.on('time', callback)` | `controller.onTime.listen(callback)` |
| `player.on('error', callback)` | `controller.onError.listen(callback)` |

## Common Patterns

### Pattern 1: Basic Player

**Before (JavaScript)**
```javascript
OvenPlayer.create('player', {
  sources: [{ type: 'webrtc', file: 'ws://...' }],
  autoStart: true,
});
```

**After (Flutter)**
```dart
OvenPlayer(
  config: OvenPlayerConfig(
    sources: [OvenPlayerSource(type: 'webrtc', file: 'ws://...')],
    autoStart: true,
  ),
)
```

### Pattern 2: Controlled Player

**Before (React)**
```jsx
const playerRef = useRef();

const handlePlay = () => {
  playerRef.current.play();
};

return (
  <>
    <OvenPlayer ref={playerRef} config={config} />
    <button onClick={handlePlay}>Play</button>
  </>
);
```

**After (Flutter)**
```dart
final controller = OvenPlayerController('player');

void handlePlay() {
  controller.play();
}

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      OvenPlayer(config: config, controller: controller),
      ElevatedButton(
        onPressed: handlePlay,
        child: Text('Play'),
      ),
    ],
  );
}
```

### Pattern 3: Event Handling

**Before (Vue)**
```vue
<OvenPlayerVue3
  @ready="onReady"
  @stateChanged="onStateChanged"
  @error="onError"
/>
```

**After (Flutter)**
```dart
@override
void initState() {
  super.initState();
  
  controller.onReady.listen(onReady);
  controller.onStateChanged.listen(onStateChanged);
  controller.onError.listen(onError);
}
```

### Pattern 4: Dynamic Configuration

**Before (JavaScript)**
```javascript
const player = OvenPlayer.create('player', config1);

// Later, load new config
player.load([
  { type: 'hls', file: 'https://...' }
]);
```

**After (Flutter)**
```dart
final controller = OvenPlayerController('player');

// Initial config
OvenPlayer(config: config1, controller: controller)

// Later, load new sources
controller.load([
  OvenPlayerSource(type: 'hls', file: 'https://...'),
]);
```

## State Management

### React (useState)

```jsx
const [isPlaying, setIsPlaying] = useState(false);

const handleStateChange = (event) => {
  setIsPlaying(event.newstate === 'playing');
};
```

### Flutter (StatefulWidget)

```dart
class _PlayerState extends State<Player> {
  bool isPlaying = false;

  void handleStateChange(StateChangedEvent event) {
    setState(() {
      isPlaying = event.newState == 'playing';
    });
  }

  @override
  void initState() {
    super.initState();
    controller.onStateChanged.listen(handleStateChange);
  }
}
```

### Flutter (Alternative: StreamBuilder)

```dart
StreamBuilder<StateChangedEvent>(
  stream: controller.onStateChanged,
  builder: (context, snapshot) {
    final isPlaying = snapshot.data?.newState == 'playing';
    return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
  },
)
```

## Styling Differences

### React/Vue (CSS)

```css
.player-container {
  width: 640px;
  height: 360px;
  margin: 0 auto;
}
```

```jsx
<div className="player-container">
  <OvenPlayer config={config} />
</div>
```

### Flutter (Widget Sizing)

```dart
Container(
  width: 640,
  height: 360,
  alignment: Alignment.center,
  child: OvenPlayer(
    config: config,
    width: 640,
    height: 360,
  ),
)
```

Or use responsive sizing:

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: OvenPlayer(config: config),
)
```

## Lifecycle Management

### React (useEffect)

```jsx
useEffect(() => {
  const player = OvenPlayer.create('player', config);
  
  return () => {
    player.remove();
  };
}, []);
```

### Flutter (StatefulWidget)

```dart
class _PlayerState extends State<Player> {
  late OvenPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = OvenPlayerController('player');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## Error Handling

### JavaScript

```javascript
player.on('error', (error) => {
  console.error('Player error:', error);
  alert(error.message);
});
```

### Flutter

```dart
controller.onError.listen((error) {
  debugPrint('Player error: $error');
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error.message ?? 'Unknown error')),
  );
});
```

## Advanced: Multiple Players

### JavaScript

```javascript
const player1 = OvenPlayer.create('player1', config1);
const player2 = OvenPlayer.create('player2', config2);
```

### Flutter

```dart
class MultiPlayer extends StatefulWidget {
  @override
  _MultiPlayerState createState() => _MultiPlayerState();
}

class _MultiPlayerState extends State<MultiPlayer> {
  late OvenPlayerController controller1;
  late OvenPlayerController controller2;

  @override
  void initState() {
    super.initState();
    controller1 = OvenPlayerController('player1');
    controller2 = OvenPlayerController('player2');
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OvenPlayer(config: config1, controller: controller1),
        OvenPlayer(config: config2, controller: controller2),
      ],
    );
  }
}
```

## Best Practices

### 1. Controller Management

**Do:**
```dart
class _PlayerState extends State<Player> {
  late final OvenPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OvenPlayerController('player');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Don't:**
```dart
// Don't create controller in build method
@override
Widget build(BuildContext context) {
  final controller = OvenPlayerController('player'); // ❌ Wrong!
  return OvenPlayer(config: config, controller: controller);
}
```

### 2. Event Subscription

**Do:**
```dart
late StreamSubscription _stateSubscription;

@override
void initState() {
  super.initState();
  _stateSubscription = controller.onStateChanged.listen(handleState);
}

@override
void dispose() {
  _stateSubscription.cancel();
  super.dispose();
}
```

**Or simply rely on controller disposal:**
```dart
@override
void initState() {
  super.initState();
  controller.onStateChanged.listen(handleState);
}

@override
void dispose() {
  controller.dispose(); // This closes all streams
  super.dispose();
}
```

### 3. Configuration Updates

**Do:**
```dart
// Update config by recreating widget with new config
setState(() {
  currentConfig = newConfig;
});
```

**Or use controller.load():**
```dart
controller.load(newSources);
```

## Troubleshooting

### Issue: Controller not working

**Problem:** Methods called on controller have no effect.

**Solution:** Make sure controller is initialized before use:

```dart
@override
void initState() {
  super.initState();
  controller = OvenPlayerController('player');
  
  // Wait for ready before calling methods
  controller.onReady.listen((_) {
    controller.play();
  });
}
```

### Issue: Memory leaks

**Problem:** App slows down after multiple navigations.

**Solution:** Always dispose controllers:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### Issue: Stream events not firing

**Problem:** Event listeners not receiving events.

**Solution:** Subscribe to streams in initState, not in build:

```dart
@override
void initState() {
  super.initState();
  controller.onTime.listen(handleTime);
}
```

## Summary

Key differences when migrating to Flutter:

1. **Language**: Use Dart instead of JavaScript/TypeScript
2. **State Management**: Use StatefulWidget or state management solutions
3. **Events**: Use Streams instead of callbacks
4. **Styling**: Use Flutter widgets instead of CSS
5. **Lifecycle**: Use initState/dispose instead of useEffect/lifecycle hooks
6. **Type Safety**: Flutter/Dart provides stronger typing

The core concepts and APIs remain similar, making migration straightforward for developers familiar with OvenPlayer in other frameworks.
