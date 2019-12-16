#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

gcloud-login

if ! cluster-exists "$CLUSTER_NAME"; then
  echo "WARNING: the cluster $CLUSTER_NAME does not exists."
  echo "WARNING: Ignore this if you are creating the cluster for the first time"
  exit 0
fi

export-kubeconfig "$CLUSTER_NAME"

save-service-account-json "$PWD/service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

purge-helm-deployments
