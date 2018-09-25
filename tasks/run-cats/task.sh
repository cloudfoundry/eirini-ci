#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

readonly CONFIG_FILE="state/environments/kube-clusters/$CLUSTER_NAME/scf-config-values.yaml"

main() {
    ibmcloud-login
    export-kubeconfig "$CLUSTER_NAME"
    set_up_gopath
    set_up_logcache
    configure_tests
    run_tests
}
set_up_gopath() {
    mkdir -p gopath/src/github.com/cloudfoundry
    export GOPATH=$PWD/gopath
    export PATH=$PATH:$GOPATH/bin
}

set_up_logcache() {
    echo "Current CF version:"
    cf version
    cf install-plugin -r CF-Community "log-cache" -f

    export CF_PLUGIN_HOME=$HOME
    echo "CF_PLUGIN_HOME is: ${CF_PLUGIN_HOME}"

    LOG_CACHE_ADDR="http://$(kubectl get service log-cache-reads -o jsonpath='{$.status.loadBalancer.ingress[0].ip}' -n oratos):8081"
    export LOG_CACHE_ADDR
}

configure_tests() {
    local cf_domain
    cf_domain="$(goml get -f "$CONFIG_FILE" -p "env.DOMAIN")"
    local cf_admin_password
    cf_admin_password="$(goml get -f "$CONFIG_FILE" -p "secrets.CLUSTER_ADMIN_PASSWORD")"

    cat > integration_config.json <<EOF
    {
      "api": "api.${cf_domain}",
      "apps_domain": "${cf_domain}",
      "admin_user": "admin",
      "admin_password": "${cf_admin_password}",
      "skip_ssl_validation": true,
      "use_http": true,
      "use_log_cache": true,
      "include_apps": true,
      "include_backend_compatibility": false,
      "include_capi_experimental": false,
      "include_capi_no_bridge": false,
      "include_container_networking": false,
      "include_credhub" : false,
      "include_detect": true,
      "include_docker": false,
      "include_internet_dependent": false,
      "include_isolation_segments": false,
      "include_private_docker_registry": false,
      "include_route_services": false,
      "include_routing": true,
      "include_routing_isolation_segments": false,
      "include_security_groups": false,
      "include_service_discovery": false,
      "include_services": false,
      "include_service_instance_sharing": false,
      "include_ssh": false,
      "include_sso": true,
      "include_tasks": false,
      "include_v3": false,
      "include_zipkin": false
    }
EOF
    CONFIG="$(readlink -nf integration_config.json)"
    export CONFIG
}

run_tests() {
    cp -a cats "$GOPATH"/src/github.com/cloudfoundry/cf-acceptance-tests
    cd "$GOPATH"/src/github.com/cloudfoundry/cf-acceptance-tests
    ./bin/update_submodules
    ./bin/test -v -r -slowSpecThreshold=120 -randomizeAllSpecs -nodes=4 -keepGoing -skip="$SKIPPED_TESTS"
}

main

