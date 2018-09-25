#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker

start-docker
./eirini-release/docker/generate-docker-image.sh "$TAG"

docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
docker push "eirini/opi:$TAG"
docker push "eirini/registry:$TAG"
