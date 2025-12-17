# Docker Setup for OvenPlayer Flutter Web

This guide explains how to run the OvenPlayer Flutter Web demo using Docker.

## Quick Start

### Option 1: Flutter Demo Only (Using External WebRTC Stream)

Run the Flutter web application that connects to an external OvenMediaEngine server:

```bash
docker-compose up flutter-demo
```

The demo will be available at: **http://localhost:8080**

You'll need to configure the WebRTC URL in the application to point to your OvenMediaEngine server.

### Option 2: Complete Setup with OvenMediaEngine

Run both the Flutter demo and a local OvenMediaEngine server:

```bash
docker-compose --profile with-ome up
```

This starts:
- **Flutter Demo** at http://localhost:8080
- **OvenMediaEngine** WebRTC signaling at ws://localhost:3333

Note: Port 8080 is used by the Flutter demo, so OME's HLS will not be available. Adjust ports in `docker-compose.yml` if needed.

### Option 3: Production Build with Nginx

Build and run the production-optimized version:

```bash
# Build the image
docker build -t ovenplayer-flutter-web .

# Run the container
docker run -d -p 80:80 ovenplayer-flutter-web
```

The demo will be available at: **http://localhost**

## Configuration

### Configuring WebRTC Connection

Edit `example/lib/main.dart` to set your WebRTC stream URL:

```dart
OvenPlayerSource(
  label: 'WebRTC',
  type: 'webrtc',
  file: 'wss://your-server.com:3333/app/stream',
),
```

### Publishing to OvenMediaEngine

If running with OvenMediaEngine, publish a stream using FFmpeg or OBS:

**Using FFmpeg:**
```bash
ffmpeg -re -i input.mp4 -c:v libx264 -preset veryfast -tune zerolatency \
  -c:a aac -f flv rtmp://localhost:1935/app/stream
```

**Using OBS:**
1. Settings → Stream
2. Service: Custom
3. Server: `rtmp://localhost:1935/app`
4. Stream Key: `stream`

## Services

### Flutter Demo (flutter-demo)

- **Port**: 8080
- **Purpose**: Serves the Flutter web application
- **Volume**: Mounts current directory for live development

### OvenMediaEngine (ovenmediaengine)

- **Ports**:
  - `1935` - RTMP input
  - `3333` - WebRTC signaling
  - `3478` - TURN/STUN
  - `9000` - LL-HLS/DASH
  - `10000-10009/udp` - WebRTC media

- **Config**: `docker/ome-config/Server.xml`
- **Logs**: Stored in `ome-logs` volume

## Development Workflow

### Live Development

For live development with hot reload:

```bash
cd example
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

Or use Docker Compose which does this automatically:

```bash
docker-compose up flutter-demo
```

### Building for Production

```bash
cd example
flutter build web --release
```

The build output is in `example/build/web/`

## Troubleshooting

### Port Conflicts

If ports are already in use:

1. Edit `docker-compose.yml` to change port mappings
2. Example: Change `"8080:8080"` to `"3000:8080"`

### OvenMediaEngine Not Starting

Check the logs:

```bash
docker-compose logs ovenmediaengine
```

Common issues:
- Port conflicts (especially 8080)
- Insufficient UDP ports for WebRTC
- Firewall blocking UDP traffic

### Flutter Demo Not Accessible

Check the logs:

```bash
docker-compose logs flutter-demo
```

Ensure:
- Dependencies are installed (`flutter pub get`)
- No syntax errors in Dart code
- Port 8080 is not blocked

### WebRTC Connection Fails

1. **Check URL format**: Must be `wss://` for secure or `ws://` for local
2. **Verify OME is running**: `docker-compose ps`
3. **Check browser console**: Look for WebSocket errors
4. **Firewall**: Ensure UDP ports 10000-10009 are open
5. **HTTPS requirement**: WebRTC requires HTTPS in production

### CORS Issues

