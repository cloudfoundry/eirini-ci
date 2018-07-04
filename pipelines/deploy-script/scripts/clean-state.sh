#!/bin/bash

set -ex

# shellcheck source=/dev/null
source "${EIRINI_LITE?"please set EIRINI_LITE env variable"}/eirini-release/scripts/set-env.sh"

main(){
	 echo ":::::::Destroying Minikube"
	 destroy_minikube
	 echo ":::::::Destroying Bosh"
	 destroy_bosh
	 echo ":::::::Removing Repos"
   remove_repos
}

destroy_minikube() {
	minikube delete
	rm -rf "$HOME/.kube"
}

destroy_bosh() {
  local vm_cid
	vm_cid="$(bosh int "$BOSH_DEPLOYMENT/state.json" --path /current_vm_cid)"

	vboxmanage controlvm "$vm_cid" poweroff
	vboxmanage unregistervm "$vm_cid" --delete

  ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.50.6
	ssh-add -D

	rm -rf "$HOME/.bosh"
	rm -rf "$HOME/.bosh_virtualbox_cpi"
}

remove_repos() {
	rm -rf "$EIRINI_LITE/cf-deployment"
	rm -rf "$EIRINI_LITE/bosh-deployment"
	rm -rf "$EIRINI_LITE/eirini-release"
	rm -rf "$EIRINI_LITE/capi-release"
}

main
