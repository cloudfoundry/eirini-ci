#!/bin/bash

set -eu

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace postfacto-redis || true
helm upgrade postfacto-redis \
  --install bitnami/redis \
  --namespace postfacto-redis \
  --set securityContext.fsGroup=65531
