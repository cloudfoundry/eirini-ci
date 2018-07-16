#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
BOSH_CLIENT_SECRET=$(bosh interpolate $DIRECTOR_PATH/vars.yml --path /admin_password)
export BOSH_CLIENT_SECRET

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

STEMCELL_VERSION=$(bosh interpolate manifest/manifest.yml --path /releases/name=capi/stemcell/version)
EXISTS=`bosh --environment lite stemcells`

if [[ $EXISTS = *"$STEMCELL_VERSION"* ]]; then
  echo "Stemcell version $STEMCELL_VERSION exists; skipping upload"
  exit 0
else
  echo "Uploading stemcell version $STEMCELL_VERSION"
  bosh --environment lite upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent\?v\=$STEMCELL_VERSION
fi
