#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="cluster-state/environments/kube-clusters/$CLUSTER_NAME"

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  helm init --upgrade --wait
  helm repo add bitnami https://charts.bitnami.com/bitnami

  helm-install
  install-nats
  create-test-secret
}

install-nats() {
  helm upgrade nats \
    --install bitnami/nats \
    --namespace cf \
    --set auth.user="nats" \
    --set auth.password="$NATS_PASSWORD"
}

create-test-secret() {
  local nats_password_b64
  nats_password_b64="$(echo -n $NATS_PASSWORD | base64)"
  goml set -f "$ENVIRONMENT/eirini-secret.yml" -p data.nats-password -v "$nats_password_b64"
  kubectl apply -n cf -f $ENVIRONMENT/eirini-secret.yml
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

  helm upgrade --install eirini \
    eirini-release/helm/eirini \
    --namespace cf \
    --values "$ENVIRONMENT"/values.yaml \
    "${cert_args[@]}" \
    "${override_image_args[@]}"
}

main
