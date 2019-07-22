#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
readonly VERSION=$(cat eirini-release-version/version)
readonly IMAGE_NAMES=("opi" "opi-init" "rootfs-patcher" "secret-smuggler" "bits-waiter")
readonly DOCKER_HUB_USER=${DOCKER_HUB_USER:?Variable not set}
readonly DOCKER_HUB_PASSWORD=${DOCKER_HUB_PASSWORD:?Variable not set}

main() {
  start-docker
  build-images
  retag-images
  push "$VERSION"
  push latest
}

build-images() {
  ./eirini-release/docker/generate-docker-image.sh "$VERSION"
}

retag-images() {
  for image_name in "${IMAGE_NAMES[@]}"; do
    docker tag "eirini/$image_name:$VERSION" "eirini/$image_name:latest"
  done
}

push() {
  local -r version="${1:?Missing version parameter}"
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  for image_name in "${IMAGE_NAMES[@]}"; do
    docker push "eirini/$image_name:$version"
  done
}

main
