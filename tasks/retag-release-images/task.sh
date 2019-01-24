#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/docker
readonly PIPELINE_VERSION=$(cat deployment-version/version)
readonly VERSION=$(cat release-version/version)
readonly CI_TAG="${CLUSTER_NAME}-${PIPELINE_VERSION}"

main() {
  start-docker
  download-images
  retag-images
  push
}

download-images() {
  docker pull "eirini/opi:$CI_TAG"
  docker pull "eirini/opi-init:$CI_TAG"
  docker pull "eirini/recipe:$CI_TAG"
  docker pull "eirini/certs-copy:$CI_TAG"
  docker pull "eirini/certs-generate:$CI_TAG"
  docker pull "eirini/secret-smuggler:$CI_TAG"
}

retag-images() {
  docker tag "eirini/opi:$CI_TAG" "eirini/opi:$VERSION"
  docker tag "eirini/opi-init:$CI_TAG" "eirini/opi-init:$VERSION"
  docker tag "eirini/recipe:$CI_TAG" "eirini/recipe:$VERSION"
  docker tag "eirini/certs-copy:$CI_TAG" "eirini/certs-copy:$VERSION"
  docker tag "eirini/certs-generate:$CI_TAG" "eirini/certs-generate:$VERSION"
  docker tag "eirini/secret-smuggler:$CI_TAG" "eirini/secret-smuggler:$VERSION"
}

push() {
  docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
  docker push "eirini/opi:$VERSION"
  docker push "eirini/opi-init:$VERSION"
  docker push "eirini/recipe:$VERSION"
  docker push "eirini/certs-copy:$VERSION"
  docker push "eirini/certs-generate:$VERSION"
  docker push "eirini/secret-smuggler:$VERSION"
}

main
