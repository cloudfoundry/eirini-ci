#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $DIRECTOR_PATH/vars.yml --path /admin_password`

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

pushd ./eirini-release

bosh sync-blobs

bosh add-blob /eirini/eirinifs.tar eirinifs/eirinifs.tar

git submodule update --init --recursive

bosh -e lite -d cf deploy -n ../manifest/manifest.yml

echo "::::::::::::::CLEAN-UP"
bosh -e lite clean-up --non-interactive --all
popd
