# Flutter Web Build Stage
FROM ubuntu:22.04 AS build

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter doctor -v && \
    flutter config --enable-web && \
    flutter precache --web

# Set working directory
WORKDIR /app

# Copy parent package first (the ovenplayer_flutter_web library)
COPY ../ /packages/flutter_web/

# Copy example app files
COPY pubspec.yaml ./
COPY lib ./lib/
COPY web ./web/

# Update pubspec.yaml to use local path for the package
RUN sed -i 's|ovenplayer_flutter_web:.*|ovenplayer_flutter_web:\n    path: /packages/flutter_web/|g' pubspec.yaml || true

# Get dependencies
RUN flutter pub get

# Build the web application
RUN flutter build web --release --web-renderer html

# Production Stage - Serve with nginx
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
