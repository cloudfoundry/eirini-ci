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
  check_api_connection "$CF_DOMAIN"
}

check-scf-readiness() {
  local counter=0
  local pods
  while true; do
    if pods=$(kubectl get pods --namespace scf); then
      if echo "$pods" | grep -E "api-*|eirini-*|^router-*|bits-*" | grep -E "[01]/2|0/1"; then
        echo "----"
        counter=$((counter + 1))
      else
        echo "SCF is ready"
        return
      fi
    fi

    if [[ $counter -gt 1080 ]]; then
      echo "SCF is NOT ready" >&2
      exit 1
    fi
    sleep 1
  done
}

check_api_connection() {
  local counter=0
  while ! curl -k "https://api.$1/v2/info" --fail; do
    echo "Unable to connect to cf api"
    if [[ $counter -gt 300 ]]; then
      echo "SCF is NOT ready" >&2
      exit 1
    fi
    sleep 1
  done
}

main
