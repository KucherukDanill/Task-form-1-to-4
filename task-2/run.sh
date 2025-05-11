#!/bin/bash

echo "Building container..."
docker-compose up -d --build

sleep 5

echo "Test HTTPS:"
curl -vk https://localhost:443 > output.txt 2>&1
cat output.txt

echo "Container is running. You can access the website at:"
echo "HTTP: http://localhost:80"
echo "HTTPS: https://localhost:443"
