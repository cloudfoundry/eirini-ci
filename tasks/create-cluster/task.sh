#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

name=${CLUSTER_NAME:?}
worker_count=${WORKER_COUNT:-1}
create-cluster "$name" "$worker_count"
wait-for-state "$name" normal
cluster-state "$name"
