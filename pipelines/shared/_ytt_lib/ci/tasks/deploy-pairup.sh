#!/bin/bash

set -euo pipefail

values=eirini-private-config/environments/kube-clusters/cf4k8s4a8e/default-values.yml
cf_domain="$(goml get -f "$values" -p "system_domain")"
cf_admin_password="$(goml get -f "$values" -p "cf_admin_password")"

cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"

cf create-org pairup || true
cf create-space -o pairup pairup || true
cf target -o pairup -s pairup

pushd pairup || exit 1
echo "$FIREBASE_CONF" >src/conf.js

yarn install
yarn build

cf push pairup --no-start
cf share-private-domain pairup eirini.cf
cf map-route pairup eirini.cf --hostname pairup
cf start pairup

popd || exit 1
