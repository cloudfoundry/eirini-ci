#! /bin/bash -e

if [ -n "$DEBUG" ]; then
    set -x
    export
fi

if [[ -z $BOSH_CLIENT ]] || [[ -z $BOSH_CLIENT_SECRET ]]; then
  echo 'ERROR: Bosh credentials not found.'
  echo 'Please set up variables $BOSH_CLIENT and $BOSH_CLIENT_SECRET'
  exit 1
fi

bosh --ca-cert <(bosh interpolate $DIRECTOR_PATH/vars.yml --path /director_ssl/ca) alias-env $BOSH2_ENV_ALIAS --environment $BOSH_DIRECTOR

bosh --environment $BOSH2_ENV_ALIAS log-in -n
