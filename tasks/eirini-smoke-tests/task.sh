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
  local counter=0
  while true; do
    if kubectl get pods --namespace scf | grep -E "api-*|eirini-*|^router-*|bits-*" | grep -E "[01]/2|0/1"; then
      echo "----"
      counter=$((counter + 1))
    else
      echo "SCF is ready"
      exit 0
    fi

    if [[ $counter -gt 1080 ]]; then
      echo "SCF is NOT ready" >&2
      exit 1
    fi
    sleep 1
  done
}

main
