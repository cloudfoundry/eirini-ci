#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
readonly VERSION="$(cat deployment-version/version)"
export SECRET=""
export CA_CERT=""

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  export-ca-cert
  helm-install
}

export-ca-cert() {
  if [ "$COMPONENT" == "scf" ]; then
    SECRET=$(kubectl get pods --namespace uaa --output jsonpath='{.items[*].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
    CA_CERT="$(kubectl get secret "$SECRET" --namespace uaa --output jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"
  fi
}

helm-install() {
  local -r image_tag="${VERSIONING_CLUSTER}-${VERSION}"
  pushd eirini-release/scf
  helm upgrade --install "$COMPONENT" \
    helm/"$HELM_CHART" \
    --namespace "$COMPONENT" \
    --values "../../$ENVIRONMENT"/scf-config-values.yaml \
    --set "secrets.UAA_CA_CERT=${CA_CERT}" \
    --set "opi.version=$VERSION" \
    --set "opi.image_tag=$image_tag" \
    --force
  popd
}

main
