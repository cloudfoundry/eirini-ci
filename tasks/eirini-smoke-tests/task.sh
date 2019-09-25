#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/scf-config-values.yaml"
main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  CF_DOMAIN="$(goml get -f "$CONFIG_FILE" -p "env.DOMAIN")"
  sleep 10

  check-scf-readiness
  curl "api.$CF_DOMAIN/v2/info" --fail
}

check-scf-readiness() {
  local exit_code
  set +e
  kubectl get pods --namespace scf | grep -E "api-*|eirini-*|^router-*|bits-*" | grep -E "[01]/2|0/1"
  exit_code="$?"
  set -e

  [ "$exit_code" -eq 1 ] || exit 1
}

main
