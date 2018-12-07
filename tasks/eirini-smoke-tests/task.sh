#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/scf-config-values.yaml"

main(){
  CF_DOMAIN="$(goml get -f "$CONFIG_FILE" -p "env.DOMAIN")"
  sleep 10

  curl-eirini-endpoints
}

curl-eirini-endpoints(){
  curl "api.$CF_DOMAIN/v2/info" --fail
}

main
