let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(reqs : ../types/deployment-requirements.dhall)
    → let deployUAA =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy-uaa"
              , input_mapping =
                  Some (toMap { eirini-release = reqs.uaaResources.name })
              , config = taskFile reqs.ciResources "deploy-uaa"
              , params =
                  Some
                    ( toMap
                        { CLUSTER_NAME = reqs.clusterName
                        , USE_CERT_MANAGER = reqs.useCertManager
                        }
                    )
              }

      let waitForUAA =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "wait-for-uaa"
              , config = taskFile reqs.ciResources "waiting-for-uaa"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }

      let getUaaResorcesStep =
                  if reqs.triggerDeployUaaWhenChanged

            then  ../helpers/get-trigger.dhall reqs.uaaResources

            else  ../helpers/get.dhall reqs.uaaResources

      in  Concourse.schemas.Job::{
          , name = "deploy-scf-uaa-${reqs.clusterName}"
          , serial_groups = Some [ reqs.clusterName ]
          , public = Some True
          , plan =
                Optional/fold
                  Concourse.Types.Resource
                  reqs.clusterReadyEvent
                  (List Concourse.Types.Step)
                  (   λ(r : Concourse.Types.Resource)
                    → [ ../helpers/get-trigger-passed.dhall
                          r
                          [ "prepare-cluster-${reqs.clusterName}" ]
                      ]
                  )
                  ([] : List Concourse.Types.Step)
              # [ getUaaResorcesStep
                , ../helpers/get.dhall reqs.ciResources
                , Concourse.helpers.getStep
                    Concourse.schemas.GetStep::{
                    , resource = reqs.clusterState
                    , get = Some "state"
                    }
                , ../tasks/download-kubeconfig.dhall
                    reqs.ciResources
                    reqs.clusterName
                    reqs.creds
                , deployUAA
                , waitForUAA
                , ../helpers/emit-event.dhall reqs.uaaReadyEvent
                ]
          }
