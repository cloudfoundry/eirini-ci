#!/bin/bash

usage(){
  cat << EOF
  $ create-director-manifest.sh <DIRECTOR_NAME> <BOSH_DEPLOYMENT> <ONE_CLICK_PIPELINE>
EOF
exit 1
}

if [ "$1" = "help" ]; then
   usage
fi

readonly DIRECTOR_NAME=${1?Director name is required}
readonly BOSH_DEPLOYMENT=${2?Path to bosh deployment repository is required}
readonly ONE_CLICK_PIPELINE=${3?Path to one-click-pipeline}

BASEDIR="$(cd $(dirname $0)/.. && pwd)"

mkdir -p $BASEDIR/environments/softlayer/director/$DIRECTOR_NAME

bosh int $BOSH_DEPLOYMENT/bosh.yml \
  -o $BOSH_DEPLOYMENT/jumpbox-user.yml \
  -o $BOSH_DEPLOYMENT/softlayer/cpi-dynamic.yml \
  -o $BOSH_DEPLOYMENT/bosh-lite.yml \
  -o $BOSH_DEPLOYMENT/bosh-lite-runc.yml \
  -o $ONE_CLICK_PIPELINE/operations/add-etc-hosts-entry.yml \
  -o $ONE_CLICK_PIPELINE/operations/increase-max-speed.yml \
  -v director_name=eirini-lite \
  -v sl_vm_name_prefix=$DIRECTOR_NAME \
  -v sl_vm_domain=softlayer.com \
  -v sl_username=eirini@cloudfoundry.org \
	-v sl_api_key=$(pass eirini/softlayer-API-key) \
  -v sl_datacenter=lon04 \
  -v sl_vlan_public=2297791 \
  -v sl_vlan_private=2297793 \
  -v internal_ip=$DIRECTOR_NAME.softlayer.com
