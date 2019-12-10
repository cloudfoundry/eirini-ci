#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export KUBECONFIG="$PWD/kube/config"

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

purge-helm-deployments
ibmcloud-login

name=${CLUSTER_NAME:?}
delete-cluster "$name"
wait-for-deletion "$name"
