#!/bin/bash

set -euo pipefail
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
readonly DO_NOT_DELETE_CF=${DO_NOT_DELETE_CF:-"false"}

if [[ "$DO_NOT_DELETE_CF" == "true" ]]; then
  echo "DO_NOT_DELETE_CF set to true. Skipping delete"
  exit 0
fi

kapp delete -a cf --yes
