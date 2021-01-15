#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="cluster-state/environments/kube-clusters/$CLUSTER_NAME"

update-cluster-state-repo() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "environments/kube-clusters/$CLUSTER_NAME/*"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add cf-for-k8s values files"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

aggregate-files() {
  mkdir -p "$CLUSTER_DIR"
  cp default-values-file/values.yml "$CLUSTER_DIR"/default-values.yml
  cp loadbalancer-values-file/values.yml "$CLUSTER_DIR"/loadbalancer-values.yml
}

# cf-for-k8s does not support rotating the database password.
# See: https://github.com/cloudfoundry/cf-for-k8s/issues/530
# We discovered experimentally the additional values that
# should also not be rotated.
preserve_deployed_passwords() {
  local blobstore_key ccdb_password ccdb_encryption_key uaa_password
  blobstore_key="$(yq read "${CLUSTER_DIR}/default-values.yml" blobstore.secret_access_key)"
  ccdb_password="$(yq read "${CLUSTER_DIR}/default-values.yml" capi.database.password)"
  ccdb_encryption_key="$(yq read "${CLUSTER_DIR}/default-values.yml" capi.database.encryption_key)"
  uaa_password="$(yq read "${CLUSTER_DIR}/default-values.yml" uaa.database.password)"

  local blobstore_key_old ccdb_password_old ccdb_encryption_key_old uaa_password_old
  blobstore_key_old="$(yq read default-values-file/values.yml blobstore.secret_access_key)"
  ccdb_password_old="$(yq read default-values-file/values.yml capi.database.password)"
  ccdb_encryption_key_old="$(yq read default-values-file/values.yml capi.database.encryption_key)"
  uaa_password_old="$(yq read default-values-file/values.yml uaa.database.password)"

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
  update-cluster-state-repo
}

main "$@"
