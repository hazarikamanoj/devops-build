#!/bin/bash
set -e
export IMAGE=${1:-manojkudocker/dev}
export TAG=${2:-latest}
docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
echo "Deployed $IMAGE:$TAG"
