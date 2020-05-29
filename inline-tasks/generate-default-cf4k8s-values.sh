#!/bin/bash

set -euo pipefail
export KUBECONFIG="$PWD/kube/config"
echo "$GCP_SERVICE_ACCOUNT" >account.json
export GCP_SERVICE_ACCOUNT_JSON="$PWD/account.json"

tar xzvf cf-for-k8s-github-release/source.tar.gz -C .
sha="$(<cf-for-k8s-github-release/commit_sha)"
src_folder="cloudfoundry-cf-for-k8s-${sha:0:7}"
"$src_folder"/hack/generate-values.sh -d "$CLUSTER_NAME".ci-envs.eirini.cf-app.com -g "$PWD/account.json" >default-values-file/values.yml
