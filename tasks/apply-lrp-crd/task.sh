#!/bin/bash

set -euo pipefail

export KUBECONFIG="$PWD"/kube/config
kubectl apply -f eirini-release/helm/eirini/templates/lrp-crd.yaml
