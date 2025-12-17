# Docker Setup for OvenPlayer Flutter Web Example

This guide explains how to build and run the OvenPlayer Flutter Web example using Docker with OvenMediaEngine for live WebRTC streaming testing.

## Prerequisites

- Docker (version 20.10 or later)
- Docker Compose (version 1.29 or later)

## Quick Start

### 1. Start the Services

From the `packages/flutter_web/example` directory, run:

```bash
docker-compose up -d
```

This will start two services:
- **OvenMediaEngine** - WebRTC streaming server on ports 1935, 3333, 3478, 8080, 9000
- **Flutter Web App** - The example application on port 8090

### 2. Access the Application

Open your browser and navigate to:
```
http://localhost:8090
```

### 3. Configure WebRTC Source

In the application, you'll see a "Stream URL" input field. The default URL format is:
```
ws://localhost:3333/app/stream
```

You can change this to match your stream name or use a different OvenMediaEngine server:
```
ws://100.68.61.22:3333/app/ppe_stream/master
```

Just update the URL in the input field and click "Load Stream" - no rebuild required!

## Streaming to OvenMediaEngine

To test with a live stream, push a stream to OvenMediaEngine using FFmpeg or OBS:

### Using FFmpeg

```bash
# Stream a test pattern
ffmpeg -re -f lavfi -i testsrc=size=1280x720:rate=30 \
  -f lavfi -i sine=frequency=1000:sample_rate=44100 \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v 2000k -maxrate 2000k -bufsize 4000k \
  -c:a aac -b:a 128k \
  -f flv rtmp://localhost:1935/app/stream

# Stream from a video file
ffmpeg -re -i input.mp4 \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v 2000k -maxrate 2000k -bufsize 4000k \
  -c:a aac -b:a 128k \
  -f flv rtmp://localhost:1935/app/stream

# Stream from webcam (Linux)
ffmpeg -f v4l2 -i /dev/video0 \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v 1000k -maxrate 1000k -bufsize 2000k \
  -c:a aac -b:a 128k \
  -f flv rtmp://localhost:1935/app/stream
```

### Using OBS Studio

1. Open OBS Studio
2. Go to Settings → Stream
3. Set:
   - Service: Custom
   - Server: `rtmp://localhost:1935/app`
   - Stream Key: `stream`
4. Click OK and start streaming

### WebRTC URL Format

Once streaming, access your stream in the Flutter app using:
```
ws://localhost:3333/app/stream
```

For different stream names:
```
ws://localhost:3333/[app_name]/[stream_name]
```

## Docker Services

### OvenMediaEngine Ports

- **1935** - RTMP input for streaming
- **3333** - WebRTC signaling (WebSocket)
- **3478** - TURN/STUN for NAT traversal
- **8080** - HLS output
- **9000** - Admin API

### Flutter App Port

- **8090** - Web application (http://localhost:8090)

## Viewing Logs

View logs for all services:
```bash
docker-compose logs -f
```

View logs for specific service:
```bash
docker-compose logs -f ovenmediaengine
docker-compose logs -f flutter-app
```

## Stopping Services

Stop all services:
```bash
docker-compose down
```

Stop and remove volumes:
```bash
docker-compose down -v
```

## Rebuilding

If you make changes to the Flutter code, rebuild the Docker image:

```bash
docker-compose up -d --build flutter-app
```

## Troubleshooting

### WebRTC Connection Fails

1. **Check OvenMediaEngine is running:**
   ```bash
   docker-compose ps
   curl http://localhost:9000
   ```

2. **Check if stream is available:**
   - Verify you're pushing a stream to RTMP
   - Check OME logs: `docker-compose logs ovenmediaengine`

3. **Verify WebRTC URL format:**
   - Must start with `ws://` or `wss://`
   - Format: `ws://hostname:3333/app/stream`

4. **Firewall/Network issues:**
   - Ensure ports 3333 and 3478 are accessible
   - For remote servers, use the actual IP/hostname

### Flutter App Not Loading

1. **Check if container is running:**
   ```bash
   docker-compose ps
   ```

2. **Check nginx logs:**
   ```bash
   docker-compose logs flutter-app
   ```

3. **Try accessing directly:**
   ```bash
   curl http://localhost:8090
   ```

### Can't Change URL

The URL input field is fully editable at runtime - no need to rebuild! Just:
1. Clear the current URL
2. Enter your new WebRTC URL (e.g., `ws://100.68.61.22:3333/app/ppe_stream/master`)
3. Click "Load Stream"

## Advanced Configuration

### Using External OvenMediaEngine

To connect to an external OME server:

1. Update the URL in the web interface to point to your server:
   ```
   ws://your-server-ip:3333/app/stream
   ```

2. Or modify `docker-compose.yml` to remove the OME service and just run the Flutter app:
   ```yaml
   version: '3.8'
   
   services:
     flutter-app:
       build:
         context: .
         dockerfile: Dockerfile
       ports:
         - "8090:80"
   ```

### Custom Build Configuration

To customize the Flutter build, edit the `Dockerfile`:

```dockerfile
# Use canvas renderer instead of html
RUN flutter build web --release --web-renderer canvaskit

# Enable source maps for debugging
RUN flutter build web --source-maps

# Profile mode
RUN flutter build web --profile
```

## Production Deployment

For production:

1. **Use a proper domain with SSL:**
   - Update nginx.conf with your domain
   - Add SSL certificates
   - Use `wss://` for WebRTC URLs

2. **Enable CORS properly:**
   - Configure allowed origins
   - Remove wildcard CORS in production

3. **Optimize caching:**
   - Configure CDN
   - Set appropriate cache headers

4. **Monitor logs:**
   - Set up log aggregation
   - Configure alerts

## Additional Resources

- [OvenMediaEngine Documentation](https://airensoft.gitbook.io/ovenmediaengine/)
- [OvenPlayer Documentation](https://airensoft.gitbook.io/ovenplayer/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Docker Documentation](https://docs.docker.com/)

## Support

For issues:
- OvenPlayer: https://github.com/AirenSoft/OvenPlayer/issues
- OvenMediaEngine: https://github.com/AirenSoft/OvenMediaEngine/issues
