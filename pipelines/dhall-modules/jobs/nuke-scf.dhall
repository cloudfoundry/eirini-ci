let Concourse = ../deps/concourse.dhall

in    λ(reqs : ../types/deployment-requirements.dhall)
    → let upstream = [ "run-core-cats-${reqs.clusterName}" ]

      let lockSteps = ./steps/lock-steps.dhall reqs.lockResource upstream

      let downloadKubeConfig =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let nuke =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "nuke"
              , config = ../helpers/task-file.dhall reqs.ciResources "nuke-scf"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }

      let waitForDeletion =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "wait-for-deleteion"
              , config =
                  ../helpers/task-file.dhall
                    reqs.ciResources
                    "wait-for-deletion"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }

      let triggerOnEiriniRelease =
            ../helpers/get-trigger-passed.dhall reqs.eiriniReleaseRepo upstream

      in  Concourse.schemas.Job::{
          , name = "nuke-scf"
          , plan =
                [ ../helpers/get.dhall reqs.ciResources ]
              # lockSteps
              # [ triggerOnEiriniRelease
                , downloadKubeConfig
                , nuke
                , waitForDeletion
                ]
          }
