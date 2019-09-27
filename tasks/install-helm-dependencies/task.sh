#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

main() {
  init-helm
  install-nginx-chart
  install-cert-manager-chart
  create-dns-editor-secret
  create-issuer
  create-uaa-certificate
  create-router-certificate
}

create-dns-editor-secret() {
  kubectl get secret -n cert-manager dns-account-json || kubectl create secret generic -n cert-manager dns-account-json --from-literal=service-account.json="$DNS_SERVICE_ACCOUNT"
}

create-issuer() {
  kubectl apply -f eirini-release/cert-manager/dns-issues.yaml
}

create-uaa-certificate() {
  kubectl apply -f <(sed "s/<dnsName>/${CLUSTER_NAME}.ci-envs.eirini.cf-app.com/" eirini-release/cert-manager/cert.yml)
}

create-router-certificate() {
  kubectl apply -f <(sed "s/<dnsName>/${CLUSTER_NAME}.ci-envs.eirini.cf-app.com/" eirini-release/cert-manager/router-cert.yml)
}

init-helm() {
  kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
  helm init --service-account tiller --upgrade
}

install-nginx-chart() {
  local static_ip
  gcloud_auth
  static_ip="$(get_static_ip)"
  helm upgrade nginx-ingress \
    --namespace nginx \
    --install \
    --set rbac.create=true \
    --set controller.service.loadBalancerIP="$static_ip" \
    stable/nginx-ingress
}

install-cert-manager-chart() {
  kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
  kubectl get namespace cert-manager || kubectl create namespace cert-manager
  kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true --overwrite
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm upgrade cert-manager \
    --install \
    --namespace cert-manager \
    --version v0.10.0 \
    jetstack/cert-manager
}

gcloud_auth() {
  echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
  gcloud auth activate-service-account --key-file="service-account.json" >/dev/null 2>&1
}

get_static_ip() {
  gcloud compute addresses describe "$CLUSTER_NAME-address" --region=europe-west1 --format json | jq --raw-output ".address"
}

main
