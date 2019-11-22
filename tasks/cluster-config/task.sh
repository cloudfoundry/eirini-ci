#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"
readonly BITS_SECRET="bits"
readonly ENABLE_STAGING=${ENABLE_OPI_STAGING:-true}
readonly STORAGE_CLASS=${STORAGE_CLASS:-hostpath}

main() {
  export KUBECONFIG="$PWD/kube/config"
  init-helm
  set-kube-state
  set-external-ips
  copy-output
}

init-helm() {
  kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
  helm init --service-account tiller --upgrade
}

set-kube-state() {
  local node_ip
  local ingress_endpoint
  node_ip="$(get-node-ip)"
  ingress_endpoint="$(<ingress/endpoint)"

  pushd cluster-state
  mkdir --parent "$CLUSTER_DIR"
  cat >"$CLUSTER_DIR"/scf-config-values.yaml <<EOF
bits:
  env:
    DOMAIN: $node_ip.nip.io
  kube:
    external_ips: []
  ingress:
    endpoint: $ingress_endpoint
    use: true
  secrets:
    BITS_SERVICE_SECRET: $BITS_SECRET
    BITS_SERVICE_SIGNING_USER_PASSWORD: $BITS_SECRET
    BLOBSTORE_PASSWORD: $BITS_SECRET
  services:
    loadbalanced: false

env:
    DOMAIN: $node_ip.nip.io

    UAA_HOST: uaa.$node_ip.nip.io
    UAA_PORT: 2793
    ENABLE_OPI_STAGING: $ENABLE_STAGING

kube:
    external_ips: []
    storage_class:
      persistent: "$STORAGE_CLASS"
      shared: "$STORAGE_CLASS"
    auth: rbac

secrets:
    CLUSTER_ADMIN_PASSWORD: $CLUSTER_ADMIN_PASSWORD
    UAA_ADMIN_CLIENT_SECRET: $UAA_ADMIN_CLIENT_SECRET
    BLOBSTORE_PASSWORD: $BITS_SECRET

services:
  loadbalanced: false

eirini:
  opi:
    use_registry_ingress: true
    ingress_endpoint: $ingress_endpoint

  secrets:
    BLOBSTORE_PASSWORD: $BITS_SECRET

  kube:
    external_ips: []
EOF
  popd
}

set-external-ips() {
  pushd cluster-state
  node_ips="$(get-node-ips)"
  IFS=" "
  for ip in $node_ips; do
    goml set -f "$CLUSTER_DIR/scf-config-values.yaml" -p kube.external_ips.+ -v "$ip"
    goml set -f "$CLUSTER_DIR/scf-config-values.yaml" -p eirini.kube.external_ips.+ -v "$ip"
    goml set -f "$CLUSTER_DIR/scf-config-values.yaml" -p bits.kube.external_ips.+ -v "$ip"
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
    git add "$CLUSTER_DIR/scf-config-values.yaml"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add scf values file"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

main
