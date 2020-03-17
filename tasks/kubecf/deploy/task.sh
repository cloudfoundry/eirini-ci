#!/bin/bash

set -xeuo pipefail

readonly ENV_DIR="cluster-state/environments/kube-clusters/$CLUSTER_NAME"

export KUBECONFIG=kube/config

main() {
  helm init --client-only
  helm repo add bits https://cloudfoundry-incubator.github.io/bits-service-release/helm
  helm repo update

  install-operator
  install-kubecf
  create-registry-secret
  copy-secret "kubecf.var-cc-bridge-cc-uploader"
  copy-secret "kubecf.var-eirini-tls-client-cert"

  wait-for-kubecf
}

install-operator() {
  kubectl delete --ignore-not-found=true psp ibm-privileged-psp
  # add privileged psp for cf-operator
  kubectl apply -f ci-resources/k8s-specs/cf-operator.yml

  helm upgrade --install cf-operator "$CF_OPERATOR_CHART_URL" \
    --namespace cf-operator \
    --set "global.operator.watchNamespace=kubecf"

  local operator_pod
  operator_pod="$(kubectl get pods --namespace=cf-operator --selector=name=cf-operator --output name)"
  kubectl wait --namespace=cf-operator --for=condition=Ready "$operator_pod"
}

install-kubecf() {
  local cluster_secret bits_tls_key bits_tls_crt
  cluster_secret=$(kubectl -n default get secrets | grep "$(kubectl config current-context | cut -d / -f 1)" | awk '{print $1}')
  bits_tls_key="$(kubectl get secret "$cluster_secret" --namespace default -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
  bits_tls_crt="$(kubectl get secret "$cluster_secret" --namespace default -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"

  helm upgrade --install kubecf kubecf/helm \
    --namespace kubecf \
    --values "$ENV_DIR/values.yaml" \
    --set "bits.secrets.BITS_TLS_KEY=${bits_tls_key}" \
    --set "bits.secrets.BITS_TLS_CRT=${bits_tls_crt}"
}

create-registry-secret() {
  readonly username=$(kubectl get configmap bits -n kubecf -oyaml | grep -E "signing_users:.*" -A 2 - | awk -F: '/username:/{print $2}' | awk '{$1=$1};1')
  readonly password=$(kubectl get configmap bits -n kubecf -oyaml | grep -E "signing_users:.*" -A 2 - | awk -F: '/password:/{print $2}' | awk '{$1=$1};1')
  readonly ingress_endpoint=$(goml get -f "$ENV_DIR/values.yaml" -p "eirini.opi.ingress_endpoint")

  kubectl create secret docker-registry registry-secret-name \
    --docker-server="https://registry.${ingress_endpoint}:443" \
    --docker-username="$username" \
    --docker-password="$password" \
    -n eirini --dry-run -o yaml |
    kubectl apply -f -
}

wait-secret() {
  local counter secrets secret_name
  counter=0
  secret_name=$1

  while true; do
    if secrets=$(kubectl get secrets --namespace kubecf); then
      if echo "$secrets" | grep "$secret_name"; then
        return
      else
        echo "Secret $secret_name not found"
        counter=$((counter + 1))
      fi
    fi

    if [[ $counter -gt 120 ]]; then
      echo "Secret $secret_name not found. Timing out." >&2
      exit 1
    fi
    sleep 1
  done
}

copy-secret() {
  wait-secret "$1"
  kubectl get secret --namespace kubecf "$1" --export -o yaml | kubectl apply -n eirini -f -
}

wait-for-kubecf() {
  kubectl wait \
    --namespace=kubecf \
    --for=condition=Ready \
    --all \
    --timeout=2400s \
    pod
}

main
