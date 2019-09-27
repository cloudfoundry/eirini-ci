#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

main() {
  helm init --upgrade --wait
  helm-install
}

helm-install() {
  local cert_args
  if [ "$USE_CERT_MANAGER" == "true" ]; then
    UAA_TLS_CRT="$(kubectl get secret uaa-ingress --namespace cert-manager -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"
    UAA_TLS_KEY="$(kubectl get secret uaa-ingress --namespace cert-manager -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
    cert_args=(
      "--set" "ingress.tls.crt=${UAA_TLS_CRT}"
      "--set" "ingress.tls.key=${UAA_TLS_KEY}"
    )
  fi
  pushd eirini-release/helm
  helm upgrade --install "uaa" \
    "uaa" \
    --namespace "uaa" \
    "${cert_args[@]}" \
    --values "../../$ENVIRONMENT"/scf-config-values.yaml

  popd
}

main
