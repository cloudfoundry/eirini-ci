#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="$CLUSTER_STATE/environments/kube-clusters/$CLUSTER_NAME"

aggregate-files() {
  mkdir -p "$CLUSTER_DIR"
  cp default-values-file/values.yml "$CLUSTER_DIR"/default-values.yml
  cp loadbalancer-values-file/values.yml "$CLUSTER_DIR"/loadbalancer-values.yml

  cp -r "$CLUSTER_STATE/." "$CLUSTER_STATE_MODIFIED"
}

# cf-for-k8s does not support rotating the database password.
# See: https://github.com/cloudfoundry/cf-for-k8s/issues/530
# We discovered experimentally the additional values that
# should also not be rotated.
preserve_deployed_passwords() {
  local blobstore_key ccdb_password ccdb_encryption_key uaa_password
  blobstore_key="$(yq eval '.blobstore.secret_access_key' "${CLUSTER_DIR}/default-values.yml")"
  ccdb_password="$(yq eval '.capi.database.password' "${CLUSTER_DIR}/default-values.yml")"
  ccdb_encryption_key="$(yq eval '.capi.database.encryption_key' "${CLUSTER_DIR}/default-values.yml")"
  uaa_password="$(yq eval '.uaa.database.password' "${CLUSTER_DIR}/default-values.yml")"

  local blobstore_key_old ccdb_password_old ccdb_encryption_key_old uaa_password_old
  blobstore_key_old="$(yq eval '.blobstore.secret_access_key' default-values-file/values.yml)"
  ccdb_password_old="$(yq eval '.capi.database.password' default-values-file/values.yml)"
  ccdb_encryption_key_old="$(yq eval '.capi.database.encryption_key' default-values-file/values.yml)"
  uaa_password_old="$(yq eval '.uaa.database.password' default-values-file/values.yml)"

  sed -i "s/$blobstore_key_old/$blobstore_key/g" default-values-file/values.yml
  sed -i "s/$ccdb_password_old/$ccdb_password/g" default-values-file/values.yml
  sed -i "s/$ccdb_encryption_key_old/$ccdb_encryption_key/g" default-values-file/values.yml
  sed -i "s/$uaa_password_old/$uaa_password/g" default-values-file/values.yml
}

main() {
  if [[ -f "$CLUSTER_DIR/default-values.yml" ]]; then
    preserve_deployed_passwords
  fi

  aggregate-files
}

main "$@"
