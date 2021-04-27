#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

gcloud-login
export-kubeconfig "$CLUSTER_NAME"

echo "$GCP_SERVICE_ACCOUNT_JSON" >"kube/service-account.json"
