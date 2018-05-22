#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $DIRECTOR_PATH/vars.yml --path /admin_password`

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

STEMCELL_VERSION=$(bosh int manifest/manifest.yml --path /releases/name=capi/stemcell/version)

echo "::::::::::::::UPLOAD-STEMCELL-VERSION: $STEMCELL_VERSION"
bosh -e lite upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent\?v\=$STEMCELL_VERSION
