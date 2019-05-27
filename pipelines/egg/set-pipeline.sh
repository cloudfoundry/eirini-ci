#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PIPELINE_YML="$PROJECT_ROOT/pipelines/egg/pipeline.yml"

readonly target="${1:-flintstone}"
readonly private_repo="${2:-$PROJECT_ROOT/../eirini-private-config}"

fly -t "$target" \
  set-pipeline \
  --config "$PIPELINE_YML" \
  --pipeline egg \
  --var ibmcloud-account=7e51fbb83371a0cb0fd553fab15aebf4 \
  --var ibmcloud-user=eirini@cloudfoundry.org \
  --var ibmcloud-password="$(pass show eirini/ibm-id)" \
  --var github-private-key="$(pass eirini/github/private-config/ssh-key)"
