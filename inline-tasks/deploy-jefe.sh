#!/bin/bash
set -euo pipefail

values=eirini-private-config/environments/kube-clusters/acceptance/values.yaml
cf_admin_password="$(goml get -f "$values" -p "secrets.CLUSTER_ADMIN_PASSWORD")"
cf_domain="$(goml get -f "$values" -p "env.DOMAIN")"
cf api "api.$cf_domain" --skip-ssl-validation
cf auth admin "$cf_admin_password"
cf target -o jefe -s jefe

set -x
./eirini-private-config/jefe/deploy.sh $PWD/jefe
