#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"

main() {
    ibmcloud-login
    export-kubeconfig "$CLUSTER_NAME"
    init-helm
    set-kube-state
    set-external-ips
    copy-output
}

init-helm() {
    helm init
}

set-kube-state() {
    local node_ip
    local ingress_endpoint
    node_ip="$(get-node-ip)"
    ingress_endpoint="$(get-ingress-endpoint)"

    pushd state
        mkdir --parent "$CLUSTER_DIR"
        cat > "$CLUSTER_DIR"/scf-config-values.yaml <<EOF
env:
    DOMAIN: $node_ip.nip.io

    UAA_HOST: uaa.$node_ip.nip.io
    UAA_PORT: 2793
    ENABLE_OPI_STAGING: false

opi:
    use_registry_ingress: true
    ingress_endpoint: $ingress_endpoint
    namespace: opi
    image_tag: $CLUSTER_NAME

kube:
    external_ips: []
    storage_class:
            persistent: "hostpath"
            shared: "hostpath"
    auth: rbac

secrets:
    CLUSTER_ADMIN_PASSWORD: $CLUSTER_ADMIN_PASSWORD
    UAA_ADMIN_CLIENT_SECRET: $UAA_ADMIN_CLIENT_SECRET
    NATS_PASSWORD: $NATS_PASSWORD
    BITS_SERVICE_SECRET: bits
EOF
    popd
}

set-external-ips(){
    pushd state
      node_ips="$(get-node-ips)"
      IFS=" "
      for ip in $node_ips
      do
        goml set -f "$CLUSTER_DIR/scf-config-values.yaml" -p kube.external_ips.+ -v "$ip"
      done
    popd
}

get-node-ip() {
    kubectl get nodes -o jsonpath='{ $.items[0].status.addresses[?(@.type=="ExternalIP")].address}'; echo
}

get-node-ips() {
    kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address}'; echo
}

get-ingress-endpoint() {
   ibmcloud ks cluster-get "$CLUSTER_NAME" --json | jq --raw-output '.ingressHostname'; echo
}

copy-output() {
    pushd state || exit
        if git status --porcelain | grep .; then
            echo "Repo is dirty"
            git add "$CLUSTER_DIR/scf-config-values.yaml"
            git config --global user.email "eirini@cloudfoundry.org"
            git config --global user.name "Come-On Eirini"
            git commit --all --message "update/add scf values file"
        else
            echo "Repo is clean"
        fi
    popd || exit

    cp -r state/. state-modified/
}

main
