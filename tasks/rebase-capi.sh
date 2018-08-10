#!/bin/bash

set -x

readonly CAPI_REMOTE="https://github.com/cloudfoundry/capi-release.git"

main(){
	add_remote
  rebase_capi
	update_submodule
	commit
}

add_remote(){
  pushd capi || exit 1
    git remote add original "$CAPI_REMOTE"
  popd || exit 1
}

rebase_capi(){
  pushd capi || exit 1
    git fetch original "refs/notes/*:refs/notes/*"
    git pull --rebase=preserve original master
    git checkout --ours src/cloud_controller_ng
		git checkout --ours .gitmodules
		git rebase --continue
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
