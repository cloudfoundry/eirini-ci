#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
readonly VERSION_FILE="eirini-release-version/version"
readonly VERSION=$(cat "$VERSION_FILE")

main() {
  change-image-tag
  update-chart-version
  update-requirements-version
  helm-dep-update
  update-requirements-repo
  zip-templates
}

change-image-tag() {
  goml set -f eirini-release/helm/eirini/values.yaml -p opi.image_tag -v "$VERSION"
}

update-chart-version() {
  goml set -f eirini-release/helm/eirini/Chart.yaml -p version -v "$VERSION"
}

update-requirements-version() {
  goml set -f eirini-release/helm/cf/requirements.yaml -p dependencies.name:eirini.version -v "$VERSION"
}

helm-dep-update() {
  pushd "eirini-release/helm/cf"
  helm init --client-only
  helm repo add bits https://cloudfoundry-incubator.github.io/bits-service-release/helm
  helm dependency update
  popd || exit
}

update-requirements-repo() {
  goml set -f eirini-release/helm/cf/requirements.yaml -p dependencies.name:eirini.repository -v https://cloudfoundry-incubator.github.io/eirini-release
}

zip-templates() {
  pushd eirini-release/helm
  tar -zcvf "eirini-cf.tgz" cf
  tar -zcvf "eirini-uaa.tgz" uaa
  tar -zcvf "eirini.tgz" eirini
  popd
  mv eirini-release/helm/*.tgz release-output
}

main
