#!/bin/bash

set -xeuo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
  start-docker
  init-scf-submodules
  prepare-release
  use-eirini-capi
  make-scf
  update-helm-templates
  docker-push
  git-commit
}

init-scf-submodules() {
  pushd scf
  grep "submodule" .gitmodules |
    grep --invert-match "capi" |
    awk '{print $2}' |
    tr --delete '"]' |
    xargs git submodule update --init --recursive
  popd
}

use-eirini-capi() {
  pushd capi-release
    git submodule update --init --recursive
  popd
  cp -r capi-release scf/src
}

prepare-release() {
  pushd scf
  # shellcheck disable=SC1091
  source .envrc
  export FISSILE_STEMCELL=splatform/fissile-stemcell-opensuse:develop-42.3-6.g1785bff-30.51
  make docker-deps
  popd
}

make-scf() {
  pushd scf
  export RUBY_VERSION=2.3.1
  make releases \
    compile \
    images
  popd
}

update-helm-templates() {
  find scf/output/helm/templates/ \( -name "cc-*" -o -name "api*" -o -name "blobstore*" \) -type f -print0 | xargs -0 -I % cp % eirini-release/helm/cf/templates
}

docker-push() {
  docker login -u "$FISSILE_DOCKER_USERNAME" -p "$FISSILE_DOCKER_PASSWORD"
  echo "Pushing Docker images ..."
  docker images --format "{{.Repository}}:{{.Tag}}" | grep eirinicf | while read -r DOCKER_IMAGE_AND_TAG; do
    docker push "$DOCKER_IMAGE_AND_TAG"
  done
}

git-commit() {
  pushd eirini-release || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "scf/helm/cf/templates"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update scf templates"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-modified/
}

main
