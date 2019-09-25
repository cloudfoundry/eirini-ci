#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  install_block_storage_prodivder
  install_hostpath_provider
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
