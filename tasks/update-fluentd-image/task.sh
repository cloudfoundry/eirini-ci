#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
  start-docker
  generate-fluentd-image
  push
}

generate-fluentd-image() {
  pushd eirini/fluentd || exit
    docker build . -t eirini/fluentd:"$TAG"
  popd || exit
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "eirini/fluentd:$TAG"
}
