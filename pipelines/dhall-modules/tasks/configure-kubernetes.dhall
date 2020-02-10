let Concourse = ../deps/concourse.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → let script =
            ''
            ${./functions/configure-kubernetes.sh as Text}
            ''

      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "configure-kubernetes"
            , config =
                Concourse.Types.TaskSpec.Config
                  Concourse.schemas.TaskConfig::{
                  , image_resource =
                      ../helpers/image-resource.dhall "eirini/ibmcloud"
                  , inputs =
                      Some
                        [ Concourse.schemas.TaskInput::{
                          , name = ciResources.name
                          }
                        , Concourse.schemas.TaskInput::{ name = "kube" }
                        ]
                  , run = ../helpers/bash-script-task.dhall script
                  }
            }
