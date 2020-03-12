let Concourse = ../deps/concourse.dhall

let IKSCreds = ../types/iks-creds.dhall

let iksParams = ../helpers/iks-params.dhall

in    λ(clusterName : Text)
    → λ(ciResources : Concourse.Types.Resource)
    → λ(iksCreds : IKSCreds)
    → let script =
            ''
            set -euo pipefail

            ${./functions/bump-iks-cluster-k8s-version.sh as Text}
            source ${ciResources.name}/scripts/ibmcloud-functions

            ibmcloud-login
            bump-version ${clusterName}
            ''

      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "bump-k8s-version"
            , params = Some (toMap (iksParams iksCreds))
            , config =
                Concourse.Types.TaskSpec.Config
                  Concourse.schemas.TaskConfig::{
                  , image_resource =
                      ../helpers/image-resource.dhall "eirini/ibmcloud"
                  , run = ../helpers/bash-script-task.dhall script
                  , inputs =
                      Some
                        [ Concourse.schemas.TaskInput::{
                          , name = ciResources.name
                          }
                        ]
                  }
            }
