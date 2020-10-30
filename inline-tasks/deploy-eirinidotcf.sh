#!/bin/bash

set -euo pipefail

values=eirini-private-config/environments/kube-clusters/cf4k8s4a8e/default-values.yml
cf_domain="$(goml get -f "$values" -p "system_domain")"
cf_admin_password="$(goml get -f "$values" -p "cf_admin_password")"

cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"

cf create-org eirinidotcf || true
cf create-space -o eirinidotcf eirinidotcf || true
cf target -o eirinidotcf -s eirinidotcf

pushd eirinidotcf/web || exit 1
cat >src/config.json.sh <<EOF
{
  "api_url": "http://eirinidotcf-api.$cf_domain",
  "title": "Team Eirini"
}
EOF
yarn add -D eslint-plugin-vuetify
yarn install
yarn run build
cf push eirinidotcf-web

if ! cf domains | grep "^eirini.cf" >/dev/null 2>&1; then
  cf create-domain eirinidotcf eirini.cf
fi
cf map-route eirinidotcf-web eirini.cf
popd || exit 1
