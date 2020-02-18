let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(clusterConfig : Concourse.Types.Resource)
      → let script =
              ''
              set -euo pipefail

              SMOKE_TEST_API_ENDPOINT=api.$(goml get --file ${clusterConfig.name}/environments/kube-clusters/cf4k8s/scf-config-values.yaml --prop system_domain)
              SMOKE_TEST_USERNAME=admin
              SMOKE_TEST_PASSWORD=$(goml get --file ${clusterConfig.name}/environments/kube-clusters/cf4k8s/scf-config-values.yaml --prop cf_admin_password)
              SMOKE_TEST_APPS_DOMAIN=$(goml get --file ${clusterConfig.name}/environments/kube-clusters/cf4k8s/scf-config-values.yaml --prop app_domains.0)
              export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_USERNAME SMOKE_TEST_API_ENDPOINT
              cd ${cfForK8s.name}/tests/smoke
              ginkgo -r
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "run smoke tests"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          , Concourse.schemas.TaskInput::{
                            , name = clusterConfig.name
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
