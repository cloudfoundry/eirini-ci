#!/bin/bash

set -x

readonly CAPI_REMOTE="https://github.com/cloudfoundry/capi-release"

main(){
	add_remote
  rebase_capi
	update_submodule
	commit
}

add_remote(){
  git remote add original "$CAPI_REMOTE"
}

rebase_capi(){
  pushd capi || exit 1
    git fetch original "refs/notes/*:refs/notes/*"
    git pull --rebase=preserve original master
  popd || exit 1
}

update_submodule(){
  pushd capi/src/cloud_controller_ng/ || exit 1
    git pull origin eirini
  popd || exit 1
}

commit(){
  cp -r capi/. capi-modified

  pushd capi-modified || exit 1
    git add src/cloud_controller_ng/
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Bump cloud_controller_ng submodule"
  popd || exit 1
}

main "$@"
