#!/bin/bash -ex

source ./ci-resources/scripts/tests-env-setup.sh

main() {
    set_up_gopath
    set_up_kubectl
    set_up_logcache
    configure_tests
    run_tests
}

configure_tests() {
    local cf_admin_password=$(bosh2 int state/environments/softlayer/director/$DIRECTOR_NAME/cf-deployment/vars.yml --path /cf_admin_password)
    local director_ip=$(cat state/environments/softlayer/director/"$DIRECTOR_NAME"/ip)

    cat > integration_config.json <<EOF
    {
      "api": "api.${director_ip}.nip.io",
      "apps_domain": "${director_ip}.nip.io",
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
    export CONFIG="$(readlink -nf integration_config.json)"
}

run_tests() {
    local skipped_tests="$(cat ci-resources/config-stubs/cats | tr '\n' '|' | sed 's/.$//')"
    cp -a cats $GOPATH/src/github.com/cloudfoundry/cf-acceptance-tests
    cd $GOPATH/src/github.com/cloudfoundry/cf-acceptance-tests
    ./bin/update_submodules
    ./bin/test -v -r -slowSpecThreshold=120 -randomizeAllSpecs -nodes=4 -keepGoing -skip="$skipped_tests"
}

main

