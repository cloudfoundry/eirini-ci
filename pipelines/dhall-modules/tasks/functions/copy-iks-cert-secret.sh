#!/bin/bash

set -euo pipefail

copy_secret() {
  local cluster_name secret_name
  cluster_name="$1"

  ibmcloud-login
  export-kubeconfig "${cluster_name}"

  secret_name="$(ibmcloud ks cluster get --cluster "${cluster_name}" --json | jq '.ingressSecretName' -r)"
  kubectl get namespace monitoring || kubectl create namespace monitoring
  kubectl get secret "$secret_name" --namespace=default --export -o yaml |
    kubectl apply --namespace="monitoring" -f -
  echo "$secret_name" >secret/name
}
