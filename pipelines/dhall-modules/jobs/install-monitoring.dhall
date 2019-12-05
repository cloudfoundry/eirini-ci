let Concourse = ../deps/concourse.dhall

let GKECreds = ../types/gke-creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let Requirements =
      { creds : ../types/creds.dhall
      , ciResources : Concourse.Types.Resource
      , upstreamEvent : Concourse.Types.Resource
      , clusterName : Text
      , grafanaAdminPassword : Text
      }

in    λ(reqs : Requirements)
    → let triggerOnClusterReady =
            Concourse.helpers.getStep
              Concourse.schemas.GetStep::{
              , resource = reqs.upstreamEvent
              , trigger = Some True
              , passed = Some [ "prepare-cluster-${reqs.clusterName}" ]
              }

      let downloadKubeConfigTask =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let ingressEndpointTask =
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

      let grafanaSecretSetupTask =
            merge
              { GKECreds =
                  λ(_ : GKECreds) → ../tasks/set-up-gke-grafana-secret.dhall
              , IKSCreds =
                    λ(iksCreds : IKSCreds)
                  → ../tasks/set-up-iks-grafana-secret.dhall
                      reqs.clusterName
                      iksCreds
                      reqs.ciResources
              }
              reqs.creds

      let installMonitoringTask =
            ../tasks/install-monitoring.dhall
              reqs.ciResources
              reqs.grafanaAdminPassword
              reqs.creds

      in  Concourse.schemas.Job::{
          , name = "install-monitoring-${reqs.clusterName}"
          , plan =
              [ ../helpers/get.dhall reqs.ciResources
              , triggerOnClusterReady
              , downloadKubeConfigTask
              , ingressEndpointTask
              , grafanaSecretSetupTask
              , installMonitoringTask
              ]
          }
