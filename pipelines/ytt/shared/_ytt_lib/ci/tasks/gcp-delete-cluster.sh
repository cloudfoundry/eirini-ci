#!/bin/bash

set -euo pipefail

echo "$GCP_SERVICE_ACCOUNT_JSON" >"$PWD/service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

pushd ci-resources/gke-cluster || exit 1
{
  terraform init -backend-config="prefix=terraform/state/$CLUSTER_NAME"
  cluster_values="$(terraform show -json | jq -r '.values ')"
  if [ "$cluster_values" == "null" ]; then
    echo "Cluster $CLUSTER_NAME does not exist"
    exit 0
  fi

  # Firewall rules are created when a LoadBalancer Service is created in GCP,
  # and since terraform doesn't know about them, they have to be manually deleted.
  # See https://github.com/terraform-providers/terraform-provider-google/issues/5948
  cluster_network="$(terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "network") | .values.name')"
  if [[ -n "$cluster_network" ]]; then
    gcloud-login
    firewall_rules=$(gcloud compute firewall-rules list --filter=network="$cluster_network" --format="value(name)")
    for rule_name in $firewall_rules; do
      gcloud compute firewall-rules delete "$rule_name" --quiet || echo "firewall rule $rule_name not found"
    done
  fi

  terraform destroy -var "name=$CLUSTER_NAME" \
    -var "node-count-per-zone=$WORKER_COUNT" \
    -auto-approve
}
popd || exit 1
