#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

RENDER_DIR=$(mktemp -d)
readonly RENDER_DIR

# shellcheck disable=SC2064
trap "rm -r $RENDER_DIR" EXIT

main() {
  generate-eirini-controller-yamls
  zip-eirini-controller-yamls
}

generate-eirini-controller-yamls() {
  local values_yaml="$PWD/state/eirini-controller/values.yaml"
  pushd eirini-controller/deployment/helm
  {
    helm template eirini-controller . --namespace eirini-controller --values "$values_yaml" --output-dir="$RENDER_DIR"
  }
  popd
}

zip-eirini-controller-yamls() {
  pushd "$RENDER_DIR"
  {
    tar -zcvf "eirini-controller.tgz" eirini-controller
  }
  popd

  mv "$RENDER_DIR/eirini-controller.tgz" release-output
}

main
