#!/bin/bash

set -x

GOPATH=$(readlink -f eirini-source)

readonly WORKSPACE="$GOPATH/src/code.cloudfoundry.org/eirini"

runTests(){
    # skipping minikube tests
    ginkgo -r -keepGoing --skipPackage=launcher,recipe --skip="Desiring some LRPs|Desiretask"
}

main(){
    cd "$WORKSPACE"
    runTests
}

main
