let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → let script =
              ''
              set -euo pipefail

              "${cfForK8s.name}"/hack/generate-values.sh "${clusterName}".ci-envs.eirini.cf-app.com > default-values-file/values.yml
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "generate default values"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-for-k8s-ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "default-values-file"
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
