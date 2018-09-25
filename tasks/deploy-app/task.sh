#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

readonly name=${CLUSTER_NAME:?}

# export KUBECONFIG
export-kubeconfig "$name"

# deploy app
readonly basedir="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$basedir/app.yml"

# this assumes we only have a single worker
ibmcloud ks workers "$name" --json | jq --raw-output '.[0].publicIP' > worker-info/public-ip
