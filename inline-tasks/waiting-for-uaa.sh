#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  local counter=0
  while true; do
    if is-pod-ready uaa uaa-0; then
      echo UAA is ready
      exit 0
    fi
    printf "·"
    counter=$((counter + 1))

    if [[ $counter -gt 600 ]]; then
      echo "UAA is NOT ready" >&2
      exit 1
    fi
    sleep 1
  done
}

main
