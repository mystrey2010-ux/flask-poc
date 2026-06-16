#!/bin/bash

echo "Stopping nginx proxy container..."
docker stop nginx_proxy

echo "Starting nginx proxy container..."
docker start nginx_proxy

echo "Nginx proxy container restarted successfully!"
