#!/usr/bin/env bash
set -euo pipefail
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

extra_args=()

deploy-cf() {
  if [[ "$USE_CERT_MANAGER" == "true" ]]; then
    extra_args=(
      "-f"
      "ci-resources/cert-manager/custom-app-domain.yml"
    )
  fi

  kapp deploy -a cf -f <(
    ytt \
      -f patched-cf-for-k8s/config \
      -f cf-k8s-prometheus/config \
      -f ci-resources/cf-for-k8s \
      -f cluster-state/environments/kube-clusters/"${1}"/default-values.yml \
      -f cluster-state/environments/kube-clusters/"${1}"/loadbalancer-values.yml \
      "${extra_args[@]}"
  ) -y

  if [[ "$USE_CERT_MANAGER" == "true" ]]; then
    kubectl get secret eirinidotcf-cert --namespace=cert-manager --export -o yaml | kubectl apply --namespace=istio-system -f -
  fi
}

deploy-cf "$CLUSTER_NAME"
