let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → let script =
              ''
              set -euo pipefail

              "${cfForK8s.name}"/hack/generate-values.sh "${clusterName}".ci-envs.eirini.cf-app.com > values-file/values.yml
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "generate values"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/ibmcloud"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "values-file"
                            }
                          ]
                  , run = ../helpers/bash-script-task.dhall script
              }

in  task
