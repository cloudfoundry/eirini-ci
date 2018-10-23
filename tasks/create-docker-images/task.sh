#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
# shellcheck disable=SC1091
source eirini-release/.envrc

main() {
  start-docker
  generate-opi-images
  generate-recipe-image
  push
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
  docker push "eirini/registry:$TAG"
  docker push "eirini/opi-init:$TAG"
  docker push "eirini/recipe:$TAG"
}

main
