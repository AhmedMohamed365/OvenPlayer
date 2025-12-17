import 'package:flutter/material.dart';
import 'package:ovenplayer_flutter_web/ovenplayer_flutter_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OvenPlayer Flutter Web Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController(
    text: 'ws://localhost:3333/app/stream',
  );
  final _typeController = TextEditingController(text: 'webrtc');
  
  OvenPlayerController? _playerController;
  String _playerState = 'idle';
  double _currentPosition = 0.0;
  double _duration = 0.0;
  int _volume = 100;
  bool _isMuted = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _playerController = OvenPlayerController('example-player');
    
    // Listen to events
    _playerController!.onStateChanged.listen((event) {
      setState(() {
        _playerState = event.newState;
        _statusMessage = 'State: ${event.newState}';
      });
    });
    
    _playerController!.onTime.listen((event) {
      setState(() {
        _currentPosition = event.position;
        _duration = event.duration;
      });
    });
    
    _playerController!.onVolumeChanged.listen((event) {
      setState(() {
        _volume = event.volume;
      });
    });
    
    _playerController!.onMute.listen((event) {
      setState(() {
        _isMuted = event.mute;
      });
    });
    
    _playerController!.onError.listen((error) {
      setState(() {
        _statusMessage = 'Error: ${error.message}';
      });
      _showSnackBar('Error: ${error.message}', isError: true);
    });
    
    _playerController!.onReady.listen((_) {
      setState(() {
        _statusMessage = 'Player ready';
      });
      _showSnackBar('Player is ready!');
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _urlController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OvenPlayer Flutter Web Example'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player widget
              Card(
                elevation: 4,
                child: Container(
                  height: 400,
                  color: Colors.black,
                  child: _playerController != null
                      ? OvenPlayer(
                          config: OvenPlayerConfig(
                            sources: [
                              OvenPlayerSource(
                                type: _typeController.text,
                                file: _urlController.text,
                                label: 'Live Stream',
                              ),
                            ],
                            autoStart: false,
                            controls: true,
                            webrtcConfig: const WebRTCConfig(
                              connectionTimeout: 10000,
                              timeoutMaxRetry: 3,
                              recoverPacketLoss: true,
                            ),
                          ),
                          controller: _playerController,
                          width: double.infinity,
                          height: 400,
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Status info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('State: $_playerState'),
                      Text('Position: ${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}'),
                      Text('Volume: $_volume'),
                      Text('Muted: $_isMuted'),
                      if (_statusMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stream configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stream Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'Stream Type',
                          hintText: 'webrtc, hls, dash, mp4',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'Stream URL',
                          hintText: 'ws://localhost:3333/app/stream',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          _playerController?.load([
                            OvenPlayerSource(
                              type: _typeController.text,
                              file: _urlController.text,
                            ),
                          ]);
                          _showSnackBar('Loading new stream...');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Stream'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Playback controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Playback Controls',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _playerController?.play(),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _playerController?.pause(),
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _playerController?.stop(),
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Volume controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Volume Controls',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _volume.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: _volume.toString(),
                              onChanged: (value) {
                                _playerController?.setVolume(value.toInt());
                              },
                            ),
                          ),
                          Text('$_volume'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _playerController?.setMute(!_isMuted);
                        },
                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                        label: Text(_isMuted ? 'Unmute' : 'Mute'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Example streams
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example Streams',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildExampleStreamTile(
                        'WebRTC (Local OME)',
                        'ws://localhost:3333/app/stream',
                        'webrtc',
                      ),
                      _buildExampleStreamTile(
                        'HLS Test Stream',
                        'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                        'hls',
                      ),
                      _buildExampleStreamTile(
                        'DASH Test Stream',
                        'https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd',
                        'dash',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Documentation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Make sure OvenPlayer JavaScript library is loaded in your web/index.html\n'
                        '2. For WebRTC: Run OvenMediaEngine on your server\n'
                        '3. For HLS: Include hls.js library\n'
                        '4. For DASH: Include dash.js library\n\n'
                        'See README.md for detailed setup instructions.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleStreamTile(String title, String url, String type) {
    return ListTile(
      title: Text(title),
      subtitle: Text(url, style: const TextStyle(fontSize: 10)),
      trailing: ElevatedButton(
        onPressed: () {
          setState(() {
            _urlController.text = url;
            _typeController.text = type;
          });
          _playerController?.load([
            OvenPlayerSource(
              type: type,
              file: url,
            ),
          ]);
          _showSnackBar('Loading $title...');
        },
        child: const Text('Load'),
      ),
    );
  }
}
