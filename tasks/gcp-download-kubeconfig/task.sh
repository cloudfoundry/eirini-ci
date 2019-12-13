#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export KUBECONFIG=kube/config

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

gcloud-login kube/service_account.json
export-kubeconfig "$CLUSTER_NAME"
