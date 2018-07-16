#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
BOSH_CLIENT_SECRET=$(bosh interpolate $DIRECTOR_PATH/vars.yml --path /admin_password)
export BOSH_CLIENT_SECRET

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

bosh --environment lite --deployment cf --non-interactive delete-deployment
