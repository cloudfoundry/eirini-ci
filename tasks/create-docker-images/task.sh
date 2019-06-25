#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
readonly VERSION_FILE="deployment-version/version"
readonly VERSION=$(cat "$VERSION_FILE")
readonly TAG="${CLUSTER_NAME}-${VERSION}"

main() {
  start-docker
  generate-opi-images
  push
}

generate-opi-images() {
  ./eirini-release/docker/generate-docker-image.sh "$TAG"
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "eirini/opi:$TAG"
  docker push "eirini/opi-init:$TAG"
  docker push "eirini/secret-smuggler:$TAG"
  docker push "eirini/rootfs-patcher:$TAG"
  docker push "eirini/bits-waiter:$TAG"
}

main
