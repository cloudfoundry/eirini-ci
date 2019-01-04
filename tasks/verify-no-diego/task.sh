#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
export SECRET=""
export CA_CERT=""

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  verify-no-diego
}

verify-no-diego() {
  local diego_components
  local exit_code

  diego_components="$(kubectl get pods --namespace scf | grep "diego")"
  exit_code="$?"
  if [ "$exit_code" -eq 0 ]; then
    echo "Diego componnets still running: $diego_components"
    exit 1
  fi
}
