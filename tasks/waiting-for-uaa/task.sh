#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"

  local ready
  ready=$(get-readiness-status)
  if [ "$ready" = "false" ]; then
    echo "Expected uaa to be ready, but it is not!"
    exit 1
  fi
}

get-readiness-status() {
  kubectl get pods uaa-0 -n uaa -o jsonpath='{.status.containerStatuses[0].ready}'
  echo
}

main
