#!/bin/bash
set -euo pipefail

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

redis_password=$(kubectl get secret postfacto-redis -n postfacto-redis -o json | jq -r '.data | .["redis-password"]' | base64 -d)
echo "$redis_password" >redis-password/password
