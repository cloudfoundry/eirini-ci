#!/bin/bash

set -euo pipefail

tar xzvf cf-for-k8s-github-release/source.tar.gz -C .
sha="$(<cf-for-k8s-github-release/commit_sha)"
src_folder="cloudfoundry-cf-for-k8s-${sha:0:7}"
rm -rf "$src_folder/build/eirini/_vendir/eirini"
cp -r eirini-release/helm/eirini "$src_folder/build/eirini/_vendir/"

./"$src_folder"/build/eirini/build.sh

cp -r "$src_folder"/* patched-cf-for-k8s/
