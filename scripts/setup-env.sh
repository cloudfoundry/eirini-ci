#!/bin/bash

echo "setting up environment"
echo "$BOSH_CRT" > /tmp/bosh2ca.crt

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config


director_ip=`cat $DIRECTOR_PATH/ip`
# setup dns entry for bosh director
echo "$director_ip $BOSH_DIRECTOR" > /etc/hosts
