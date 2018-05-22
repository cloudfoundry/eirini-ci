#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $DIRECTOR_PATH/vars.yml --path /admin_password`

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

bosh -e lite -d cf -n delete-deployment
