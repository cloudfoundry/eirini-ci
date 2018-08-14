#!/bin/bash

bosh interpolate cf-deployment/cf-deployment.yml \
    --vars-store "$DIRECTOR_PATH/cf-deployment/vars.yml" \
    --ops-file cf-deployment/operations/experimental/enable-bpm.yml \
    --ops-file cf-deployment/operations/use-compiled-releases.yml \
    --ops-file cf-deployment/operations/bosh-lite.yml \
    --ops-file eirini-release/operations/capi-dev-version.yml \
    --ops-file eirini-release/operations/enable-opi.yml \
    --ops-file eirini-release/operations/disable-router-tls.yml \
    --ops-file 1-click/operations/add-system-domain-dns-alias.yml \
    --var system_domain="$DIRECTOR_IP.nip.io" \
    --var opi_cf_url="http://opi-$DIRECTOR_NAME.$KUBE_ENDPOINT:80" \
  > manifest/manifest.yml
