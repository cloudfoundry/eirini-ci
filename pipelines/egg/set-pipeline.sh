#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PIPELINE_YML="$PROJECT_ROOT/pipelines/egg/pipeline.yml"

readonly target="${1:-eirini}"

fly -t "$target" \
  set-pipeline \
  --config "$PIPELINE_YML" \
  --pipeline egg \
  --var ibmcloud-account=7e51fbb83371a0cb0fd553fab15aebf4 \
  --var ibmcloud-user=eirini@cloudfoundry.org \
  --var ibmcloud-password="$(pass show eirini/ibm-id)" \
  --var mysql-password="$(pass show eirini/mysql-admin-password)" \
  --var github-private-key="$(pass eirini/github/private-config/ssh-key)" \
  --var jefe-client-id="$(pass eirini/jefe/client-id)" \
  --var jefe-client-secret="$(pass eirini/jefe/client-secret)" \
  --var jefe-dbuser-pass="$(pass eirini/jefe/dbuser-pass)"
