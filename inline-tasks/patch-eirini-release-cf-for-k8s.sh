#!/bin/bash

set -euo pipefail

tar xzvf cf-for-k8s-github-release/source.tar.gz -C .
sha="$(<cf-for-k8s-github-release/commit_sha)"
src_folder="cloudfoundry-cf-for-k8s-${sha:0:7}"
rm -rf "$src_folder/build/eirini/_vendir/eirini"

eirini_values=./"$src_folder"/build/eirini/eirini-values.yml
eirini_custom_values=./"$src_folder"/build/eirini/eirini-custom-values.yml
eirini_values_merged=./"$src_folder"/build/eirini/eirini-values-merged.yml

cat >"./"$src_folder"/build/eirini/add-namespaces-overlay.yml" <<EOF
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind":"Namespace", "metadata":{"name":"cf-workloads"}})
#@overlay/remove
---

EOF

cat >>"$eirini_custom_values" <<EOF
---
opi:
  serviceName: eirini
  lrpController:
    tls:
      secretName: "eirini-internal-tls-certs"
      keyPath: "tls.key"
      caPath: "tls.ca"
      certPath: "tls.crt"
  tasks:
    tls:
      taskReporter:
          secretName: "eirini-internal-tls-certs"
          keyPath: "tls.key"
          caPath: "tls.ca"
          certPath: "tls.crt"

EOF

yq -s '.[0] * .[1]' "$eirini_values" "$eirini_custom_values" -y >"$eirini_values_merged"
mv "$eirini_values_merged" "$eirini_values"

cp -r eirini-release/helm/eirini "$src_folder/build/eirini/_vendir/"

./"$src_folder"/build/eirini/build.sh

cp -r "$src_folder"/* patched-cf-for-k8s/
