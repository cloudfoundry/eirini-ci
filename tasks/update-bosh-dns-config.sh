#!/bin/bash -ex

. 1-click/tasks/bosh-login.sh

bosh2 -n update-runtime-config bosh-deployment/runtime-configs/dns.yml --name=dns
