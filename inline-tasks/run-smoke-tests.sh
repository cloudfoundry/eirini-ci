#!/bin/bash
set -euo pipefail

SMOKE_TEST_API_ENDPOINT=api.$(cat smoke-tests-env-vars/smoke-test-api-endpoint)
SMOKE_TEST_PASSWORD=$(cat smoke-tests-env-vars/smoke-test-password)
SMOKE_TEST_APPS_DOMAIN=$(cat smoke-tests-env-vars/smoke-test-apps-domain)

export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_API_ENDPOINT

src_folder="cf-for-k8s-prs"
cd "$src_folder/tests/smoke"
ginkgo -v -r
