#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"
readonly BITS_SECRET="bits"
readonly STORAGE_CLASS=${STORAGE_CLASS:-hostpath}

main() {
  export KUBECONFIG="$PWD/kube/config"
  set-kube-state
  copy-output
}

set-kube-state() {
  local node_ip
  local ingress_endpoint
  node_ip="$(get-node-ip)"
  ingress_endpoint="$(<ingress/endpoint)"

  pushd cluster-state
  mkdir --parent "$CLUSTER_DIR"
  cat >"$CLUSTER_DIR"/values.yaml <<EOF
env:
  DOMAIN: $node_ip.nip.io
ingress:
  endpoint: $ingress_endpoint
  use: true
secrets:
  BITS_SERVICE_SECRET: $BITS_SECRET
  BITS_SERVICE_SIGNING_USER_PASSWORD: $BITS_SECRET
  BLOBSTORE_PASSWORD: $BITS_SECRET

opi:
  use_registry_ingress: true
  ingress_endpoint: $ingress_endpoint
  tls:
    opiCapiClient:
      secretName: "cf-secrets"
    opiServer:
      secretName: "cf-secrets"
    capi:
      secretName: "cf-secrets"
    eirini:
      secretName: "cf-secrets"
  events:
    tls:
      capiClient:
        secretName: "cf-secrets"
      capi:
        secretName: "cf-secrets"
  logs:
    tls:
      client:
        secretName: "cf-secrets"
      server:
        secretName: "cf-secrets"

  rootfsPatcher:
    enable: false

  metrics:
    tls:
      client:
        secretName: "cf-secrets"
      server:
        secretName: "cf-secrets"
  routing:
    nats:
      serviceName: nats-client
      secretName: "cf-secrets"
  secretSmuggler:
    enable: false
  staging:
    tls:
      client:
        secretName: "cf-secrets"
      cc_uploader:
        secretName: "cf-secrets"
      ca:
        secretName: "cf-secrets"
      stagingReporter:
        secretName: "cf-secrets"
  tasks:
    tls:
      taskReporter:
        secretName: "cf-secrets"
  lrpController:
    tls:
      secretName: "cf-secrets"
EOF
  popd
}

get-node-ip() {
  kubectl get nodes --output jsonpath='{ $.items[0].status.addresses[?(@.type=="ExternalIP")].address}'
  echo
}

copy-output() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$CLUSTER_DIR/values.yaml"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add Eirini/Bits values file"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

main
