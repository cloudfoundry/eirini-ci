let Concourse = ../deps/concourse.dhall

let iksParams = ../helpers/iks-params.dhall

in    λ(clusterName : Text)
    → λ(iksCreds : ../types/iks-creds.dhall)
    → λ(ciResources : Concourse.Types.Resource)
    → let script =
            ''
            ${../tasks/functions/copy-iks-cert-secret.sh as Text}
            source ${ciResources.name}/scripts/ibmcloud-functions

            copy_secret ${clusterName}
            ''

      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "set-up-iks-grafana-secret"
            , params =
                Some
                  (toMap (iksParams iksCreds ⫽ { CLUSTER_NAME = clusterName }))
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
                        ]
                  , outputs =
                      Some [ Concourse.schemas.TaskOutput::{ name = "secret" } ]
                  , run = ../helpers/bash-script-task.dhall script
                  }
            }
