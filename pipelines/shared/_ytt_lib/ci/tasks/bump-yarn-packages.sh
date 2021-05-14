#!/usr/bin/env bash

set -euxo pipefail

commit() {
  pushd eirinidotcf
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add web
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Bump yarn packages"
  else
    echo "Repo is clean"
  fi
  popd
  cp -r eirinidotcf/. eirinidotcf-updated
}

main() {
  yarnpkg upgrade --cwd eirinidotcf/web
  commit
}

main
