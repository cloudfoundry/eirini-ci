#!/bin/bash

readonly DIRECTOR_DIR="state/environments/softlayer/director/$DIRECTOR_NAME"
readonly JUMPBOX_KEY="$DIRECTOR_DIR/jumpbox.key"
readonly DIRECTOR_IP="$(cat "$DIRECTOR_DIR/ip")"

main() {
  chmod 600 "$JUMPBOX_KEY"
  set_rules
}

set_rules() {
  local nats_rule="-p tcp --dport 4222 -j DNAT --to 10.244.0.129:4222"
  local opi_rule="-p tcp --dport 8085 -j DNAT --to 10.244.0.142:8085"
  local registry_rule="-p tcp --dport 8080 -j DNAT --to 10.244.0.142:8080"

  check_and_set "$nats_rule"
  check_and_set "$opi_rule"
  check_and_set "$registry_rule"
}

# shellcheck disable=SC2029
check_and_set(){
  local check_rule="sudo iptables -t nat -C PREROUTING"
  local insert_rule="sudo iptables -t nat -I PREROUTING 2"

  if ssh -o "StrictHostKeyChecking no" "jumpbox@$DIRECTOR_IP" -i "$JUMPBOX_KEY" "$check_rule" "$1"; then
  echo "IPTABLES RULE: $1 already exists. Skipping..."
  else
    ssh -o "StrictHostKeyChecking no" "jumpbox@$DIRECTOR_IP" -i "$JUMPBOX_KEY" \
    "$insert_rule" \
      "$1"

    echo "IPTABLES RULE: $1 SET"
  fi
}

main
