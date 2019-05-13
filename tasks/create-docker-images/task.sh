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
  export-gopath
  generate-opi-images
  push
}

export-gopath() {
  pushd eirini-release || exit
  # shellcheck disable=SC1091
  source .envrc
  popd || exit
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
}

main
