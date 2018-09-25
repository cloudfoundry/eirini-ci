#!/bin/bash

set -euo pipefail
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

    cat > config.json <<EOF
    {
      "suite_name"                      : "CF_SMOKE_TESTS",
      "api"                             : "api.${cf_domain}",
      "apps_domain"                     : "${cf_domain}",
      "user"                            : "admin",
      "password"                        : "${cf_admin_password}",
      "cleanup"                         : false,
      "use_existing_org"                : true,
      "org"                             : "system",
      "use_existing_space"              : false,
      "use_log_cache"                   : true,
      "logging_app"                     : "",
      "runtime_app"                     : "",
      "enable_windows_tests"            : false,
      "windows_stack"                   : "windows2012R2",
      "enable_etcd_cluster_check_tests" : false,
      "etcd_ip_address"                 : "",
      "backend"                         : "diego",
      "isolation_segment_name"          : "is1",
      "isolation_segment_domain"        : "is1.bosh-lite.com",
      "enable_isolation_segment_tests"  : false,
      "skip_ssl_validation"             : true
    }
EOF
    CONFIG="$(readlink -nf config.json)"
    export CONFIG
}

run_tests() {
    cp -a cf-smoke-tests "$GOPATH"/src/github.com/cloudfoundry/
    cd "$GOPATH"/src/github.com/cloudfoundry/cf-smoke-tests
    # Using nodes=1, because multiple nodes seem to cause race-conditions. Is that a bug in cf-smoke-tests?
    bin/test -v -r -slowSpecThreshold=120 -randomizeAllSpecs -nodes=1 -keepGoing
}

main
