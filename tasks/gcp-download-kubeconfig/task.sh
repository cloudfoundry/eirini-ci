#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

gcloud-login
export-kubeconfig "$CLUSTER_NAME"

save-service-account-json "kube/service-account.json"
