#!/bin/bash

set -euo pipefail

install_monitoring() {
    local config_dir="$1/postfacto-deployment/monitoring"
    local admin_password="$2"
    local grafana_url="$3"
    local storage_class="$4"

    helm init --client-only

    helm upgrade --install prometheus stable/prometheus \
         --namespace monitoring \
         --values="$config_dir/prometheus-values.yaml" \
         --wait

    helm upgrade --install grafana stable/grafana \
         --namespace monitoring \
         --values="$config_dir/grafana-values.yaml" \
         --set adminPassword="$admin_password" \
         --set "grafana\.ini.server.root_url=$grafana_url" \
         --set "persistence.storageClassName=$storage_class" \
         --wait
}

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
