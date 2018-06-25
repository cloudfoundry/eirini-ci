#!/bin/bash

set -x

readonly WORKSPACE="$GOPATH/src/code.cloudfoundry.org/eirini"

setupTestEnv(){
    mkdir -p "$WORKSPACE"
    cp -r eirini/* "$WORKSPACE"
}

runTests(){
    # skipping minikube tests
    ginkgo -r -keepGoing --skipPackage=launcher,recipe --skip="Desiring some LRPs|Desiretask"
}

main(){
    setupTestEnv
    cd "$WORKSPACE"
    runTests
}

main
