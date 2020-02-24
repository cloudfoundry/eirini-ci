#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  ibmcloud_failed_discovery_check_workaround
  wait_for_service_availability
  install_block_storage_prodivder
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

    if [[ $counter -gt 1800 ]]; then
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
  helm init --upgrade --wait
  helm repo add iks-charts https://icr.io/helm/iks-charts
  helm repo update
  helm upgrade --install ibmcloud-block-storage-plugin iks-charts/ibmcloud-block-storage-plugin
}

ibmcloud_failed_discovery_check_workaround() {
  delete_pod "kube-system" "vpn"
  delete_pod "kube-system" "metrics-server"
}

delete_pod() {
  local namespace deployment_name

  namespace="$1"
  deployment_name="$2"
  kubectl -n "$namespace" get pods | grep "$deployment_name" | awk '{ print $1 }' | xargs kubectl -n "$namespace" delete pod
  kubectl -n "$namespace" rollout status deployment "$deployment_name"
}

main
