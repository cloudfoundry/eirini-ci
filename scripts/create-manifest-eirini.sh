#!/bin/bash

bosh interpolate ./cf-deployment/cf-deployment.yml \
     --vars-store "./$DIRECTOR_PATH/cf-deployment/vars.yml" \
     --ops-file ./cf-deployment/operations/experimental/enable-bpm.yml \
     --ops-file ./cf-deployment/operations/use-compiled-releases.yml \
     --ops-file ./cf-deployment/operations/bosh-lite.yml \
     --ops-file ./cf-deployment/operations/experimental/use-bosh-dns.yml \
     --ops-file ./eirini-release/operations/capi-dev-version.yml \
     --ops-file ./eirini-release/operations/eirini-bosh-operations.yml \
     --ops-file ./eirini-release/operations/dev-version.yml \
     --ops-file ./cf-deployment/iaas-support/softlayer/add-system-domain-dns-alias.yml \
     --var=k8s_flatten_cluster_config="$(kubectl config view --flatten=true)" \
     --var system_domain="$DIRECTOR_IP.nip.io" \
     --var cc_api="https://api.$DIRECTOR_IP.nip.io" \
     --var kube_namespace="$KUBE_NAMESPACE" \
     --var kube_endpoint="$KUBE_ENDPOINT" \
     --var nats_ip="$NATS_IP" \
     --var registry_address="registry.$DIRECTOR_IP.nip.io:8089" \
     --var eirini_ip="$EIRINI_IP" \
     --var eirini_address="http://eirini.$DIRECTOR_IP.nip.io:8090" \
     --var eirini_local_path=./eirini-release > ./manifest/manifest.yml
