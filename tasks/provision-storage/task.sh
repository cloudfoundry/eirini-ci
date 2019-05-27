#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  install_block_storage_prodivder
  install_hostpath_provider
}

install_block_storage_prodivder() {
  helm init --client-only
  helm repo add iks-charts https://icr.io/helm/iks-charts
  helm repo update
  helm install iks-charts/ibmcloud-block-storage-plugin
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
