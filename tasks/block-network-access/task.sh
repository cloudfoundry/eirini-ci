#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login

readonly CALICOCNF="$(ibmcloud ks cluster-config jax-conf --network -s | grep calicoctl)"


calicoctl apply --config $CALICOCNF -f - <<EOF
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: deny-scf-access
  namespace: eirini
spec:
  types:
  - Egress
  egress:
  - action: Deny
    destination:
      namespaceSelector: name == 'scf'
  - action: Allow
EOF
