#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

readonly jq_cmd='.subjects |= map(select(.name != "system:serviceaccounts" and .name != "system:authenticated" ))'

kubectl get clusterrolebindings privileged-psp-user -o json |
  jq  "$jq_cmd" |
  kubectl apply -f -

kubectl get clusterrolebindings restricted-psp-user -o json |
    jq  "$jq_cmd" |
    kubectl apply -f -
