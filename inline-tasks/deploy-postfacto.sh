#!/bin/bash
set -euo pipefail

unzip postfacto/package.zip -d postfacto/
cp eirini-private-config/postfacto-deployment/api/config.js postfacto/package/assets/client/
redis_password="$(cat redis-password/password)"
values=eirini-private-config/environments/kube-clusters/acceptance/values.yaml
cf_domain="$(goml get -f "$values" -p "env.DOMAIN")"
cf_admin_password="$(goml get -f "$values" -p "secrets.CLUSTER_ADMIN_PASSWORD")"
cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"
cf target -o postfacto -s postfacto

domain="$(goml get -f "$values" -p "eirini.opi.ingress_endpoint")"

cf rename postfacto-api postfacto-api-old

cf push -f eirini-private-config/postfacto-deployment/api/manifest.yml \
  -p postfacto/package/assets \
  --hostname retro-temp \
  -d "${domain}" \
  --var api-app-name=postfacto-api \
  --var pcf-url="${domain}" \
  --var domain="${domain}" \
  --var namespace=postfacto-redis \
  --var redis-password="${redis_password}" \
  --var mysql-password="((mysql-password))"

curl --fail "https://retro-temp.${domain}"
cf map-route postfacto-api "${domain}" --hostname retro
cf unmap-route postfacto-api-old "${domain}" --hostname retro
cf unmap-route postfacto-api "${domain}" --hostname retro-temp

curl --fail "https://retro.${domain}"
cf delete -f postfacto-api-old
