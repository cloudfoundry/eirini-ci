#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
readonly RENDER_DIR=$(mktemp -d)

# shellcheck disable=SC2064
trap "rm -r $RENDER_DIR" EXIT

main() {
  generate-eirini-yamls
  zip-eirini-yamls
}

generate-eirini-yamls() {
  eirini-release/scripts/render-templates.sh cf-system "$RENDER_DIR/eirini"
}

zip-eirini-yamls() {
  pushd "$RENDER_DIR"
  tar -zcvf "eirini.tgz" eirini
  popd

  mv "$RENDER_DIR/*.tgz" release-output
}

main
