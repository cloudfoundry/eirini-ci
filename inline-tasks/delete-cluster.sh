#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

name=${CLUSTER_NAME:?}
delete-cluster "$name"
wait-for-deletion "$name"
