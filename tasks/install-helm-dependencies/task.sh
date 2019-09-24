#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

main() {
  init-helm
  install-nginx-chart
  install-cert-manager-chart
}

init-helm() {
  kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
  helm init --service-account tiller --upgrade
}

install-nginx-chart(){
  helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set "controller.extraArgs=--enable-ssl-passthrough"
}

install-cert-manager-chart(){
  kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
  kubectl create namespace cert-manager
  kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.10.0 \
  jetstack/cert-manager
}

main
