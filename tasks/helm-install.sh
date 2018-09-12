#!/bin/bash

set -ex

readonly HELM_DIR=eirini-helm-release/kube-release/helm/eirini

main(){
  place_kube_config
  create_and_set_namespace
  copy_helm_config_files
  helm_install_or_upgrade
}

place_kube_config(){
  mkdir -p ~/.kube
  echo "$KUBE_CONF" > ~/.kube/config
}

create_and_set_namespace(){
  set +e
  if kubectl get namespace "$KUBE_NAMESPACE"; then
    echo "namespace $KUBE_NAMESPACE exits"
  else
    kubectl create namespace "$KUBE_NAMESPACE"
    echo "namespace $KUBE_NAMESPACE created"
  fi
  kubectl config set-context "$(kubectl config current-context)" --namespace="$KUBE_NAMESPACE"
  set -e
}

copy_helm_config_files(){
  cp configs/opi.yaml $HELM_DIR/configs/
}

helm_install_or_upgrade(){
  if helm history "$TAG"; then
    helm upgrade \
      "$TAG" \
      eirini-helm-release/kube-release/helm/eirini \
      --set-string "ingress.opi.host=opi-$DIRECTOR_NAME.$KUBE_ENDPOINT" \
      --set-string "config.opi_image=eirini/opi:$TAG" \
      --set-string "config.registry_image=eirini/registry:$TAG" \
      --set-string "ingress.registry.host=registry-$DIRECTOR_NAME.$KUBE_ENDPOINT"
  else
    helm install \
      eirini-helm-release/kube-release/helm/eirini \
      --namespace "$KUBE_NAMESPACE" \
      --set-string "ingress.opi.host=opi-$DIRECTOR_NAME.$KUBE_ENDPOINT" \
      --set-string "ingress.registry.host=registry-$DIRECTOR_NAME.$KUBE_ENDPOINT" \
      --set-string "config.registry_image=eirini/registry:$TAG" \
      --set-string "config.opi_image=eirini/opi:$TAG" \
      --debug \
      --name "$TAG"
  fi
}

main
