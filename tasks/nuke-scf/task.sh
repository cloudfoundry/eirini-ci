#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  helm-purge
}

helm-purge() {
  local output
  kubectl delete namespace scf --ignore-not-found
  if ! output="$(helm del scf --purge 2>&1)"; then
    echo "$output" | grep --ignore-case "not found"
  fi
}

main
