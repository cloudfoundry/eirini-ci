#!/bin/bash

set -euo pipefail
export KUBECONFIG="$PWD/kube/config"
echo "$GCP_SERVICE_ACCOUNT" >account.json
export GCP_SERVICE_ACCOUNT_JSON="$PWD/account.json"

src_folder="cf-for-k8s-prs"
"$src_folder"/hack/generate-values.sh -d "$CLUSTER_NAME".ci-envs.eirini.cf-app.com -g "$PWD/account.json" >default-values-file/values.yml
