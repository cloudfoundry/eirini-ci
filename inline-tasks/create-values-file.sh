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
      secretName: "eirini-certs"
      keyPath: "tls.key"
      certPath: "tls.crt"
    opiServer:
      secretName: "eirini-certs"
      certPath: "tls.crt"
      keyPath: "tls.key"
    capi:
      secretName: "eirini-certs"
      caPath: "ca.crt"
    eirini:
      secretName: "eirini-certs"
      caPath: "ca.crt"

  events:
    tls:
      capiClient:
        secretName: "eirini-certs"
        keyPath: "tls.key"
        certPath: "tls.crt"
      capi:
        secretName: "eirini-certs"
        caPath: "ca.crt"

  logs:
    tls:
      client:
        secretName: "eirini-certs"
        keyPath: "tls.key"
        certPath: "tls.crt"
      server:
        secretName: "eirini-certs"
        caPath: "ca.crt"

  metrics:
    tls:
      client:
        secretName: "eirini-certs"
        keyPath: "tls.key"
        certPath: "tls.crt"
      server:
        secretName: "eirini-certs"
        caPath: "ca.crt"

  routing:
    nats:
      serviceName: nats-client
      secretName: "eirini-certs"

  secretSmuggler:
    enable: false

  staging:
    tls:
      client:
        secretName: "eirini-certs"
        certPath: "tls.crt"
        keyPath: "tls.key"
      cc_uploader:
        secretName: "eirini-certs"
        certPath: "tls.crt"
        keyPath: "tls.key"
      ca:
        secretName: "eirini-certs"
        path: "ca.crt"
      stagingReporter:
        secretName: "eirini-certs"
        certPath: "tls.crt"
        keyPath: "tls.key"
        caPath: "ca.crt"

  tasks:
    tls:
      taskReporter:
        secretName: "eirini-certs"
        keyPath: "tls.key"
        certPath: "tls.crt"
        caPath: "ca.crt"

  lrpController:
    tls:
      secretName: "eirini-certs"
      certPath: "tls.crt"
      keyPath: "tls.key"
      caPath: "ca.crt"

  cc_api:
    serviceName: "cc-wiremock"
    tls_disabled: true
    protocol: http
    port: 80
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
