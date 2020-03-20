#!/bin/bash

set -euo pipefail

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/values.yaml"

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

get-cf-credentials() {
  if helm ls --short | grep kubecf; then
    get-kubecf-credentials
  else
    get-scf-credentials
  fi
}

get-kubecf-credentials() {
  goml get -f "$CONFIG_FILE" -p system_domain >cf-credentials/cf-domain
  kubectl get secret \
    --namespace kubecf kubecf.var-cf-admin-password \
    -o jsonpath='{.data.password}' |
    base64 --decode >cf-credentials/cf-admin-password
}

get-scf-credentials() {
  goml get -f "$CONFIG_FILE" -p env.DOMAIN >cf-credentials/cf-domain
  goml get -f "$CONFIG_FILE" -p secrets.CLUSTER_ADMIN_PASSWORD >cf-credentials/cf-admin-password
}
