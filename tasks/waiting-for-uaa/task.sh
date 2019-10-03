#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  local ready
  ready=$(is-pod-ready uaa uaa-0)

  if [ "$ready" = "true" ]; then
    echo UAA is ready
    exit 0
  else
    echo UAA is NOT ready
    exit 1
  fi
}

main
