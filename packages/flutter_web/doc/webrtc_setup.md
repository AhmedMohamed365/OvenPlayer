# WebRTC Setup Guide

This guide explains how to set up WebRTC streaming with OvenPlayer Flutter Web.

## Overview

WebRTC (Web Real-Time Communication) enables sub-second latency streaming, making it ideal for live streaming applications where timing is critical.

## Prerequisites

- **OvenMediaEngine**: A streaming server that supports WebRTC output
- **Valid SSL Certificate**: Required for WebRTC connections (wss://)
- **Network Configuration**: Proper firewall rules and ports open

## OvenMediaEngine Setup

### 1. Install OvenMediaEngine

Follow the [OvenMediaEngine installation guide](https://airensoft.gitbook.io/ovenmediaengine/getting-started).

Quick Docker setup:

```bash
docker run -d \
  --name ome \
  -p 1935:1935 \
  -p 3333:3333 \
  -p 3478:3478 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 10000-10009:10000-10009/udp \
  airensoft/ovenmediaengine:latest
```

### 2. Configure WebRTC in OvenMediaEngine

Edit your `Server.xml` configuration:

```xml
<Server version="8">
  <Bind>
    <Providers>
      <RTMP>
        <Port>1935</Port>
      </RTMP>
    </Providers>
    <Publishers>
      <WebRTC>
        <Signalling>
          <Port>3333</Port>
          <TLSPort>3334</TLSPort>
        </Signalling>
        <IceCandidates>
          <IceCandidate>*:10000-10009/udp</IceCandidate>
        </IceCandidates>
      </WebRTC>
    </Publishers>
  </Bind>
  
  <VirtualHosts>
    <VirtualHost>
      <Name>default</Name>
      
      <Applications>
        <Application>
          <Name>app</Name>
          <Type>live</Type>
          
          <Publishers>
            <WebRTC>
              <Timeout>30000</Timeout>
            </WebRTC>
          </Publishers>
        </Application>
      </Applications>
    </VirtualHost>
  </VirtualHosts>
</Server>
```

### 3. Configure SSL/TLS

WebRTC requires secure connections (wss://). Configure your SSL certificate:

```xml
<TLS>
  <CertPath>/path/to/cert.crt</CertPath>
  <KeyPath>/path/to/private.key</KeyPath>
  <ChainCertPath>/path/to/chain.crt</ChainCertPath>
</TLS>
```

### 4. Test Your Setup

Send a test stream using OBS or FFmpeg:

```bash
ffmpeg -re -i input.mp4 -c:v libx264 -c:a aac -f flv rtmp://your-server:1935/app/stream
```

## Flutter Web Configuration

### Basic WebRTC Configuration

```dart
final controller = OvenPlayerController(
  config: OvenPlayerConfig(
    sources: [
      OvenPlayerSource(
        label: 'WebRTC Stream',
        type: 'webrtc',
        file: 'wss://your-server.com:3334/app/stream',
      ),
    ],
    autoStart: true,
    webrtcConfig: OvenPlayerWebRTCConfig(
      timeoutMaxRetry: 3,
      connectionTimeout: 10000,
    ),
  ),
);
```

### WebRTC Configuration Options

```dart
OvenPlayerWebRTCConfig(
  // Maximum number of connection retry attempts
  timeoutMaxRetry: 3,
  
  // Connection timeout in milliseconds
  connectionTimeout: 10000,
  
  // Enable packet loss recovery (helps with unstable networks)
  recoverPacketLoss: true,
  
  // Generate public ICE candidates
  generatePublicCandidate: true,
)
```

### URL Format

WebRTC URLs follow this format:

```
wss://{domain}:{signalling-port}/{app-name}/{stream-name}
```

Example:
```
wss://live.example.com:3334/app/mystream
```

## Advanced Configuration

### Multiple Sources with Fallback

Configure WebRTC as primary with HLS fallback:

```dart
OvenPlayerConfig(
  sources: [
    // Primary: WebRTC for sub-second latency
    OvenPlayerSource(
      label: 'WebRTC (Ultra Low Latency)',
      type: 'webrtc',
      file: 'wss://server.com:3334/app/stream',
    ),
    // Fallback: LLHLS for low latency
    OvenPlayerSource(
      label: 'LLHLS (Low Latency)',
      type: 'hls',
      file: 'https://server.com/app/stream/llhls.m3u8',
    ),
    // Fallback: Standard HLS
    OvenPlayerSource(
      label: 'HLS (Standard)',
      type: 'hls',
      file: 'https://server.com/app/stream/playlist.m3u8',
    ),
  ],
  autoFallback: true, // Automatically switch on error
)
```

### Network Resilience

Handle unstable networks:

```dart
_controller.onError = (error) {
  if (error.code == WEBRTC_TIMEOUT_ERROR) {
    // Retry or switch to fallback source
    _controller.setCurrentSource(_controller.getCurrentSource() + 1);
  }
};
```

### Monitoring Connection Quality

```dart
_controller.onBufferChanged = (buffer) {
  if (buffer.buffer < 10) {
    print('Warning: Low buffer, connection may be unstable');
  }
};
```

## Troubleshooting

### Connection Fails

**Problem**: WebRTC connection times out

**Solutions**:
1. Verify the WebSocket URL is correct (wss://)
2. Check that OvenMediaEngine is running
3. Ensure SSL certificate is valid
4. Check firewall rules allow WebRTC ports
5. Verify ICE candidates are properly configured

### SSL/TLS Errors

**Problem**: "NET::ERR_CERT_AUTHORITY_INVALID"

**Solutions**:
1. Use a valid SSL certificate from a trusted CA
2. For testing, you can use Let's Encrypt
3. Ensure certificate includes all necessary intermediate certificates

### No Video Despite Connection

**Problem**: WebRTC connects but no video displays

**Solutions**:
1. Check that the stream is actually being published to the server
2. Verify the app name and stream name match
3. Check browser console for codec errors
4. Ensure the video codec is supported (H.264 recommended)

### High Latency

**Problem**: WebRTC still has noticeable latency

**Solutions**:
1. Reduce keyframe interval in your encoder (2 seconds or less)
2. Enable packet loss recovery
3. Check network conditions
4. Verify server and client are geographically close

### Packet Loss

**Problem**: Video stuttering or artifacts

**Solutions**:
```dart
OvenPlayerWebRTCConfig(
  recoverPacketLoss: true, // Enable packet loss recovery
  timeoutMaxRetry: 5, // Increase retry attempts
)
```

## Network Requirements

### Bandwidth

- **Encoder**: Sufficient upload bandwidth for your bitrate
- **Viewer**: Sufficient download bandwidth for the stream
- **Recommended**: 1.5x the stream bitrate for stable playback

### Ports

Ensure these ports are open:

- **1935**: RTMP input (for streaming to OME)
- **3333/3334**: WebRTC signaling
- **10000-10009/udp**: WebRTC media (configurable)

### Firewall Rules

Example iptables rules:

```bash
# RTMP
iptables -A INPUT -p tcp --dport 1935 -j ACCEPT

# WebRTC Signaling
iptables -A INPUT -p tcp --dport 3333 -j ACCEPT
iptables -A INPUT -p tcp --dport 3334 -j ACCEPT

# WebRTC Media
iptables -A INPUT -p udp --dport 10000:10009 -j ACCEPT
```

## Best Practices

### 1. Use Multiple Sources

Always provide fallback sources:

```dart
sources: [
  OvenPlayerSource(type: 'webrtc', file: 'wss://...'),
  OvenPlayerSource(type: 'hls', file: 'https://...'),
]
```

### 2. Handle Errors Gracefully

```dart
_controller.onError = (error) {
  // Log error
  debugPrint('WebRTC Error: ${error.message}');
  
  // Show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Connection issue, trying fallback...')),
  );
  
  // Try next source
  if (_controller.getCurrentSource() < sources.length - 1) {
    _controller.setCurrentSource(_controller.getCurrentSource() + 1);
  }
};
```

### 3. Monitor Connection State

```dart
_controller.onStateChanged = (state) {
  switch (state) {
    case OvenPlayerState.loading:
      // Show loading indicator
      break;
    case OvenPlayerState.playing:
      // Hide loading, show player
      break;
    case OvenPlayerState.error:
      // Handle error
      break;
  }
};
```

### 4. Test on Different Networks

- Test on WiFi, 4G, 5G
- Test with network throttling
- Test behind corporate firewalls
- Test with VPN connections

### 5. Optimize Encoder Settings

For OBS:
- **Encoder**: x264
- **Rate Control**: CBR
- **Keyframe Interval**: 2 seconds
- **CPU Usage Preset**: veryfast
- **Profile**: baseline
- **Tune**: zerolatency

## Performance Tips

### Client-Side

1. Use appropriate player size (don't render larger than needed)
2. Dispose controllers when not in use
3. Monitor memory usage in long-running streams
4. Consider adaptive bitrate for varying network conditions

### Server-Side

1. Use appropriate keyframe interval (2 seconds recommended)
2. Enable hardware acceleration if available
3. Use appropriate bitrate for your audience
4. Consider adaptive bitrate streaming

## Security Considerations

1. **Always use WSS**: Never use unsecured WebSocket (ws://)
2. **Validate tokens**: Implement authentication if needed
3. **Rate limiting**: Protect against DoS attacks
4. **CORS**: Configure properly for your domain
5. **Certificate**: Use valid SSL from trusted CA

## Example: Complete WebRTC Setup

```dart
class LiveStreamPage extends StatefulWidget {
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  late OvenPlayerController _controller;
  String _statusMessage = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  void _setupPlayer() {
    _controller = OvenPlayerController(
      config: OvenPlayerConfig(
        sources: [
          OvenPlayerSource(
            label: 'WebRTC',
            type: 'webrtc',
            file: 'wss://live.example.com:3334/app/stream',
          ),
          OvenPlayerSource(
            label: 'HLS',
            type: 'hls',
            file: 'https://live.example.com/app/stream/playlist.m3u8',
          ),
        ],
        autoStart: true,
        autoFallback: true,
        webrtcConfig: OvenPlayerWebRTCConfig(
          timeoutMaxRetry: 3,
          connectionTimeout: 10000,
          recoverPacketLoss: true,
        ),
      ),
    );

    _controller.onReady = () {
      setState(() => _statusMessage = 'Connected');
    };

    _controller.onError = (error) {
      setState(() => _statusMessage = 'Error: ${error.message}');
    };

    _controller.onStateChanged = (state) {
      setState(() => _statusMessage = 'State: ${state.name}');
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Stream')),
      body: Column(
        children: [
          Expanded(child: OvenPlayerWidget(controller: _controller)),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(_statusMessage),
          ),
        ],
      ),
    );
  }
}
```

## Resources

- [OvenMediaEngine Documentation](https://airensoft.gitbook.io/ovenmediaengine/)
- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [WebRTC Specification](https://www.w3.org/TR/webrtc/)
- [OvenMediaEngine GitHub](https://github.com/AirenSoft/OvenMediaEngine)
