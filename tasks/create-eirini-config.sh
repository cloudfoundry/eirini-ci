#!/bin/bash

set -euox pipefail
IFS=$'\n\t'

readonly DIRECTOR_DIR="./state/environments/softlayer/director/$DIRECTOR_NAME"
readonly CF_DEPLOYMENT="$DIRECTOR_DIR/cf-deployment/vars.yml"

main(){
  CF_PASSWORD=$(bosh interpolate "$CF_DEPLOYMENT" --path /cf_admin_password)
  NATS_PASSWORD=$(bosh interpolate "$CF_DEPLOYMENT" --path /nats_password)
  DIRECTOR_IP=$(cat "$DIRECTOR_DIR/ip")
  NATS_IP=$DIRECTOR_IP #requires iptables rule at director to forward trafic to nats
  create_config
}

create_config() {
  cp ci-resources/stubs/opi.yaml configs
  goml set -f configs/opi.yaml -p opi.kube_namespace -v "$KUBE_NAMESPACE"
  goml set -f configs/opi.yaml -p opi.kube_endoint -v "$KUBE_ENDPOINT"
  goml set -f configs/opi.yaml -p opi.nats_password -v "$NATS_PASSWORD"
  goml set -f configs/opi.yaml -p opi.nats_ip -v "$NATS_IP"
  goml set -f configs/opi.yaml -p opi.api_endpoint -v "https://api.$DIRECTOR_IP.nip.io"
  goml set -f configs/opi.yaml -p opi.cf_password -v "$CF_PASSWORD"
  goml set -f configs/opi.yaml -p opi.external_eirini_address -v "registry-$DIRECTOR_NAME.$KUBE_NAMESPACE:80"
}

main
