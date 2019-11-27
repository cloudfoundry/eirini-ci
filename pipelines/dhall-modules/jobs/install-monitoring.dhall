let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

let GKECreds = ../types/gke-creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let Requirements =
      { creds : ../types/creds.dhall
      , privateRepo : Concourse.Types.Resource
      , ciResources : Concourse.Types.Resource
      , upstreamEvent : Concourse.Types.Resource
      , clusterName : Text
      , grafanaAdminPassword : Text
      }

in    λ(reqs : Requirements)
    → let ingressEndpointTask =
            merge
              { GKECreds =
                    λ(_ : GKECreds)
                  → ../tasks/get-gke-ingress-endpoint.dhall reqs.clusterName
              , IKSCreds =
                    λ(iksCreds : IKSCreds)
                  → ../tasks/get-iks-ingress-endpoint.dhall
                      reqs.ciResources
                      reqs.clusterName
                      iksCreds
              }
              reqs.creds

      let storageClassName =
            merge
              { GKECreds = λ(_ : GKECreds) → "standard"
              , IKSCreds = λ(_ : IKSCreds) → "ibmc-block-gold"
              }
              reqs.creds

      let script =
            ''
            set -euo pipefail

            ${../tasks/functions/install-monitoring.sh as Text}
            install_monitoring \
              "${reqs.privateRepo.name}" \
              "${reqs.grafanaAdminPassword}" \
              "https://grafana.$(cat ingress/endpoint)" \
              "${storageClassName}"
            ''

      let installTask =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "install-monitoring"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        Some
                          Concourse.schemas.ImageResource::{
                          , type = "docker-image"
                          , source =
                              Some
                                ( toMap
                                    { repository = JSON.string "eirini/ibmcloud"
                                    }
                                )
                          }
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = reqs.privateRepo.name
                            }
                          , Concourse.schemas.TaskInput::{ name = "kube" }
                          , Concourse.schemas.TaskInput::{ name = "ingress" }
                          ]
                    , run =
                        Concourse.schemas.TaskRunConfig::{
                        , path = "bash"
                        , args = Some [ "-c", script ]
                        }
                    }
              }

      let downloadKubeConfig =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let triggerOnClusterReady =
            Concourse.helpers.getStep
              Concourse.schemas.GetStep::{
              , resource = reqs.upstreamEvent
              , trigger = Some True
              , passed = Some [ "prepare-cluster-${reqs.clusterName}" ]
              }

      in  Concourse.schemas.Job::{
          , name = "install-monitoring-${reqs.clusterName}"
          , plan =
              [ ../helpers/get.dhall reqs.privateRepo
              , ../helpers/get.dhall reqs.ciResources
              , triggerOnClusterReady
              , downloadKubeConfig
              , ingressEndpointTask
              , installTask
              ]
          }
