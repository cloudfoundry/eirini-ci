#!/bin/bash

set -ex

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
BOSH_CLIENT_SECRET=$(bosh interpolate $DIRECTOR_PATH/vars.yml --path /admin_password)
export BOSH_CLIENT_SECRET

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

echo Prepare CAPI release
pushd capi
  git submodule update --init --recursive
  bosh sync-blobs
popd

if [ "$USE_EIRINI_RELEASE" = true ]; then
  echo Prepare Eirini release
  pushd eirini-release
    ./scripts/buildfs.sh
    bosh sync-blobs
    bosh add-blob /eirini/eirinifs.tar eirinifs/eirinifs.tar
    git submodule update --init --recursive
  popd
fi

echo Deploy CF
bosh --environment lite --deployment cf deploy manifest/manifest.yml \
        --non-interactive \
        --var capi_local_path="$(pwd)/capi" \
        --vars-store "$DIRECTOR_PATH/cf-deployment/vars.yml"

echo Clean up
bosh --environment lite clean-up --non-interactive --all
