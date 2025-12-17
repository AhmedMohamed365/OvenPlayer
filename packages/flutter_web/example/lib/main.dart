import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OvenPlayer Flutter Web Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VideoPlayerPage(),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late OvenPlayerController _controller;
  String _statusText = 'Initializing...';
  double _currentPosition = 0.0;
  double _duration = 0.0;
  int _volume = 100;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = OvenPlayerController(
      config: OvenPlayerConfig(
        sources: [
          // Example WebRTC source
          OvenPlayerSource(
            label: 'WebRTC',
            type: 'webrtc',
            file: 'wss://demo.ovenplayer.com/app/stream',
          ),
          // Example HLS source as fallback
          OvenPlayerSource(
            label: 'HLS',
            type: 'hls',
            file: 'https://demo.ovenplayer.com/playlist.m3u8',
          ),
        ],
        autoStart: false,
        autoFallback: true,
        mute: false,
        volume: 100,
        controls: true,
        showBigPlayButton: true,
        webrtcConfig: OvenPlayerWebRTCConfig(
          timeoutMaxRetry: 3,
          connectionTimeout: 10000,
        ),
      ),
    );

    // Set up event handlers
    _controller.onReady = () {
      setState(() {
        _statusText = 'Player Ready';
      });
      debugPrint('Player is ready');
    };

    _controller.onStateChanged = (state) {
      setState(() {
        _statusText = 'State: ${state.name}';
      });
      debugPrint('Player state changed: ${state.name}');
    };

    _controller.onError = (error) {
      setState(() {
        _statusText = 'Error: ${error.message}';
      });
      debugPrint('Player error: ${error.message}');
    };

    _controller.onMetaChanged = (meta) {
      setState(() {
        _duration = meta.duration?.toDouble() ?? 0.0;
      });
      debugPrint('Metadata: ${meta.width}x${meta.height}');
    };

    _controller.onTime = (time) {
      setState(() {
        _currentPosition = time.position;
        _duration = time.duration;
      });
    };

    _controller.onVolumeChanged = (volumeData) {
      setState(() {
        _volume = volumeData.volume;
      });
    };

    _controller.onSourceChanged = (source) {
      debugPrint('Source changed to: ${source.currentSource}');
    };

    _controller.onQualityLevelChanged = (quality) {
      debugPrint('Quality changed to: ${quality.currentQuality}');
    };

    _controller.onComplete = () {
      setState(() {
        _statusText = 'Playback Complete';
      });
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('OvenPlayer Flutter Web Demo'),
      ),
      body: Column(
        children: [
          // Player container
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: OvenPlayerWidget(controller: _controller),
                ),
              ),
            ),
          ),

          // Status and controls
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status text
                  Text(
                    _statusText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Time display
                  Text(
                    'Time: ${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 48,
                        onPressed: () => _controller.play(),
                        tooltip: 'Play',
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 48,
                        onPressed: () => _controller.pause(),
                        tooltip: 'Pause',
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        iconSize: 48,
                        onPressed: () => _controller.stop(),
                        tooltip: 'Stop',
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                        iconSize: 48,
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            _controller.setMute(_isMuted);
                          });
                        },
                        tooltip: _isMuted ? 'Unmute' : 'Mute',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Volume slider
                  Row(
                    children: [
                      const Text('Volume: '),
                      Expanded(
                        child: Slider(
                          value: _volume.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: _volume.toString(),
                          onChanged: (value) {
                            setState(() {
                              _volume = value.toInt();
                              _controller.setVolume(_volume);
                            });
                          },
                        ),
                      ),
                      Text('$_volume%'),
                    ],
                  ),

                  // Additional controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _controller.toggleFullScreen(),
                        child: const Text('Toggle Fullscreen'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final qualities = _controller.getQualityLevels();
                          debugPrint('Quality levels: ${qualities.length}');
                        },
                        child: const Text('Get Qualities'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
