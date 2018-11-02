#!/bin/bash

set -ueo pipefail
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
      "skip_ssl_validation": ${SKIP_SSL_VALIDATION},
      "use_http": ${USE_HTTP},
      "use_log_cache": ${USE_LOG_CACHE},
      "include_apps": ${INCLUDE_APPS},
      "include_backend_compatibility": ${INCLUDE_BACKEND_COMPATIBILITY},
      "include_capi_experimental": ${INCLUDE_CAPI_EXPERIMENTAL},
      "include_capi_no_bridge": ${INCLUDE_CAPI_NO_BRIDGE},
      "include_container_networking": ${INCLUDE_CONTAINER_NETWORKING},
      "include_credhub" : ${INCLUDE_CREDHUB},
      "include_detect": ${INCLUDE_DETECT},
      "include_docker": ${INCLUDE_DOCKER},
      "include_internet_dependent": ${INCLUDE_INTERNET_DEPENDENT},
      "include_isolation_segments": ${INCLUDE_ISOLATION_SEGMENTS},
      "include_private_docker_registry": ${INCLUDE_PRIVATE_DOCKER_REGISTRY},
      "include_route_services": ${INCLUDE_ROUTE_SERVICES},
      "include_routing": ${INCLUDE_ROUTING},
      "include_routing_isolation_segments": ${INCLUDE_ROUTING_ISOLATION_SEGMENTS},
      "include_security_groups": ${INCLUDE_SECURITY_GROUPS},
      "include_service_discovery": ${INCLUDE_SERVICE_DISCOVERY},
      "include_services": ${INCLUDE_SERVICES},
      "include_service_instance_sharing": ${INCLUDE_SERVICE_INSTANCE_SHARING},
      "include_ssh": ${INCLUDE_SSH},
      "include_sso": ${INCLUDE_SSO},
      "include_tasks": ${INCLUDE_TASKS},
      "include_v3": ${INCLUDE_V3},
      "include_zipkin": ${INCLUDE_ZIPKIN}
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

