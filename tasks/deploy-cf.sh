#!/bin/bash

set -ex

export DIRECTOR_PATH=state/environments/softlayer/director/$DIRECTOR_NAME

export BOSH_CLIENT=admin
BOSH_CLIENT_SECRET=$(bosh interpolate "$DIRECTOR_PATH/vars.yml" --path /admin_password)
export BOSH_CLIENT_SECRET

./ci-resources/scripts/setup-env.sh
./ci-resources/scripts/bosh-login.sh

main() {
  prepare-capi-release
	prepare-eirini-release
	deploy-cf
	cleanup
}

prepare-capi-release() {
  echo Prepare CAPI release
  pushd capi
    bosh sync-blobs
  popd
}

prepare-eirini-release() {
  [ "$USE_EIRINI_RELEASE" = true ] || return

  echo Prepare Eirini release
  pushd eirini-release
    apt remove --yes docker-ce
    apt install --yes docker-ce=17.09.1~ce-0~debian

    echo 'DOCKER_OPTS="--data-root /scratch/docker --max-concurrent-downloads 10"' > /etc/default/docker
    service docker start
    service docker status
    trap 'service docker stop' EXIT
		sleep 5

		GOPATH=$PWD ./scripts/buildfs.sh

    bosh sync-blobs
  popd
}

deploy-cf() {
  echo Deploy CF
  bosh --environment lite \
       --non-interactive \
		deploy manifest/manifest.yml \
		   --deployment cf \
       --var capi_local_path="$(pwd)/capi" \
       --vars-store "$DIRECTOR_PATH/cf-deployment/vars.yml"
}

cleanup() {
  echo Clean up
  bosh --environment lite \
		   --non-interactive \
		clean-up \
		  --all
}

main "$@"

