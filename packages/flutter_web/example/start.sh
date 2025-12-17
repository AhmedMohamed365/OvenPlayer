#!/bin/bash

# OvenPlayer Flutter Web - Docker Setup Script
# This script helps you quickly start the example app with OvenMediaEngine

set -e

echo "=========================================="
echo "OvenPlayer Flutter Web - Docker Setup"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo ""

# Build and start services
echo "Building and starting services..."
echo "This may take a few minutes on first run..."
echo ""

docker-compose up -d --build

echo ""
echo "=========================================="
echo "Services Started Successfully!"
echo "=========================================="
echo ""
echo "Flutter Web App: http://localhost:8090"
echo "OvenMediaEngine Admin: http://localhost:9000"
echo ""
echo "WebRTC Signaling URL: ws://localhost:3333/app/stream"
echo ""
echo "To push a test stream, run:"
echo "  ffmpeg -re -f lavfi -i testsrc=size=1280x720:rate=30 \\"
echo "    -f lavfi -i sine=frequency=1000:sample_rate=44100 \\"
echo "    -c:v libx264 -preset veryfast -b:v 2000k \\"
echo "    -c:a aac -b:a 128k \\"
echo "    -f flv rtmp://localhost:1935/app/stream"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""
echo "For more information, see DOCKER_SETUP.md"
echo "=========================================="
