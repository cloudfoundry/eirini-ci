#!/bin/bash

set -eu

echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"
terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME" ci-resources/gke-cluster
terraform destroy -var "name=$CLUSTER_NAME" \
  -var "node_count_per_zone=$WORKER_COUNT" \
  -auto-approve \
  ci-resources/gke-cluster
