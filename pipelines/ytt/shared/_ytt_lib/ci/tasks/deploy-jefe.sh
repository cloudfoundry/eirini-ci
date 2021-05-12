#!/bin/bash
set -euo pipefail

values=eirini-private-config/environments/kube-clusters/cf4k8s4a8e/default-values.yml
cf_domain="$(goml get -f "$values" -p "system_domain")"
cf_admin_password="$(goml get -f "$values" -p "cf_admin_password")"

cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"

cf create-org jefe || true
cf create-space -o jefe jefe || true
cf target -o jefe -s jefe
cf enable-feature-flag diego_docker

cf push jefe --no-start -o eirini/jefe
cf share-private-domain jefe eirini.cf
cf map-route jefe eirini.cf --hostname jefe
cf set-env jefe JEFE_DSN "$JEFE_DSN"
cf set-env jefe JEFE_GITHUB_CLIENT_ID "$JEFE_GITHUB_CLIENT_ID"
cf set-env jefe JEFE_GITHUB_SECRET "$JEFE_GITHUB_SECRET"
cf set-env jefe JEFE_GITHUB_O_AUTH_ORG "$JEFE_O_AUTH_ORG"
cf set-env jefe JEFE_ADMIN_PASSWORD "$JEFE_ADMIN_PASSWORD"
cf start jefe
