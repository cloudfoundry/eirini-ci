let Concourse = ../deps/concourse.dhall

let Creds = ../types/creds.dhall

let GKECreds = ../types/gke-creds.dhall

let IKSCreds = ../types/iks-creds.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(adminPassword : Text)
    → λ(creds : Creds)
    → let providerValuesFile =
            merge
              { GKECreds = λ(_ : GKECreds) → "gke-specific-grafana-values.yml"
              , IKSCreds = λ(_ : IKSCreds) → "iks-specific-grafana-values.yml"
              }
              creds

      let script =
            ''
            set -euo pipefail
            ${./functions/install-monitoring.sh as Text}

            install_monitoring \
              "${ciResources.name}" \
              "${adminPassword}" \
              "${providerValuesFile}"
            ''

      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "install-monitoring"
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
                        , Concourse.schemas.TaskInput::{ name = "ingress" }
                        , Concourse.schemas.TaskInput::{ name = "secret" }
                        ]
                  , run = ../helpers/bash-script-task.dhall script
                  }
            }
