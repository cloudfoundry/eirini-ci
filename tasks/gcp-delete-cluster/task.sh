#!/bin/bash

set -euo pipefail

echo "$GCP_SERVICE_ACCOUNT_JSON" >"$PWD/service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

if $IS_CF4K8S_DEPLOYMENT; then
  kapp delete -a cf --yes
fi

terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME" ci-resources/gke-cluster
terraform destroy -var "name=$CLUSTER_NAME" \
  -var "node-count-per-zone=$WORKER_COUNT" \
  -auto-approve \
  ci-resources/gke-cluster
