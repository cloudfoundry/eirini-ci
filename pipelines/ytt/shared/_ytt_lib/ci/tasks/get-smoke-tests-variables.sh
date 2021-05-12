#!/bin/bash
set -euo pipefail

goml get --file "cluster-state/environments/kube-clusters/$CLUSTER_NAME/default-values.yml" --prop system_domain >smoke-tests-env-vars/smoke-test-api-endpoint
goml get --file "cluster-state/environments/kube-clusters/$CLUSTER_NAME/default-values.yml" --prop cf_admin_password >smoke-tests-env-vars/smoke-test-password
goml get --file "cluster-state/environments/kube-clusters/$CLUSTER_NAME/default-values.yml" --prop app_domains.0 >smoke-tests-env-vars/smoke-test-apps-domain
