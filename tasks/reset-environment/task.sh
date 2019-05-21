#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  nuke-release scf
  nuke-release uaa
}

nuke-release() {
  local release_name="$1"
  if helm status "$release_name"; then
    helm del --purge "$release_name"
    kubectl delete namespace "$release_name"
  fi
}

main
