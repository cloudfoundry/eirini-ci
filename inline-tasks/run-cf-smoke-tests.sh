#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

main() {
  set_up_gopath
  configure_tests
  run_tests
}

set_up_gopath() {
  mkdir -p gopath/src/github.com/cloudfoundry
  export GOPATH=$PWD/gopath
  export PATH=$PATH:$GOPATH/bin
}

configure_tests() {
  local cf_domain
  cf_domain="$(cat cf-credentials/cf-domain)"
  local cf_admin_password
  cf_admin_password="$(cat cf-credentials/cf-admin-password)"

  cat >config.json <<EOF
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
      "use_log_cache"                   : false,
      "logging_app"                     : "",
      "runtime_app"                     : "",
      "enable_windows_tests"            : false,
      "windows_stack"                   : "windows2012R2",
      "enable_etcd_cluster_check_tests" : false,
      "etcd_ip_address"                 : "",
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
