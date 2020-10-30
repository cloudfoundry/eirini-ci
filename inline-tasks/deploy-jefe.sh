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

set -x
./eirini-private-config/jefe/deploy.sh "$PWD/jefe"
