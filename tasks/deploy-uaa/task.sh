#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
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
    --values "../../$ENVIRONMENT"/values.yaml

  popd
}

main
