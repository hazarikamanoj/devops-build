#!/bin/bash
set -e
IMAGE=${1:-manojkudocker/dev}
TAG=${2:-latest}
docker build -t "$IMAGE:$TAG" -t "$IMAGE:latest" .
echo "Built $IMAGE:$TAG"
