#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $DIRECTOR_PATH/vars.yml --path /admin_password`

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

pushd ./eirini-release

nats_password=`bosh int ../state/cf-deployment/deployment-vars.yml --path /nats_password`

echo "::::::::::::::CREATING MANIFEST:::::::"
bosh int ../cf-deployment/cf-deployment.yml \
     --vars-store ../state/cf-deployment/deployment-vars.yml \
     -o ../cf-deployment/operations/experimental/enable-bpm.yml \
     -o ../cf-deployment/operations/use-compiled-releases.yml \
     -o ../cf-deployment/operations/bosh-lite.yml \
     -o ../cf-deployment/operations/experimental/use-bosh-dns.yml \
     -o ./operations/eirini-bosh-operations.yml \
     -o ./operations/dev-version.yml \
     -o ../cf-deployment/iaas-support/softlayer/add-system-domain-dns-alias.yml \
     --var=k8s_flatten_cluster_config="$(kubectl config view --flatten=true)" \
     -v system_domain=$SYSTEM_DOMAIN \
     -v cc_api=$CC_API \
     -v kube_namespace=$KUBE_NAMESPACE \
     -v kube_endpoint=$KUBE_ENDPOINT \
     -v nats_ip=$NATS_IP \
     -v nats_password=$nats_password \
     -v registry_address=$REGISTRY_ADDRESS \
     -v eirini_ip=$EIRINI_IP \
     -v eirini_address=$EIRINI_ADDRESS \
     -v eirini_local_path=./ > ../manifest/manifest.yml

