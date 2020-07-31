#!/bin/bash
set -euo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions
ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

redis_password=$(kubectl get secret postfacto-redis -n postfacto-redis -o json | jq -r '.data | .["redis-password"]' | base64 -d)
echo "$redis_password" >redis-password/password
