#!/bin/bash

set -e

DIRECTOR_PATH="state/environments/softlayer/director/$DIRECTOR_NAME"
BOSH_CLIENT_SECRET=$(bosh int "$DIRECTOR_PATH/vars.yml" --path /admin_password)
DIRECTOR_IP=$(cat "$DIRECTOR_PATH/ip")

export BOSH_CLIENT=admin
export DIRECTOR_PATH
export BOSH_CLIENT_SECRET
export DIRECTOR_IP

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

mkdir -p "$DIRECTOR_PATH/cf-deployment/"

echo "::::::::::::::CREATING MANIFEST:::::::"
if [ "$USE_EIRINI_RELEASE" = true ]; then
  ./ci-resources/scripts/create_manifest_eirini.sh
else
  ./ci-resources/scripts/create_manifest_cf.sh
fi

pushd state
  if git status --porcelain | grep .; then
     echo "Repo is dirty"
     git add "environments/softlayer/director/$DIRECTOR_NAME/cf-deployment/vars.yml"
     git config --global user.email "CI.BOT@de.ibm.com"
     git config --global user.name "Come-On Eirini"
     git commit -am "update/add deployment vars.yml"
  else
     echo "Repo is clean"
  fi
popd

cp -r state/. new-state
