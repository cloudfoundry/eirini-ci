#!/bin/bash

set -euo pipefail

export KUBECONFIG="$PWD"/kube/config
kubectl delete -f eirini-release/helm/eirini/templates/lrp-crd.yaml
