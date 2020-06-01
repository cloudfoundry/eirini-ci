#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

main() {
  helm init --client-only
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
