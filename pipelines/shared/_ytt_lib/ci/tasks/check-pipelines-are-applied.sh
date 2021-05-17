#!/bin/bash

set -euxo pipefail

wget -q -O /usr/bin/fly 'https://jetson.eirini.cf-app.com/api/v1/cli?arch=amd64&platform=linux'
chmod +x /usr/bin/fly

export PATH=$PWD/ci-resources/pipelines/fakes:$PATH

fly -t eirini login -c https://jetson.eirini.cf-app.com -u $USERNAME -p $PASSWORD

cd ci-resources/pipeline-checker
../pipelines/set-all-pipelines | go run main.go
