#!/bin/bash

set -euo pipefail

src_folder="cf-for-k8s"
render_dir="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -rf $render_dir" EXIT

rm -rf "$src_folder/build/eirini/_vendir/eirini"

eirini-release/scripts/render-templates.sh cf-system "$render_dir" --values eirini-release/scripts/assets/cf-for-k8s-value-overrides.yml
mv "$render_dir/templates" "$render_dir/eirini"
pushd "$src_folder"
{
  vendir sync -d "build/eirini/_vendir=$render_dir"
}
popd

./"$src_folder"/build/eirini/build.sh

cp -r "$src_folder"/* patched-cf-for-k8s/
