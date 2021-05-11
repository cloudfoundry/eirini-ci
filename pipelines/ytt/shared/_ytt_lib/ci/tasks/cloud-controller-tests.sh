#!/bin/bash

set -e

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi

export KUBECONFIG=${PWD}/kube/config
export CF_RUN_EIRINI_SPECS=true
export PGPASSWORD=password
export KUBE_CLUSTER_NAME
KUBE_CLUSTER_NAME="$(awk '/current-context:/ { print $2 }' "$KUBECONFIG")"

# The ruby kubeclient supports GOOGLE_APPLICATION_CREDENTIALS, but needs to
# have an empty config object in the auth_provider of the kubeconfig file
# otherwise it causes a runtime exception. Getting the kubeconfig using gcloud
# omits the config field, which ends up as nil in ruby.
yq eval --inplace '.users.[] |= select(.name == "*integration").user.auth-provider.config |= {}' "$KUBECONFIG"

cd cloud_controller_ng

service postgresql start

bundle install
bundle exec rspec spec/unit/lib/cloud_controller/opi/ spec/unit/lib/kubernetes/api_client_spec.rb spec/unit/lib/cloud_controller/dependency_locator_spec.rb
bundle exec rspec spec/integration/eirini_k8s_client_spec.rb