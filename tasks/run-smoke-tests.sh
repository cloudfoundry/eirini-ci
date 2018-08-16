#!/bin/bash -ex

main() {
    set_up_gopath
    set_up_kubectl
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

    export LOG_CACHE_ADDR="http://$(kubectl get service log-cache-reads -o jsonpath='{$.status.loadBalancer.ingress[0].ip}' -n oratos):8081"
}

configure_tests() {
    local cf_admin_password=$(bosh2 int state/environments/softlayer/director/$DIRECTOR_NAME/cf-deployment/vars.yml --path /cf_admin_password)
    local director_ip=`cat state/environments/softlayer/director/$DIRECTOR_NAME/ip`

    cat > config.json <<EOF
    {
      "suite_name"                      : "CF_SMOKE_TESTS",
      "api"                             : "api.${director_ip}.nip.io",
      "apps_domain"                     : "${director_ip}.nip.io",
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
    export CONFIG="$(readlink -nf config.json)"
}


set_up_kubectl() {
    echo "$KUBE_CONF" > kube.yml
    export KUBECONFIG=$PWD/kube.yml

    echo "KUBECONFIG is at: ${KUBECONFIG}"

    echo "Installing kubectl..."

    apt-get update && sudo apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    touch /etc/apt/sources.list.d/kubernetes.list
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubectl

    echo "kubectl installed successfully!"
    kubectl version
}


run_tests() {
    cp -a cf-smoke-tests $GOPATH/src/github.com/cloudfoundry/
    cd $GOPATH/src/github.com/cloudfoundry/cf-smoke-tests
    # Using nodes=1, because multiple nodes seem to cause race-conditions. Is that a bug in cf-smoke-tests?
    bin/test -v -r -slowSpecThreshold=120 -randomizeAllSpecs -nodes=1 -keepGoing
}

main
