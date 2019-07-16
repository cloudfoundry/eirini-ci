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
  local git_sha
  git_sha="$(git -C "$CONTEXT_PATH" rev-parse HEAD)"

  docker build "$CONTEXT_PATH" -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH" --build-arg "GIT_SHA=$git_sha"
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "$IMAGE_NAME:$TAG"
}

main
