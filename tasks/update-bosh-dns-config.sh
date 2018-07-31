#!/bin/bash -ex

DIRECTOR_PATH="state/environments/softlayer/director/$BOSH_LITE_NAME"

. 1-click/tasks/bosh-login.sh

bosh2 -n update-runtime-config bosh-deployment/runtime-configs/dns.yml \
	--name=dns \
	--vars-store "$DIRECTOR_PATH/cf-deployment/vars.yml"
