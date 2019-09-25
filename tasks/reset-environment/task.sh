#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
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
