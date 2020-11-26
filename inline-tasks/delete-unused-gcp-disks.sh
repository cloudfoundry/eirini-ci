#!/bin/bash

set -euo pipefail

echo "$GCP_SERVICE_ACCOUNT_JSON" >"$PWD/service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

# shellcheck disable=SC1091
source ci-resources/scripts/gcloud-functions

delete-disk() {
  local disk_name zone
  disk_name="$1"
  zone="$2"
  echo "Deleting disk: $disk_name in region: $zone"
  gcloud compute disks delete -q "$disk_name" --zone "$zone"
}

main() {
  gcloud-login
  disks=$(gcloud compute disks list --filter="-users:*" --format="csv[separator=' ',no-heading](name, location())")
  if [[ -z "$disks" ]]; then
    echo "Nothing to delete!"
    exit 0
  fi

  while IFS= read -r line; do
    local disk_name zone
    disk_name="$(echo "$line" | awk '{print $1}')"
    zone="$(echo "$line" | awk '{print $2}')"
    delete-disk "$disk_name" "$zone"
  done < <(echo "${disks}")
}

main
