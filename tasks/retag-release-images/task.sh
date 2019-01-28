#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
readonly PIPELINE_VERSION=$(cat deployment-version/version)
readonly VERSION=$(cat release-version/version)
readonly CI_TAG="${CLUSTER_NAME:?Missing cluster name}-${PIPELINE_VERSION}"
readonly IMAGE_NAMES=("opi" "opi-init" "recipe" "certs-copy" "certs-generate" "secret-smuggler")
readonly DOCKER_HUB_USER=${DOCKER_HUB_USER:?Variable not set}
readonly DOCKER_HUB_PASSWORD=${DOCKER_HUB_PASSWORD:?Variable not set}

main() {
  start-docker
  download-images
  retag-images "$VERSION"
  retag-images latest
  push "$VERSION"
  push latest
}

download-images() {
  for image_name in "${IMAGE_NAMES[@]}"; do
    docker pull "eirini/$image_name:$CI_TAG"
  done
}

retag-images() {
  local -r version="${1:?Missing version parameter}"
  for image_name in "${IMAGE_NAMES[@]}"; do
    docker tag "eirini/$image_name:$CI_TAG" "eirini/$image_name:$version"
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
