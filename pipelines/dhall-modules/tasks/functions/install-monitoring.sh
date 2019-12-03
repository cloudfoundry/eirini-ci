#!/bin/bash

set -euo pipefail

readonly NAMESPACE="monitoring"

install_monitoring() {
  local config_dir="$1/cluster-monitoring"
  local admin_password="$2"
  local grafana_url="$3"
  local grafana_host="$4"
  local provider_specific_values="$5"
  local certs_secret_name="$6"

  helm init --client-only

  helm upgrade --install prometheus stable/prometheus \
    --namespace="$NAMESPACE" \
    --values="$config_dir/prometheus-values.yml" \
    --wait

  helm upgrade --install grafana stable/grafana \
    --namespace="$NAMESPACE" \
    --values="$config_dir/grafana-values.yml" \
    --values="$config_dir/$provider_specific_values" \
    --set-file "dashboards.default.cluster-overview.json=$config_dir/cluster-overview.json" \
    --set adminPassword="$admin_password" \
    --set "grafana\.ini.server.root_url=$grafana_url" \
    --set "ingress.hosts={${grafana_host}}" \
    --set "ingress.tls[0].hosts={${grafana_host}}" \
    --set "ingress.tls[0].secretName=${certs_secret_name}" \
    --wait
}

gke_secret() {
  echo "grafana-certs"
}

iks_secret() {
  local cluster_name="$1"
  local secret_name

  secret_name="$(ibmcloud ks cluster-get "$cluster_name" --json | jq '.ingressSecretName' -r)"
  kubectl get secret "$secret_name" --namespace=default --export -o yaml | kubectl apply --namespace="$NAMESPACE" -f - >/dev/null 2>&1
  echo "$secret_name"
}

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
