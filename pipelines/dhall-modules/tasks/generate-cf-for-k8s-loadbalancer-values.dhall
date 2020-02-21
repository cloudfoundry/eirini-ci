let Concourse = ../deps/concourse.dhall

let task =
        λ(ciResources : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → λ(creds : ../types/creds.dhall)
      → let script =
              ''
               set -euo pipefail
               ${./functions/generate-cf-for-k8s-loadbalancer-values.sh as Text}

               generate-values ${clusterName}
              ''

        let cloudParams = ../helpers/get-creds.dhall creds

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "generate loadbalancer values"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/gcloud"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = ciResources.name
                            }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "loadbalancer-values-file"
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              , params = Some cloudParams
              }

in  task
