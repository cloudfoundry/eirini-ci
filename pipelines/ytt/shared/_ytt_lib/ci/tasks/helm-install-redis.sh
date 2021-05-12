#!/bin/bash

set -eu

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

CHART_STATUS="$(helm status postfacto-redis \
  --namespace postfacto-redis \
  --output json |
  jq -r ".info.status")"

echo "Redis chart status: $CHART_STATUS"

helm repo add bitnami https://charts.bitnami.com/bitnami
if [[ "$CHART_STATUS" == "deployed" ]]; then
  REDIS_PASSWORD=$(kubectl get secret --namespace "postfacto-redis" postfacto-redis -o jsonpath="{.data.redis-password}" | base64 --decode)
  helm upgrade postfacto-redis bitnami/redis \
    --namespace postfacto-redis \
    --set securityContext.fsGroup=65531 \
    --set auth.password="$REDIS_PASSWORD"
else
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm install postfacto-redis bitnami/redis \
    --namespace postfacto-redis \
    --create-namespace \
    --set securityContext.fsGroup=65531
fi
