#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/scf-config-values.yaml"

main(){
  INGRESS_ENDPOINT="$(goml get -f "$CONFIG_FILE" -p "opi.ingress_endpoint")"
  CF_DOMAIN="$(goml get -f "$CONFIG_FILE" -p "env.DOMAIN")"
  sleep 10

  curl-eirini-endpoints
}

curl-eirini-endpoints(){
  curl "api.$CF_DOMAIN/v2/info" --fail
  curl "http://registry.$INGRESS_ENDPOINT/v2" --fail
}

main
