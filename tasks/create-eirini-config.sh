#!/bin/bash

set -euox pipefail
IFS=$'\n\t'

readonly DIRECTOR_DIR="./state/environments/softlayer/director/$DIRECTOR_NAME"
readonly CF_DEPLOYMENT="$DIRECTOR_DIR/cf-deployment/vars.yml"

main(){
  CF_PASSWORD=$(bosh int "$CF_DEPLOYMENT" --path /cf_admin_password)
  NATS_PASSWORD=$(bosh int "$CF_DEPLOYMENT" --path /nats_password)
  DIRECTOR_IP=$(cat "$DIRECTOR_DIR/ip")
  NATS_IP=$DIRECTOR_IP #requires iptables rule at director to forward trafic to nats
  create_config
}

# TODO: use goml and modify stub
create_config(){
  cat > configs/opi.yaml << EOF
opi:
  kube_config: "/workspace/jobs/opi/config/kube.conf"
  kube_namespace: "$KUBE_NAMESPACE"
  kube_endpoint: "$KUBE_ENDPOINT"
  nats_password: "$NATS_PASSWORD"
  nats_ip: "$NATS_IP"
  api_endpoint: "https://api.$DIRECTOR_IP.nip.io"
  cf_username: admin
  cf_password: "$CF_PASSWORD"
  external_eirini_address: "eirini-registry.cube-kube.uk-south.containers.mybluemix.net"
  skip_ssl_validation: true
  insecure_skip_verify: true
EOF
}

main
