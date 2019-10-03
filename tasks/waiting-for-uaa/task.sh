#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  if is-pod-ready uaa uaa-0; then
    echo UAA is ready
    exit 0
  else
    echo UAA is NOT ready
    exit 1
  fi
}

main
