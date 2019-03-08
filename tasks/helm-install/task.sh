#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
readonly VERSION="$(cat deployment-version/version)"
export SECRET=""
export CA_CERT=""
export BITS_TLS_CRT=""
export BITS_TLS_KEY=""

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  export-certs
  helm-dep-update
  helm init --upgrade --wait
  helm-install
}

export-certs() {
  if [ "$COMPONENT" == "scf" ]; then
    SECRET=$(kubectl get pods --namespace uaa --output jsonpath='{.items[*].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
    CA_CERT="$(kubectl get secret "$SECRET" --namespace uaa --output jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"
    BITS_TLS_CRT="$(kubectl get secret "$(kubectl config current-context)" --namespace default -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"
    BITS_TLS_KEY="$(kubectl get secret "$(kubectl config current-context)" --namespace default -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
  fi
}

helm-dep-update() {
  if [ "$COMPONENT" == "scf" ]; then
    pushd "eirini-release/helm/cf"
    helm init --client-only
    helm dependency update
    popd || exit
  fi
}

helm-install() {
  local -r image_tag="${VERSIONING_CLUSTER}-${VERSION}"
  pushd eirini-release/helm
  helm upgrade --install "$COMPONENT" \
    "$HELM_CHART" \
    --namespace "$COMPONENT" \
    --values "../../$ENVIRONMENT"/scf-config-values.yaml \
    --set "secrets.UAA_CA_CERT=${CA_CERT}" \
    --set "opi.version=$VERSION" \
    --set "eirini.opi.image_tag=$image_tag" \
    --set "eirini.secrets.BITS_TLS_CRT=${BITS_TLS_CRT}" \
    --set "eirini.secrets.BITS_TLS_KEY=${BITS_TLS_KEY}" \
    --force
  popd
}

main
