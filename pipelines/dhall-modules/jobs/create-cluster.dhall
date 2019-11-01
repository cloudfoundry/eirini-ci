let Concourse = ../deps/concourse.dhall

let ClusterRequirements = ../types/cluster-requirements.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

let createClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getClusterState =
              ../helpers/get-trigger-passed.dhall
                reqs.clusterState
                [ "delete-cluster-${reqs.clusterName}" ]
        
        let createCluster =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "create-kubernetes-cluster"
                    , config = taskFile reqs.ciResources "create-cluster"
                    , params =
                        Some
                          ( toMap
                              (   iksParams reqs.iksCreds
                                ⫽ { CLUSTER_NAME = reqs.clusterName
                                  , WORKER_COUNT = Natural/show reqs.workerCount
                                  }
                              )
                          )
                    }
                )
        
        in    Concourse.defaults.Job
            ⫽ { name = "create-cluster-${reqs.clusterName}"
              , plan =
                  [ ../helpers/get.dhall reqs.ciResources
                  , getClusterState
                  , createCluster
                  , ../helpers/emit-event.dhall reqs.clusterCreatedEvent
                  ]
              , on_failure = reqs.failureNotification
              }

in  createClusterJob
