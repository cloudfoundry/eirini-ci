#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

export SECRET=""
export CA_CERT=""

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
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
