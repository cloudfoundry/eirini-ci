let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

in    λ(reqs : ../deployment-requirements.dhall)
    → let getUAAReadyEvent =
            ../helpers/get-passed.dhall
              reqs.uaaReadyEvent
              [ "deploy-scf-uaa-${reqs.clusterName}" ]
      
      let deploySCF =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy-scf"
              , config = taskFile reqs.ciResources "deploy-scf"
              , params =
                  Some
                    ( toMap
                        { CLUSTER_NAME = reqs.clusterName
                        , VERSIONING_CLUSTER = reqs.worldName
                        , USE_CERT_MANAGER = reqs.useCertManager
                        }
                    )
              }
      
      let smokeTestEirini =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "smoke-eirini"
              , config = taskFile reqs.ciResources "eirini-smoke-tests"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }
      
      let blockNetworkAccess =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "block-network-access"
              , config = taskFile reqs.ciResources "block-network-access"
              , params =
                  Some
                    ( toMap
                        (   iksParams reqs.iksCreds
                          ⫽ { CLUSTER_NAME = reqs.clusterName }
                        )
                    )
              }
      
      let recheckEirini =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "recheck-eirini"
              , config = taskFile reqs.ciResources "eirini-smoke-tests"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }
      
      in  Concourse.schemas.Job::{
          , name = "deploy-scf-eirini-${reqs.clusterName}"
          , serial_groups = Some [ reqs.clusterName ]
          , plan =
              [ ../helpers/get-trigger.dhall reqs.eiriniReleaseResources
              , ../helpers/get.dhall reqs.ciResources
              , Concourse.helpers.getStep
                  Concourse.schemas.GetStep::{
                  , resource = reqs.clusterState
                  , get = Some "state"
                  }
              , getUAAReadyEvent
              , reqs.downloadKubeconfigTask
              , deploySCF
              , smokeTestEirini
              , blockNetworkAccess
              , recheckEirini
              ]
          }
