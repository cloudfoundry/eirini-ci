#!/bin/bash

set -e

trap "pkill dockerd" EXIT

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

create_buildkit_secret() {
  kubectl delete secret buildkit --ignore-not-found=true
  kubectl create secret docker-registry buildkit \
    --docker-username="$DOCKERHUB_USER" --docker-password="$DOCKERHUB_PASS"
}

generate_values() {
  local eirini_controller_path values_source_path values_dest_path
  eirini_controller_path="$(readlink -f eirini-controller)"
  values_source_path=$(readlink -f "eirini-controller/deployment/helm/values.yaml")
  values_dest_path=$(readlink -f "state-modified/eirini-controller")

  "$eirini_controller_path"/deployment/scripts/build.sh

  mkdir -p "$values_dest_path"
  cp "$values_source_path" "$values_dest_path"
}

create_buildkit_secret
generate_values
