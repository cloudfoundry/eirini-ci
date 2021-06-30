#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

CHART_DIR=$(mktemp -d)
readonly CHART_DIR

# shellcheck disable=SC2064
trap "rm -r $CHART_DIR" EXIT

main() {
  compile-helm-chart
  package-helm-chart
}

compile-helm-chart() {
  cp -a eirini-controller/deployment/helm/* "$CHART_DIR"
  cp "$VALUES_PATH" "$CHART_DIR/"
}

package-helm-chart() {
  local version
  version=$(cat eirini-controller-version/version)
  helm package "$CHART_DIR" --app-version "$version" --version "$version" -d "$OUTPUT"
}

main
