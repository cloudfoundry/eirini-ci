let Concourse = ../deps/concourse.dhall

let task =
        λ(ciResources : Concourse.Types.Resource)
      → λ(clusterConfig : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → let script =
              ''
              set -euo pipefail
              ${./functions/deploy-cf-for-k8s.sh as Text}

              deploy-cf ${clusterName}
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy CF for K8s"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-for-k8s-ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{ name = "patched-cf-for-k8s" }
                          , Concourse.schemas.TaskInput::{
                            , name = ciResources.name
                            }
                          , Concourse.schemas.TaskInput::{
                            , name = clusterConfig.name
                            }
                          , Concourse.schemas.TaskInput::{ name = "kube" }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
