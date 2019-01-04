#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly HOSTPATH_PROVIDER_RBAC="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/rbac.yaml"
readonly HOSTPATH_PROVIDER_DEPLOYMENT="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/deployment.yaml"
readonly HOSTPATH_PROVIDER_STORAGECLASS="https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/storageclass.yaml"

ibmcloud-login

export-kubeconfig "$CLUSTER_NAME"

kubectl apply --filename "$HOSTPATH_PROVIDER_RBAC"
kubectl apply --filename "$HOSTPATH_PROVIDER_DEPLOYMENT"
kubectl apply --filename "$HOSTPATH_PROVIDER_STORAGECLASS"
