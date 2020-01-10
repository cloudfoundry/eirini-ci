#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

export KUBECONFIG=kube/config

main() {
  helm init --client-only
  install-nginx-chart
  install-cert-manager-chart
  create-dns-editor-secret
  create-issuer
}

create-dns-editor-secret() {
  kubectl get secret -n cert-manager dns-account-json || kubectl create secret generic -n cert-manager dns-account-json --from-literal=service-account.json="$DNS_SERVICE_ACCOUNT"
}

create-issuer() {
  kubectl apply -f ci-resources/cert-manager/letsencrypt-dns-issuer.yaml
}

cert-status() {
  local cert_name=${1:?No cert name}
  kubectl get certificate -n cert-manager "$cert_name" -o jsonpath='{.status.conditions[?(@.type == "Ready")].status}'
}

install-nginx-chart() {
  local static_ip
  gcloud-login
  static_ip="$(get-static-ip "$CLUSTER_NAME")"
  helm upgrade nginx-ingress \
    --namespace nginx \
    --install \
    --set rbac.create=true \
    --set controller.service.loadBalancerIP="$static_ip" \
    stable/nginx-ingress \
    --wait
}

install-cert-manager-chart() {
  kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml --validate=false
  kubectl get namespace cert-manager || kubectl create namespace cert-manager
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm upgrade cert-manager \
    --install \
    --namespace cert-manager \
    --version v0.11.0 \
    jetstack/cert-manager \
    --wait
}

main
