#!/bin/bash

set -euo pipefail

export KUBECONFIG="$PWD/kube/config"

readonly jq_cmd='.subjects |= map(select(.name != "system:serviceaccounts" and .name != "system:authenticated" ))'

kubectl get clusterrolebindings privileged-psp-user -o json |
  jq "$jq_cmd" |
  kubectl apply -f -

kubectl get clusterrolebindings restricted-psp-user -o json |
  jq "$jq_cmd" |
  kubectl apply -f -
