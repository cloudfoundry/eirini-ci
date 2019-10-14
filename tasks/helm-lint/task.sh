#!/bin/bash
set -euo pipefail

helm init --client-only >/dev/null
helm repo add bits https://cloudfoundry-incubator.github.io/bits-service-release/helm
pushd eirini-release/helm/cf
helm dep update
diff_req=$(git diff requirements.lock)
if [ "$diff_req" != "" ]; then
  echo "requirements.lock is not committed"
  exit 1
fi
popd

eirini-release/scripts/helm-lint.sh
