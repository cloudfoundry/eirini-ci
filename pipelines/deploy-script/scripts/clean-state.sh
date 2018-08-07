#!/bin/bash

set -ex

# shellcheck source=/dev/null
source "${EIRINI_LITE?"please set EIRINI_LITE env variable"}/eirini-release/scripts/lite/set-env.sh"

main(){
  set_env
  destroy_minikube
  destroy_bosh
  remove_repos
}

destroy_minikube() {
  echo Destroying Minikube
  minikube delete
  rm -rf "$HOME/.kube"
}

destroy_bosh() {
  echo Destroying Bosh
  local vm_cid
	vm_cid="$(bosh interpolate "$BOSH_DEPLOYMENT_DIR/state.json" --path /current_vm_cid)"

  vboxmanage controlvm "$vm_cid" poweroff
  vboxmanage unregistervm "$vm_cid" --delete

  ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.50.6
  ssh-add -D

  rm -rf "$HOME/.bosh"
  rm -rf "$HOME/.bosh_virtualbox_cpi"
}

remove_repos() {
  echo Removing Repos
  rm -rf "$EIRINI_LITE/cf-deployment"
  rm -rf "$EIRINI_LITE/bosh-deployment"
  rm -rf "$EIRINI_LITE/eirini-release"
  rm -rf "$EIRINI_LITE/capi-release"
}

main
