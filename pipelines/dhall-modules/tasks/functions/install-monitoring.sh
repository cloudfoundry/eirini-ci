#!/bin/bash

set -euo pipefail

readonly NAMESPACE="monitoring"

install_monitoring() {
  local config_dir="$1/cluster-monitoring"
  local admin_password="$2"
  local grafana_url="$3"
  local storage_class="$4"

  helm init --client-only

  helm upgrade --install prometheus stable/prometheus \
    --namespace="$NAMESPACE" \
    --values="$config_dir/prometheus-values.yml" \
    --wait

  helm upgrade --install grafana stable/grafana \
    --namespace="$NAMESPACE" \
    --values="$config_dir/grafana-values.yml" \
    --set adminPassword="$admin_password" \
    --set "grafana\.ini.server.root_url=$grafana_url" \
    --set "persistence.storageClassName=$storage_class" \
    --wait
}

expose_monitoring_gke() {
  local config_dir="$1/cluster-monitoring"
  local cluster_domain="$2"

  sed "s/<CLUSTER_DOMAIN>/${cluster_domain}/g" "$config_dir/gcp-grafana-ingress.yaml" | kubectl apply --namespace="$NAMESPACE" -f -
}

expose_monitoring_iks() {
  local config_dir="$1/cluster-monitoring"
  local cluster_domain="$2"

  kubectl get secret acceptance --namespace=default --export -o yaml | kubectl apply --namespace="$NAMESPACE" -f -
  sed "s/<CLUSTER_DOMAIN>/${cluster_domain}/g" "$config_dir/iks-grafana-ingress.yaml" | kubectl apply --namespace="$NAMESPACE" -f -
}

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
