let Concourse = ../deps/concourse.dhall

let task =
        λ(clusterName : Text)
      → λ(clusterConfig : Concourse.Types.Resource)
      → λ(outputDirName : Text)
      → let script =
              ''
              set -euo pipefail

              goml get --file ${clusterConfig.name}/environments/kube-clusters/${clusterName}/default-values.yml --prop system_domain > ${outputDirName}/smoke-test-api-endpoint
              goml get --file ${clusterConfig.name}/environments/kube-clusters/${clusterName}/default-values.yml --prop cf_admin_password > ${outputDirName}/smoke-test-password
              goml get --file ${clusterConfig.name}/environments/kube-clusters/${clusterName}/default-values.yml --prop app_domains.0 > ${outputDirName}/smoke-test-apps-domain
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "get-smoke-tests-variables"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = clusterConfig.name
                            }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = outputDirName
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
