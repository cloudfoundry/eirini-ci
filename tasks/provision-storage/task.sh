#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  wait_for_service_availability
  install_block_storage_prodivder
  install_hostpath_provider
}

wait_for_service_availability() {
  local counter=0
  local services
  while true; do
    services="$(kubectl get apiservice --no-headers=true)"
    if any_unnavailable_services "$services"; then
      echo "----"
      counter=$((counter + 1))
    else
      echo "All services are available"
      return 0
    fi

    if [[ $counter -gt 30 ]]; then
      echo "Unavalable services" >&2
      echo "$services" >&2
      exit 1
    fi
    sleep 1
  done
}

any_unnavailable_services() {
  local services="$1"
  echo "$services" | awk '{print $3}' | grep "False"
}

install_block_storage_prodivder() {
  helm init --client-only
  helm repo add iks-charts https://icr.io/helm/iks-charts
  helm repo update
  helm upgrade --install ibmcloud-block-storage-plugin iks-charts/ibmcloud-block-storage-plugin
}

install_hostpath_provider() {
  local HOSTPATH_PROVIDER_RBAC="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/rbac.yaml"
  local HOSTPATH_PROVIDER_DEPLOYMENT="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/deployment.yaml"
  local HOSTPATH_PROVIDER_STORAGECLASS="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/storageclass.yaml"

  kubectl apply --filename "$HOSTPATH_PROVIDER_RBAC"
  kubectl apply --filename "$HOSTPATH_PROVIDER_DEPLOYMENT"
  kubectl apply --filename "$HOSTPATH_PROVIDER_STORAGECLASS"
}

main
