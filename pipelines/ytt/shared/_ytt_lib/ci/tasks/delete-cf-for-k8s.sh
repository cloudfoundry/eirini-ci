#!/bin/bash

set -euo pipefail
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

kapp delete -a cf --yes
