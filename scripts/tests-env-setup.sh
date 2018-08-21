#!/bin/bash -ex


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

set_up_gopath() {
    mkdir -p gopath/src/github.com/cloudfoundry
    export GOPATH=$PWD/gopath
    export PATH=$PATH:$GOPATH/bin
}

cp -a cats gopath/src/github.com/cloudfoundry/cf-acceptance-tests


set_up_logcache() {
    echo "Current CF version:"
    cf version
    cf install-plugin -r CF-Community "log-cache" -f

    export CF_PLUGIN_HOME=$HOME
    echo "CF_PLUGIN_HOME is: ${CF_PLUGIN_HOME}"

    export LOG_CACHE_ADDR="http://$(kubectl get service log-cache-reads -o jsonpath='{$.status.loadBalancer.ingress[0].ip}' -n oratos):8081"
}

