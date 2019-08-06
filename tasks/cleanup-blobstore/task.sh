#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

kubectl exec -n scf blobstore-0 -c blobstore -- \
  /bin/sh -c 'rm -rf /var/vcap/store/shared/cc-droplets/sh/a2/sha256:*'
