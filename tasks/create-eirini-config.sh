#!/bin/bash


main(){
  CF_PASSWORD=$(bosh int "./state/environments/softlayer/director/$DIRECTOR_NAME/vars.yml" --path /cf_admin_password)
  DIRECTOR_IP=$(cat "./state/environments/softlayer/director/ip")
  create_config
}

create_config(){
  cat eirini-conf << EOF
opi:
  kube_config: "/workspace/jobs/opi/config/kube.conf"
  kube_namespace: "$KUBE_NAMESPACE"
  kube_endpoint: "$KUBE_NAMESPACE"
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