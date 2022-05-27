#!/bin/bash
set -euo pipefail

SMOKE_TEST_API_ENDPOINT=api.$(cat smoke-tests-env-vars/smoke-test-api-endpoint)
SMOKE_TEST_PASSWORD=$(cat smoke-tests-env-vars/smoke-test-password)
SMOKE_TEST_APPS_DOMAIN=$(cat smoke-tests-env-vars/smoke-test-apps-domain)

export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_API_ENDPOINT

src_folder="cf-for-k8s"
cd "$src_folder/tests/smoke"

# We are explicitly using ginkgo v1 here, since this is cf-for-k8s, not one of our repos
go run github.com/onsi/ginkgo/ginkgo@latest -v -r
