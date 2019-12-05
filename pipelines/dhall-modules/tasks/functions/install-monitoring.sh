#!/bin/bash

set -euo pipefail

readonly NAMESPACE="monitoring"

install_monitoring() {
  local config_dir="$1/cluster-monitoring"
  local admin_password="$2"
  local provider_specific_values="$3"

  local root_url host secret_name minor_server_version dashboard_config
  host="grafana.$(cat ingress/endpoint)"
  root_url="https://$host"
  secret_name="$(cat secret/name)"

  # Kubernetes < 1.16 will send metrics with old names to prometheus
  # See https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#removed-metrics
  minor_server_version="$(kubectl version --output json | jq -r .serverVersion.minor | sed 's/[^0-9]*//g')"
  dashboard_config="$config_dir/cluster-overview.json"
  if [ "$minor_server_version" -lt "16" ]; then
    dashboard_config="$config_dir/cluster-overview-pre-1.16.json"
  fi

  helm init --client-only

  helm upgrade --install prometheus stable/prometheus \
    --namespace="$NAMESPACE" \
    --values="$config_dir/prometheus-values.yml" \
    --wait

  helm upgrade --install grafana stable/grafana \
    --namespace="$NAMESPACE" \
    --values="$config_dir/grafana-values.yml" \
    --values="$config_dir/$provider_specific_values" \
    --set-file "dashboards.default.cluster-overview.json=$dashboard_config" \
    --set adminPassword="$admin_password" \
    --set "grafana\.ini.server.root_url=$root_url" \
    --set "ingress.hosts={$host}" \
    --set "ingress.tls[0].hosts={$host}" \
    --set "ingress.tls[0].secretName=$secret_name" \
    --wait
}

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
