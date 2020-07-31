#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

ibmcloud ks cluster get -cluster "$CLUSTER_NAME" --json | jq --raw-output '.ingressHostname' >ingress/endpoint
