#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

readonly name=${CLUSTER_NAME:?}
export-kubeconfig "$name"

kubectl delete namespace scf
helm del scf --purge
