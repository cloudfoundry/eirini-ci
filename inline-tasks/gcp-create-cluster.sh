#!/bin/bash

set -eu

echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

TERRAFORM_CONFIG_PATH=ci-resources/gke-cluster
if [[ $WINDOWS_POOL == "true" ]]; then
  TERRAFORM_CONFIG_PATH=ci-resources/gke-cluster-windows
fi

terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME" "$TERRAFORM_CONFIG_PATH"
terraform apply -var "name=$CLUSTER_NAME" \
  -var "node-count-per-zone=$WORKER_COUNT" \
  -auto-approve \
  "$TERRAFORM_CONFIG_PATH"
