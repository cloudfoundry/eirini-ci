#!/bin/bash

set -eu

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

purge-helm-deployments

echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"
terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME" ci-resources/gke-cluster
terraform destroy -var "name=$CLUSTER_NAME" \
  -var "node-count-per-zone=$WORKER_COUNT" \
  -auto-approve \
  ci-resources/gke-cluster
