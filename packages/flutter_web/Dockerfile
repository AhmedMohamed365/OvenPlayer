# Multi-stage Dockerfile for Flutter Web OvenPlayer Demo
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml ./
COPY example/pubspec.yaml ./example/

# Get dependencies
RUN flutter pub get
RUN cd example && flutter pub get

# Copy source code
COPY . .

# Build the web app
RUN cd example && flutter build web --release

# Production stage - use nginx to serve
FROM nginx:alpine

# Copy built web app
COPY --from=builder /app/example/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
