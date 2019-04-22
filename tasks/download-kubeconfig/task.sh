#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

readonly KUBE_RESOURCES=$(dirname "$KUBECONFIG")
cp "$KUBE_RESOURCES/*.pem" kube
cp "$KUBECONFIG" kube/config
