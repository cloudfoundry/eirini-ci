#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ci-resources/scripts/gcloud-functions

generate-values() {
  local clusterName
  clusterName="$1"

  gcloud-login

  #todo change region with a variable
  gcloud compute addresses \
      describe $clusterName \
      --region=europe-west1 \
      --format=json | jq -r '.address' > loadbalancer-address

  cat >loadbalancer-values-file/values.yml <<EOF
#@data/values
---
#@overlay/match missing_ok=True
loadBalancerIP: $(cat loadbalancer-address)
EOF
}
