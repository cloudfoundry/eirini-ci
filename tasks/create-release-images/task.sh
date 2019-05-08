#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
readonly VERSION=$(cat eirini-release-version/version)
readonly IMAGE_NAMES=("opi" "opi-init" "recipe" "secret-smuggler")
readonly DOCKER_HUB_USER=${DOCKER_HUB_USER:?Variable not set}
readonly DOCKER_HUB_PASSWORD=${DOCKER_HUB_PASSWORD:?Variable not set}

export-gopath() {
  pushd eirini-release || exit
  # shellcheck disable=SC1091
  source .envrc
  popd || exit
}

main() {
  start-docker
  export-gopath
  build-images
  retag-images
  push "$VERSION"
  push latest
}

build-images() {
  pushd "eirini-release/" || exit
  ./docker/generate-docker-image.sh "$VERSION"
  ./src/code.cloudfoundry.org/eirini/recipe/bin/build.sh "$VERSION"
  popd || exit
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
