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
      initialRoute: '/',
      routes: {
        '/': (context) => const VideoPlayerPage(),
        '/grid': (context) => const GridPlayerPage(),
        '/grid16': (context) => const Grid16PlayerPage(),
      },
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
          // WebRTC source from OvenMediaEngine server
          OvenPlayerSource(
            label: 'WebRTC Live',
            type: 'webrtc',
            file: 'ws://100.97.40.30:3333/app/ppe_stream',
          ),
        ],
        autoStart: true,
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
    if (seconds.isInfinite || seconds.isNaN || seconds < 0) {
      return 'LIVE';
    }
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
          // Player container - takes most of the space
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: OvenPlayerWidget(controller: _controller),
            ),
          ),

          // Status and controls - scrollable
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status text
                  Text(
                    _statusText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Time display
                  Text(
                    'Time: ${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 36,
                        onPressed: () => _controller.play(),
                        tooltip: 'Play',
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 36,
                        onPressed: () => _controller.pause(),
                        tooltip: 'Pause',
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        iconSize: 36,
                        onPressed: () => _controller.stop(),
                        tooltip: 'Stop',
                      ),
                      IconButton(
                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                        iconSize: 36,
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
                  const SizedBox(height: 8),

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
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/grid'),
                        child: const Text('Grid View'),
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

// ============================================================================
// Grid Player Page - Display 4 WebRTC streams in a grid
// ============================================================================

class GridPlayerPage extends StatefulWidget {
  const GridPlayerPage({super.key});

  @override
  State<GridPlayerPage> createState() => _GridPlayerPageState();
}

class _GridPlayerPageState extends State<GridPlayerPage> {
  final List<OvenPlayerController> _controllers = [];
  final List<String> _streamLabels = [
    'Stream 1',
    'Stream 2', 
    'Stream 3',
    'Stream 4',
  ];
  
  // You can customize these URLs for each stream
  final List<String> _streamUrls = [
    'ws://100.97.40.30:3333/app/ppe_stream',
    'ws://100.97.40.30:3333/app/ppe_stream',
    'ws://100.97.40.30:3333/app/ppe_stream',
    'ws://100.97.40.30:3333/app/ppe_stream',
  ];

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    for (int i = 0; i < 4; i++) {
      final controller = OvenPlayerController(
        config: OvenPlayerConfig(
          sources: [
            OvenPlayerSource(
              label: _streamLabels[i],
              type: 'webrtc',
              file: _streamUrls[i],
            ),
          ],
          autoStart: true,
          autoFallback: true,
          mute: true, // Mute by default to avoid audio overlap
          volume: 100,
          controls: true,
          showBigPlayButton: true,
          webrtcConfig: OvenPlayerWebRTCConfig(
            timeoutMaxRetry: 3,
            connectionTimeout: 10000,
          ),
        ),
      );

      controller.onReady = () {
        debugPrint('${_streamLabels[i]} is ready');
      };

      controller.onError = (error) {
        debugPrint('${_streamLabels[i]} error: ${error.message}');
      };

      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('OvenPlayer Grid View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_expandedIndex != null)
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () => setState(() => _expandedIndex = null),
              tooltip: 'Show Grid',
            ),
          IconButton(
            icon: const Icon(Icons.grid_4x4),
            onPressed: () => Navigator.pushReplacementNamed(context, '/grid16'),
            tooltip: '4x4 Grid',
          ),
        ],
      ),
      body: _expandedIndex != null
          ? _buildExpandedView(_expandedIndex!)
          : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildPlayerCard(index);
      },
    );
  }

  Widget _buildExpandedView(int index) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: OvenPlayerWidget(controller: _controllers[index]),
          ),
        ),
        _buildControlBar(index),
      ],
    );
  }

  Widget _buildPlayerCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Player
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: OvenPlayerWidget(controller: _controllers[index]),
            ),
          ),
          // Overlay with controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _streamLabels[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        iconSize: 20,
                        onPressed: () => _controllers[index].play(),
                        tooltip: 'Play',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.pause, color: Colors.white),
                        iconSize: 20,
                        onPressed: () => _controllers[index].pause(),
                        tooltip: 'Pause',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _controllers[index].getMute()
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          final isMuted = _controllers[index].getMute();
                          _controllers[index].setMute(!isMuted);
                          setState(() {});
                        },
                        tooltip: 'Toggle Mute',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        iconSize: 20,
                        onPressed: () => _toggleExpand(index),
                        tooltip: 'Expand',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  Widget _buildControlBar(int index) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _streamLabels[index],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].play(),
            tooltip: 'Play',
          ),
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].pause(),
            tooltip: 'Pause',
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].stop(),
            tooltip: 'Stop',
          ),
          IconButton(
            icon: Icon(
              _controllers[index].getMute() ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            iconSize: 32,
            onPressed: () {
              final isMuted = _controllers[index].getMute();
              _controllers[index].setMute(!isMuted);
              setState(() {});
            },
            tooltip: 'Toggle Mute',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].toggleFullScreen(),
            tooltip: 'Native Fullscreen',
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            iconSize: 32,
            onPressed: () => setState(() => _expandedIndex = null),
            tooltip: 'Back to Grid',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Grid 16 Player Page - Display 16 WebRTC streams in a 4x4 grid
// ============================================================================

class Grid16PlayerPage extends StatefulWidget {
  const Grid16PlayerPage({super.key});

  @override
  State<Grid16PlayerPage> createState() => _Grid16PlayerPageState();
}

class _Grid16PlayerPageState extends State<Grid16PlayerPage> {
  final List<OvenPlayerController> _controllers = [];
  final String _baseStreamUrl = 'ws://100.97.40.30:3333/app/ppe_stream';
  
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    for (int i = 0; i < 16; i++) {
      final controller = OvenPlayerController(
        config: OvenPlayerConfig(
          sources: [
            OvenPlayerSource(
              label: 'Stream ${i + 1}',
              type: 'webrtc',
              file: _baseStreamUrl,
            ),
          ],
          autoStart: true,
          autoFallback: true,
          mute: true,
          volume: 100,
          controls: false, // Hide default controls for compact view
          showBigPlayButton: false,
          webrtcConfig: OvenPlayerWebRTCConfig(
            timeoutMaxRetry: 3,
            connectionTimeout: 10000,
          ),
        ),
      );

      controller.onReady = () {
        debugPrint('Stream ${i + 1} is ready');
      };

      controller.onError = (error) {
        debugPrint('Stream ${i + 1} error: ${error.message}');
      };

      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_expandedIndex != null 
            ? 'Stream ${_expandedIndex! + 1}' 
            : 'OvenPlayer 4x4 Grid'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_expandedIndex != null)
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () => setState(() => _expandedIndex = null),
              tooltip: 'Show Grid',
            ),
          IconButton(
            icon: const Icon(Icons.grid_3x3),
            onPressed: () => Navigator.pushReplacementNamed(context, '/grid'),
            tooltip: '2x2 Grid',
          ),
        ],
      ),
      body: _expandedIndex != null
          ? _buildExpandedView(_expandedIndex!)
          : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        return _buildPlayerCard(index);
      },
    );
  }

  Widget _buildExpandedView(int index) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: OvenPlayerWidget(controller: _controllers[index]),
          ),
        ),
        _buildControlBar(index),
      ],
    );
  }

  Widget _buildPlayerCard(int index) {
    return GestureDetector(
      onDoubleTap: () => _toggleExpand(index),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Player
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: OvenPlayerWidget(controller: _controllers[index]),
              ),
            ),
            // Compact overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMiniIconButton(
                          icon: Icons.volume_off,
                          onPressed: () {
                            final isMuted = _controllers[index].getMute();
                            _controllers[index].setMute(!isMuted);
                            setState(() {});
                          },
                          isActive: !_controllers[index].getMute(),
                        ),
                        _buildMiniIconButton(
                          icon: Icons.fullscreen,
                          onPressed: () => _toggleExpand(index),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildControlBar(int index) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Stream ${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].play(),
            tooltip: 'Play',
          ),
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].pause(),
            tooltip: 'Pause',
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].stop(),
            tooltip: 'Stop',
          ),
          IconButton(
            icon: Icon(
              _controllers[index].getMute() ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            iconSize: 32,
            onPressed: () {
              final isMuted = _controllers[index].getMute();
              _controllers[index].setMute(!isMuted);
              setState(() {});
            },
            tooltip: 'Toggle Mute',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            iconSize: 32,
            onPressed: () => _controllers[index].toggleFullScreen(),
            tooltip: 'Native Fullscreen',
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            iconSize: 32,
            onPressed: () => setState(() => _expandedIndex = null),
            tooltip: 'Back to Grid',
          ),
        ],
      ),
    );
  }
}
