#!/bin/bash
set -e
export IMAGE=${1:-manojkudocker/dev}
export TAG=${2:-latest}
docker compose -p react-app pull
docker compose -p react-app up -d --remove-orphans
docker image prune -f
echo "Deployed $IMAGE:$TAG"
