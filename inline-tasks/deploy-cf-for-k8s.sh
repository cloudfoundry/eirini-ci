#!/usr/bin/env bash
set -euo pipefail
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

deploy-cf() {
  kapp deploy -a cf -f <(
    ytt -f "patched-cf-for-k8s/config" \
      -f ci-resources/cf-for-k8s \
      -f cluster-state/environments/kube-clusters/"${1}"/default-values.yml \
      -f cluster-state/environments/kube-clusters/"${1}"/loadbalancer-values.yml
  ) -y
}

deploy-cf "$CLUSTER_NAME"
