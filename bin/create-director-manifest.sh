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

BASEDIR="$(cd "$(dirname $0)/.." && pwd)"

mkdir -p $BASEDIR/environments/softlayer/director/$DIRECTOR_NAME

bosh interpolate $BOSH_DEPLOYMENT/bosh.yml \
  --ops-file $BOSH_DEPLOYMENT/jumpbox-user.yml \
  --ops-file $BOSH_DEPLOYMENT/softlayer/cpi-dynamic.yml \
  --ops-file $BOSH_DEPLOYMENT/bosh-lite.yml \
  --ops-file $BOSH_DEPLOYMENT/bosh-lite-runc.yml \
  --ops-file $ONE_CLICK_PIPELINE/operations/add-etc-hosts-entry.yml \
  --ops-file $ONE_CLICK_PIPELINE/operations/increase-max-speed.yml \
  --ops-file $ONE_CLICK_PIPELINE/operations/disable-virtual-delete-vms.yml \
  --ops-file $BASEDIR/operations/configure-blobstore.yml \
  --var director_name=eirini-lite \
  --var sl_vm_name_prefix=$DIRECTOR_NAME \
  --var sl_vm_domain=softlayer.com \
  --var sl_username=eirini@cloudfoundry.org \
  --var sl_api_key="$(pass eirini/softlayer-API-key)" \
  --var sl_datacenter=lon04 \
  --var sl_vlan_public=2297791 \
  --var sl_vlan_private=2297793 \
  --var internal_ip=$DIRECTOR_NAME.softlayer.com
