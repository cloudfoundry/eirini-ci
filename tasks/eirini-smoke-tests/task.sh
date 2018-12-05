#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/scf-config-values.yaml"
# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

main(){
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  CF_DOMAIN="$(goml get -f "$CONFIG_FILE" -p "env.DOMAIN")"
  sleep 10

  check-scf-readiness
  curl "api.$CF_DOMAIN/v2/info" --fail
}

check-scf-readiness() {
  local exit_code
  set +e
  kubectl get pods -n scf | grep -E "api-*|eirini-*|^router-*|bits-*" | grep "0/1"
  exit_code="$?"
  set -e

  [ "$exit_code" -eq 1 ] || exit 1
}

main