The nginx configuration includes CORS headers. If you still have issues:

1. Check browser console for CORS errors
2. Verify the nginx.conf is being used
3. Restart the container after config changes

## Network Configuration

The setup uses a custom Docker network (`ovenplayer-network`) for inter-container communication.

Services can communicate using container names:
- `ovenmediaengine` - The OME server
- `flutter-demo` - The Flutter web app

## Volumes

### flutter-pub-cache

Caches Flutter/Dart packages to speed up rebuilds.

To clear:
```bash
docker volume rm ovenplayer_flutter_pub_cache
```

### ome-logs

Stores OvenMediaEngine logs.

To view:
```bash
docker volume inspect ovenplayer_ome-logs
```

## Production Deployment

### Using Docker Hub

```bash
# Build and tag
docker build -t username/ovenplayer-flutter-web:latest .

# Push to Docker Hub
docker push username/ovenplayer-flutter-web:latest

# Deploy
docker pull username/ovenplayer-flutter-web:latest
docker run -d -p 80:80 username/ovenplayer-flutter-web:latest
```

### Using Docker Compose in Production

Create a `docker-compose.prod.yml`:

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "80:80"
    restart: always
```

Deploy:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Environment Variables

You can customize the setup with environment variables:

```bash
# Change Flutter web port
FLUTTER_PORT=3000 docker-compose up
```

Add to `docker-compose.yml`:
```yaml
environment:
  - FLUTTER_PORT=${FLUTTER_PORT:-8080}
```

## Security Considerations

### For Production:

1. **Use HTTPS**: WebRTC requires secure connections
2. **Configure CORS**: Restrict allowed origins
3. **Firewall Rules**: Limit exposed ports
4. **Update Dependencies**: Keep Flutter and packages updated
5. **Content Security Policy**: Add CSP headers in nginx
6. **Rate Limiting**: Add rate limiting to prevent abuse

### Recommended nginx additions:

```nginx
# Add to nginx.conf
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
limit_req zone=one burst=20 nodelay;

add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline';" always;
```

## Performance Optimization

### Enable HTTP/2

Update nginx configuration:

```nginx
listen 443 ssl http2;
```

### Optimize Flutter Build

```bash
flutter build web --release --web-renderer canvaskit
```

### Enable Caching

The nginx configuration includes caching for static assets. Adjust cache times in `docker/nginx.conf`.

## Monitoring

### Container Health

```bash
# Check running containers
docker-compose ps

# View logs
docker-compose logs -f

# Check resource usage
docker stats
```

### Application Logs

```bash
# Flutter demo logs
docker-compose logs -f flutter-demo

# OvenMediaEngine logs
docker-compose logs -f ovenmediaengine
```

## Cleanup

### Stop and remove containers:

```bash
docker-compose down
```

### Remove volumes:

```bash
docker-compose down -v
```

### Remove images:

```bash
docker-compose down --rmi all
```

## Advanced Configuration

### Custom OvenMediaEngine Config

Edit `docker/ome-config/Server.xml` to customize:
- Port numbers
- Codec settings
- Security options
- Recording settings

After changes:
```bash
docker-compose restart ovenmediaengine
```

### Multi-Container Scaling

For production, use orchestration:

**Docker Swarm:**
```bash
docker swarm init
docker stack deploy -c docker-compose.yml ovenplayer
```

**Kubernetes:**
Convert using kompose:
```bash
kompose convert -f docker-compose.yml
kubectl apply -f .
```

## Support

For issues:
- Check logs: `docker-compose logs`
- Verify network: `docker network inspect ovenplayer_ovenplayer-network`
- Test connectivity: `docker-compose exec flutter-demo ping ovenmediaengine`

## Resources

- [OvenMediaEngine Docs](https://airensoft.gitbook.io/ovenmediaengine/)
- [Flutter Web](https://flutter.dev/web)
- [Docker Compose Docs](https://docs.docker.com/compose/)
