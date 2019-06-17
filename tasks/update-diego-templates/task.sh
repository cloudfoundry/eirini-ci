#!/bin/bash

set -euo pipefail

main(){
  update-templates
  commit
}

update-templates(){
  pushd eirini-release
    sed -i '2i\{{ if .Values.env.ENABLE_OPI_STAGING  }}' helm/cf/templates/diego-*.yaml
    sed -i -e '\$a{{- end}}' helm/cf/templates/diego-*.yaml
  popd || exit
}

commit(){
  pushd eirini-release
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "helm/cf/templates/diego-*.yaml"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update diego templates"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-modified/
}

main


