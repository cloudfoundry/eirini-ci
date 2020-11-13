#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
readonly VERSION_FILE="eirini-release-version/version"
readonly VERSION=$(cat "$VERSION_FILE")

main() {
  update-chart-version
  zip-templates
}

update-chart-version() {
  goml set -f eirini-release/helm/eirini/Chart.yaml -p version -v "$VERSION"
}

zip-templates() {
  pushd eirini-release/helm
  tar -zcvf "eirini.tgz" eirini
  popd

  mv eirini-release/helm/*.tgz release-output

  pushd eirini-release
  tar -zcvf ../release-output-yaml/eirini-yaml.tgz deploy
  popd
}

main
