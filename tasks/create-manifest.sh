#!/bin/bash

set -e

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $DIRECTOR_PATH/vars.yml --path /admin_password`

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

director_ip=`cat $DIRECTOR_PATH/ip`
mkdir -p $DIRECTOR_PATH/cf-deployment/

pushd ./eirini-release

nats_password=`bosh int ../state/cf-deployment/deployment-vars.yml --path /nats_password`


echo "::::::::::::::CREATING MANIFEST:::::::"
bosh int ../cf-deployment/cf-deployment.yml \
     --vars-store ../$DIRECTOR_PATH/cf-deployment/vars.yml \
     -o ../cf-deployment/operations/experimental/enable-bpm.yml \
     -o ../cf-deployment/operations/use-compiled-releases.yml \
     -o ../cf-deployment/operations/bosh-lite.yml \
     -o ../cf-deployment/operations/experimental/use-bosh-dns.yml \
     -o ./operations/eirini-bosh-operations.yml \
     -o ./operations/dev-version.yml \
     -o ../cf-deployment/iaas-support/softlayer/add-system-domain-dns-alias.yml \
     --var=k8s_flatten_cluster_config="$(kubectl config view --flatten=true)" \
     -v system_domain="$director_ip.nip.io" \
     -v cc_api="https://api.$director_ip.nip.io" \
     -v kube_namespace=$KUBE_NAMESPACE \
     -v kube_endpoint=$KUBE_ENDPOINT \
     -v nats_ip=$NATS_IP \
     -v nats_password=$nats_password \
     -v registry_address="registry.$director_ip.nip.io:8089" \
     -v eirini_ip=$EIRINI_IP \
     -v eirini_address="http://eirini.$director_ip.nip.io:8090" \
     -v eirini_local_path=./ > ../manifest/manifest.yml
popd

pushd state
  if git status --porcelain | grep .; then
     echo "Repo is dirty"
     git add environments/softlayer/director/$DIRECTOR_NAME/cf-deployment/vars.yml
     git config --global user.email "CI.BOT@de.ibm.com"
     git config --global user.name "Come-On Eirini"
     git commit -am "update/add deployment vars.yml"
  else
     echo "Repo is clean"
  fi
popd

cp -r state/. new-state
