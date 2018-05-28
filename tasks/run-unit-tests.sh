#!/bin/bash

readonly BASEDIR="$(cd $(dirname $0)/.. && pwd)"
readonly DEFAULTS="launcher blobondemand vendor scripts cmd opi eirinifakes"
readonly EXCLUDE="$DEFAULTS $@"
readonly WORKSPACE="$GOPATH/src/github.com/cloudfoundry-incubator/eirini"

setupTestEnv(){
	mkdir -p $WORKSPACE
	cp -r eirini/* $WORKSPACE
}

runTests(){
	local is_failed=false

	for d in *; do
	  if [ -d "$d" ]; then
		  dirname=$(basename $d)
		  if [[ $EXCLUDE != *"$dirname"* ]]; then
		     pushd $d
		       ginkgo -succinct
		       if [ $? -ne 0 ]; then
			  is_failed=true
		       fi
		     popd
		  fi
	  fi
	done

	if $is_failed; then
	  exit 1
	fi
}

main(){
	setupTestEnv
        pushd $WORKSPACE
        runTests
}

main
