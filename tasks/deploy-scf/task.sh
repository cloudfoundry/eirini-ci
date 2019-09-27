#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="state/environments/kube-clusters/$CLUSTER_NAME"
export SECRET=""
export CA_CERT=""
export BITS_TLS_CRT=""
export BITS_TLS_KEY=""

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  export-certs
  helm-dep-update
  helm init --upgrade --wait
  helm-install
}

export-certs() {
  if [ "$USE_CERT_MANAGER" == "true" ]; then
    BITS_TLS_CRT="$(kubectl get secret router-ingress --namespace cert-manager -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"
    BITS_TLS_KEY="$(kubectl get secret router-ingress --namespace cert-manager -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
    CA_CERT="$(curl -s https://letsencrypt.org/certs/isrgrootx1.pem.txt)"
  else
    BITS_TLS_CRT="$(kubectl get secret "$(kubectl config current-context)" --namespace default -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"
    BITS_TLS_KEY="$(kubectl get secret "$(kubectl config current-context)" --namespace default -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
    SECRET=$(kubectl get pods --namespace uaa --output jsonpath='{.items[*].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
    CA_CERT="$(kubectl get secret "$SECRET" --namespace uaa --output jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"
  fi
}

helm-dep-update() {
  pushd "eirini-release/helm/cf"
  helm init --client-only
  helm repo add bits https://cloudfoundry-incubator.github.io/bits-service-release/helm
  helm dependency update
  popd || exit
}

helm-install() {
  local image_tag override_image_args cert_args

  override_image_args=()
  if [[ -f deployment-version/version ]]; then
    image_tag=$(cat deployment-version/version)
    override_image_args=(
      "--set" "eirini.opi.init_image=eirini/opi-init"
      "--set" "eirini.opi.image=eirini/opi"
      "--set" "eirini.opi.bits_waiter_image=eirini/bits-waiter"
      "--set" "eirini.opi.rootfs_patcher_image=eirini/rootfs-patcher"
      "--set" "eirini.opi.secret_smuggler_image=eirini/secret-smuggler"
      "--set" "eirini.opi.loggregator_fluentd_image=eirini/loggregator-fluentd"
      "--set" "eirini.opi.image_tag=$image_tag"
    )
  fi

  if [ "$USE_CERT_MANAGER" == "true" ]; then
    cert_args=(
      "--set" "ingress.tls.crt=${BITS_TLS_CRT}"
      "--set" "ingress.tls.key=${BITS_TLS_KEY}"
    )
  fi

  helm upgrade --install "scf" \
    "eirini-release/helm/cf" \
    --namespace "scf" \
    --values "$ENVIRONMENT"/scf-config-values.yaml \
    --set "eirini.secrets.BITS_TLS_CRT=${BITS_TLS_CRT}" \
    --set "eirini.secrets.BITS_TLS_KEY=${BITS_TLS_KEY}" \
    --set "secrets.UAA_CA_CERT=${CA_CERT}" \
    "${cert_args[@]}" \
    "${override_image_args[@]}"
}

main
