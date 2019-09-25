#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
export KUBECONFIG="$PWD/kube/config"

main() {
  helm init --upgrade --wait
  helm-install
}

helm-install() {
  pushd eirini-release/helm
  helm upgrade --install "uaa" \
    "uaa" \
    --namespace "uaa" \
    --values "../../$ENVIRONMENT"/scf-config-values.yaml
  popd
}

main
