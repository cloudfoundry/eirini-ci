#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
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
