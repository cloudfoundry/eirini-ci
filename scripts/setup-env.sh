#!/bin/bash

echo "setting up environment"
echo "$BOSH_CRT" > /tmp/bosh2ca.crt

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config

# setup dns entry for bosh director
echo "$DIRECTOR_IP $BOSH_DIRECTOR" > /etc/hosts
