#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  helm init --upgrade --wait
  helm-install
}

helm-install() {
  pushd eirini-release/helm
  helm upgrade --install "uaa" \
    "uaa" \
    --namespace "uaa" \
    --values "../../$ENVIRONMENT"/scf-config-values.yaml \
    --force
  popd
}

main
