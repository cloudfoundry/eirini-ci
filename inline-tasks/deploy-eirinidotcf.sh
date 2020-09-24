#!/bin/bash

set -euo pipefail

values=eirini-private-config/environments/kube-clusters/acceptance/values.yaml
cf_domain="$(goml get -f "$values" -p "env.DOMAIN")"
cf_admin_password="$(goml get -f "$values" -p "secrets.CLUSTER_ADMIN_PASSWORD")"

cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"
cf target -o eirinidotcf -s eirinidotcf

export MYSQL_ROOT_PASSWORD
export MYSQL_PORT
export MYSQL_IP_ADDRESS

MYSQL_ROOT_PASSWORD="$(<db-conf/mysql-root-password)"
MYSQL_PORT="$(<db-conf/mysql-port)"
MYSQL_IP_ADDRESS="$(<db-conf/mysql-ip-address)"

ups="$(
  cat <<EOF
{
  "db_name": "pheed",
  "username":"root",
  "password":"$MYSQL_ROOT_PASSWORD",
  "db_address": "$MYSQL_IP_ADDRESS:$MYSQL_PORT"
}
EOF
)"

pushd eirinidotcf/api || exit 1
cf push --no-start
if cf service pheed-db; then
  cf uups pheed-db -p "$ups"
else
  cf cups pheed-db -p "$ups"
fi
cf bind-service eirinidotcf-api pheed-db
cf start eirinidotcf-api
popd || exit 1

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

if ! cf domains | grep eirini.cf >/dev/null 2>&1; then
  cf create-domain eirinidotcf eirini.cf
fi
cf map-route eirinidotcf-web eirini.cf
popd || exit 1
