#!/bin/bash

set -euo pipefail

readonly NAMESPACE="monitoring"

install_monitoring() {
  local config_dir="$1/cluster-monitoring"
  local admin_password="$2"
  local provider_specific_values="$3"

  local root_url host secret_name
  host="grafana.$(cat ingress/endpoint)"
  root_url="https://$host"
  secret_name="$(cat secret/name)"

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
    --set "grafana\.ini.server.root_url=$root_url" \
    --set "ingress.hosts={$host}" \
    --set "ingress.tls[0].hosts={$host}" \
    --set "ingress.tls[0].secretName=$secret_name" \
    --wait
}

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
