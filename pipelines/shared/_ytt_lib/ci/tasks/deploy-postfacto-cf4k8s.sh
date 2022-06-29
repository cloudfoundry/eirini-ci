#!/bin/bash
set -euo pipefail

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

redis_password="$(cat redis-password/password)"
values=eirini-private-config/environments/kube-clusters/cf4k8s4a8e/default-values.yml
cf_domain="$(goml get -f "$values" -p "system_domain")"
cf_admin_password="$(goml get -f "$values" -p "cf_admin_password")"

unzip postfacto/package.zip -d postfacto/
cp eirini-private-config/postfacto-deployment/api/config.js postfacto/package/assets/client/

sed -i "34i gem 'mini_racer'" postfacto/package/assets/Gemfile
sed -i "329i \ \ x86_64-linux" postfacto/package/assets/Gemfile.lock
sed -i "s/ruby '2.7.3'/ruby '2.7.5'/" postfacto/package/assets/Gemfile

cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"
cf create-org postfacto
cf create-space -o postfacto postfacto
cf target -o postfacto -s postfacto

cf push -f eirini-private-config/postfacto-deployment/api/manifest-cf4k8s4a8e.yml \
  -p postfacto/package/assets \
  --var api-app-name=postfacto-api \
  --var pcf-url="${cf_domain}" \
  --var domain="${cf_domain}" \
  --var namespace=postfacto-redis \
  --var redis-password="${redis_password}" \
  --var mysql-address="$MYSQL_ADDRESS" \
  --var mysql-password="$MYSQL_PASSWORD" \
  --no-start

if ! cf domains | grep "^eirini.cf" >/dev/null 2>&1; then
  cf create-domain postfacto eirini.cf
fi
cf map-route postfacto-api eirini.cf --hostname retro
cf start postfacto-api
