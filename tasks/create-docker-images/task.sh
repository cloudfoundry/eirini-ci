#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
  start-docker
  export-gopath
  generate-opi-images
  generate-recipe-image
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

generate-recipe-image() {
  ./eirini-release/src/code.cloudfoundry.org/eirini/recipe/bin/build.sh "$TAG"
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "eirini/opi:$TAG"
  docker push "eirini/opi-init:$TAG"
  docker push "eirini/recipe:$TAG"
}

main
