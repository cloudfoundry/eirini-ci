#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

main() {
  ibmcloud-login
  export-kubeconfig "${CLUSTER_NAME:?Cluster name not provided}"

  local ready
  ready=$(is-labeled-container-ready scf "name=bits")

  if [ "$ready" = "true" ]; then
    echo Bits-Service is ready
    exit 0
  else
    echo Bits-Service is NOT ready
    exit 1
  fi
}

main
