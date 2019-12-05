#!/bin/bash

set -euo pipefail

copy_secret() {
  local cluster_name secret_name
  cluster_name="$1"

  ibmcloud-login
  export-kubeconfig "${cluster_name}"

  secret_name="$(ibmcloud ks cluster-get "${cluster_name}" --json | jq '.ingressSecretName' -r)"
  kubectl get secret "$secret_name" --namespace=default --export -o yaml |
    kubectl apply --namespace="monitoring" -f - >/dev/null 2>&1
  echo "$secret_name" >secret/name
}
