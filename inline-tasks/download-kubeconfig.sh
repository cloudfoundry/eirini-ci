#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"
store-kubeconfig "kube/config"

export KUBECONFIG="kube/config"
context_name=$(kubectl config get-contexts -o name | head -1)
kubectl config use-context "$context_name"
