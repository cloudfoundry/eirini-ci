#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

gcloud-login

terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME" ci-resources/gke-cluster
terraform destroy -var "name=$CLUSTER_NAME" \
  -var "node-count-per-zone=$WORKER_COUNT" \
  -auto-approve \
  ci-resources/gke-cluster
