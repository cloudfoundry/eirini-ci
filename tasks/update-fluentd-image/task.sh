#!/bin/bash

set -euox pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
  start-docker
  generate-fluentd-image
  push
}

generate-fluentd-image() {
  pushd eirini/fluentd || exit 1
    docker build . -t eirini/fluentd:"$TAG"
  popd || exit 1
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "eirini/fluentd:$TAG"
}

main
