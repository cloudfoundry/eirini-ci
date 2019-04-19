#!/bin/bash

set -xeuo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/docker

trap clean-artefacts EXIT
SCF_DIR=$PWD/scf

main() {
  start-docker
  prepare-release
  make-scf
  update-helm-templates
  docker-push
  git-commit
}

clean-artefacts() {
  set +e
  rm -rf "$SCF_DIR"
  set -e
}

prepare-release() {
  pushd scf
  # shellcheck disable=SC1091
  source .envrc
  export FISSILE_STEMCELL=splatform/fissile-stemcell-opensuse:42.3-24.g63783b3-30.60
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
  rm -rf eirini-release/helm/cf/templates
  cp -r scf/output/helm/templates eirini-release/helm/cf/
  cp -r scf/output/helm/*.yaml eirini-release/helm/cf/
}

docker-push() {
  docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
  echo "Pushing Docker images ..."
  docker images --format "{{.Repository}}:{{.Tag}}" | grep eirinicf | while read -r DOCKER_IMAGE_AND_TAG; do
    docker push "$DOCKER_IMAGE_AND_TAG"
  done
}

git-commit() {
  pushd eirini-release || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "helm/cf/templates"
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
