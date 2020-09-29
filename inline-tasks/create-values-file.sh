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
  echo "$VALUES_TEMPLATE" >"$CLUSTER_DIR/values.yaml"
  goml set --prop env.DOMAIN --value "$node_ip.nip.io" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop ingress.endpoint --value "$ingress_endpoint" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop ingress.use --value "true" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop secrets.BITS_SERVICE_SECRET --value "$BITS_SECRET" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop secrets.BITS_SERVICE_SIGNING_USER_PASSWORD --value "$BITS_SECRET" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop secrets.BLOBSTORE_PASSWORD --value "$BITS_SECRET" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop opi.use_registry_ingress --value "true" --file "$CLUSTER_DIR/values.yaml"
  goml set --prop opi.ingress_endpoint --value "$ingress_endpoint" --file "$CLUSTER_DIR/values.yaml"
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
