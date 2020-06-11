#!/bin/bash

set -euo pipefail

export KUBECONFIG="$PWD/kube/config"

deployments="$(kubectl get deployments \
  --namespace cf \
  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{ end }}')"

for dep in $deployments; do
  kubectl rollout status deployment "$dep" \
    --namespace cf \
    --timeout=30s
done
