#!/bin/bash
set -euo pipefail

SMOKE_TEST_API_ENDPOINT=api.$(cat smoke-tests-env-vars/smoke-test-api-endpoint)
SMOKE_TEST_PASSWORD=$(cat smoke-tests-env-vars/smoke-test-password)
SMOKE_TEST_APPS_DOMAIN=$(cat smoke-tests-env-vars/smoke-test-apps-domain)

export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_API_ENDPOINT

tar xzvf cf-for-k8s-github-release/source.tar.gz -C .
sha="$(<cf-for-k8s-github-release/commit_sha)"
src_folder="cloudfoundry-cf-for-k8s-${sha:0:7}"
cd "$src_folder/tests/smoke"
ginkgo -v -r
