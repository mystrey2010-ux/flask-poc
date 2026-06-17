#!/bin/bash

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

echo "Restarting nginx proxy container..."
docker compose restart nginx_proxy

if [ $? -eq 0 ]; then
    echo "Nginx proxy container restarted successfully!"
else
    echo "Error: Failed to restart nginx proxy container"
    exit 1
fi
