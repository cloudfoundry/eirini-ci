#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="cluster-state/environments/kube-clusters/$CLUSTER_NAME"
export SECRET=""
export CA_CERT=""
export BITS_TLS_CRT=""
export BITS_TLS_KEY=""

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"
  export-certs
  helm init --upgrade --wait
  helm repo add bits https://cloudfoundry-incubator.github.io/bits-service-release/helm
  helm-install
}

export-certs() {
  secret_name="$(kubectl get secrets -o name | grep "$CLUSTER_NAME")"
  BITS_TLS_CRT="$(kubectl get "$secret_name" --namespace default -o jsonpath="{.data['tls\.crt']}" | base64 --decode -)"
  BITS_TLS_KEY="$(kubectl get "$secret_name" --namespace default -o jsonpath="{.data['tls\.key']}" | base64 --decode -)"
}

helm-install() {
  local image_tag override_image_args cert_args

  override_image_args=()
  if [[ -f deployment-version/version ]]; then
    image_tag=$(cat deployment-version/version)
    override_image_args=(
      "--set" "opi.image=eirini/opi"
      "--set" "opi.bits_waiter_image=eirini/bits-waiter"
      "--set" "opi.rootfs_patcher_image=eirini/rootfs-patcher"
      "--set" "opi.secret_smuggler_image=eirini/secret-smuggler"
      "--set" "opi.loggregator_fluentd_image=eirini/loggregator-fluentd"
      "--set" "opi.route_collector_image=eirini/route-collector"
      "--set" "opi.route_pod_informer_image=eirini/route-pod-informer"
      "--set" "opi.route_statefulset_informer_image=eirini/route-statefulset-informer"
      "--set" "opi.metrics_collector_image=eirini/metrics-collector"
      "--set" "opi.image_tag=$image_tag"
    )
  fi

  cert_args=(
    "--set" "bits.secrets.BITS_TLS_CRT=${BITS_TLS_CRT}"
    "--set" "bits.secrets.BITS_TLS_KEY=${BITS_TLS_KEY}"
    "--set" "eirini.secrets.BITS_TLS_CRT=${BITS_TLS_CRT}"
    "--set" "eirini.secrets.BITS_TLS_KEY=${BITS_TLS_KEY}"
  )

  helm install "eirini-release/helm/eirini" \
    --namespace "cf" \
    --values "$ENVIRONMENT"/values.yaml \
    "${cert_args[@]}" \
    "${override_image_args[@]}"

  helm install "eirini-release/helm/bits" \
    --namespace "cf" \
    --values "$ENVIRONMENT"/values.yaml \
    "${cert_args[@]}" \
    "${override_image_args[@]}"
}

main
