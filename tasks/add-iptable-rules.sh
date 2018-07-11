#!/bin/bash

set -euox pipefail

readonly DIRECTOR_DIR="./state/environments/softlayer/director/$DIRECTOR_NAME"
readonly JUMPBOX_KEY="$DIRECTOR_DIR/jumpbox.key"
readonly DIRECTOR_IP="$(cat "$DIRECTOR_DIR/ip")"

main() {
	chmod +x "$JUMPBOX_KEY"
  set_rules
}

set_rules() {
	# NATS
	ssh -o "StrictHostKeyChecking no" "jumpbox@$DIRECTOR_IP" -i "$JUMPBOX_KEY" \
		sudo iptables \
		-t nat \
		-I PREROUTING 2 \
		-p tcp \
		--dport 4222 \
		-j DNAT \
		--to 10.244.0.129:4222

	# OPI
	ssh -o "StrictHostKeyChecking no" "jumpbox@$DIRECTOR_IP" -i "$JUMPBOX_KEY" \
		sudo iptables \
		-t nat \
		-I PREROUTING 2 \
		-p tcp \
		--dport 8090 \
		-j DNAT \
		--to 10.244.0.142:8085

	# REGISTRY
	ssh -o "StrictHostKeyChecking no" "jumpbox@$DIRECTOR_IP" -i "$JUMPBOX_KEY" \
		sudo iptables \
		-t nat \
		-I PREROUTING 2 \
		-p tcp \
		--dport 8089 \
		-j DNAT \
		--to 10.244.0.142:8080
}

main
