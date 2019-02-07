#!/bin/bash

set -ueo pipefail
IFS=$'\n\t'

export GOPATH="$PWD/eirini-source"
export PATH="$PATH:$GOPATH/bin"
export DB=postgres
readonly EIRINI_MAIN="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini/cmd/opi/"

main() {
  build-opi
  start-postgres
  run-tests
}

build-opi() {
  pushd "$EIRINI_MAIN"
  go install
  popd
}

start-postgres() {
  service postgresql restart
  trap stop-postgres EXIT
}

stop-postgres() {
  service postgresql stop
}

run-tests() {
  pushd cc-ng-fork
  export BUNDLE_GEMFILE=Gemfile
  bundle install

  bundle exec rake rubocop
  CF_RUN_OPI_SPEC=true bundle exec rake spec:serial
  popd
}

main
