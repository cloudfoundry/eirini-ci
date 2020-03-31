#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"
readonly STORAGE_CLASS=${STORAGE_CLASS:-hostpath}

main() {
  export KUBECONFIG="$PWD/kube/config"
  generate-kubecf-values

  set-external-ips
  copy-output
}

generate-kubecf-values() {
  local node_ip
  local ingress_endpoint
  node_ip="$(get-node-ip)"
  ingress_endpoint="$(<ingress/endpoint)"

  pushd cluster-state
  mkdir --parent "$CLUSTER_DIR"
  cat >"$CLUSTER_DIR"/values.yaml <<EOF
eirini:
  opi:
    ingress_endpoint: $ingress_endpoint
    use_registry_ingress: true
  kube:
    external_ips: []
bits:
  env:
    DOMAIN: $node_ip.nip.io
  ingress:
    endpoint: $ingress_endpoint
    use: true
  kube:
    external_ips: []
  secrets:
    BITS_SERVICE_SECRET: changeme
    BITS_SERVICE_SIGNING_USER_PASSWORD: changeme

system_domain: $node_ip.nip.io
kube:
  storage_class: $STORAGE_CLASS
  service_cluster_ip_range: '172.21.0.0/16'
  pod_cluster_ip_range: '172.30.0.0/16'
services:
  router:
    externalIPs: []
sizing:
  diego_cell:
    instances: 0

features:
  eirini:
    enabled: true
    use_helm_release: true
EOF
  popd
}

set-external-ips() {
  pushd cluster-state
  node_ips="$(get-node-ips)"
  IFS=" "
  for ip in $node_ips; do
    goml set -f "$CLUSTER_DIR/values.yaml" -p eirini.kube.external_ips.+ -v "$ip"
    goml set -f "$CLUSTER_DIR/values.yaml" -p bits.kube.external_ips.+ -v "$ip"
    goml set -f "$CLUSTER_DIR/values.yaml" -p services.router.externalIPs.+ -v "$ip"
  done
  popd
}

get-node-ip() {
  kubectl get nodes --output jsonpath='{ $.items[0].status.addresses[?(@.type=="ExternalIP")].address}'
  echo
}

get-node-ips() {
  kubectl get nodes --output jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
  echo
}

copy-output() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$CLUSTER_DIR/values.yaml"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add kubecf values file"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

main
