#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
readonly VERSION_FILE="deployment-version/version"
readonly VERSION=$(cat "$VERSION_FILE")

main() {
  change-image-tags
  zip-templates
}

change-image-tags() {
  sed -i "s/{{ .Values.opi.image_tag }}/${VERSION}/g" eirini-release/scf/helm/cf/templates/eirini.yaml
}

zip-templates() {
  pushd eirini-release/scf/helm
  tar -zcvf "eirini-scf-release-v${VERSION}.tgz" cf uaa
  popd
  mv "eirini-release/scf/helm/eirini-scf-release-v${VERSION}.tgz" release-output
}

main
