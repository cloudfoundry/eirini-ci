#!/bin/bash

set -e

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

pushd ./cube-release

bosh sync-blobs
git submodule update --init --recursive

echo "::::::::::::::DEPLOY CUBE RELEASE:::::::"
bosh -e lite -d cf deploy -n ../cf-deployment/cf-deployment.yml \
     --vars-store ../ci-resources/bosh-lite/deployment-vars.yml \
     -o ../cf-deployment/operations/experimental/enable-bpm.yml \
     -o ../cf-deployment/operations/bosh-lite.yml \
     -o ../cf-deployment/operations/use-compiled-releases.yml \
     -o ./operations/cube-bosh-operations.yml \
     -o ./operations/dev-version.yml
     --var=k8s_flatten_cluster_config="$(kubectl config view --flatten=true)" \
     -v system_domain=bosh-lite-cube.dynamic-dns.net \
     -v cc_api=$CC_API \
     -v cube_local_path=./

echo "::::::::::::::CLEAN-UP:::::::;::::::::::"
bosh -e lite clean-up --non-interactive --all

popd
