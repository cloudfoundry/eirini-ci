let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let ClusterRequirements = ../cluster-requirements.dhall

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
        
        let putClusterCreatedEvent =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterCreatedEvent
                    , params =
                        Some (toMap { bump = Prelude.JSON.string "major" })
                    }
                )
        
        in    Concourse.defaults.Job
            ⫽ { name = "create-cluster-${reqs.clusterName}"
              , plan =
                  [ ../helpers/get.dhall reqs.ciResources
                  , getClusterState
                  , createCluster
                  , putClusterCreatedEvent
                  ]
              }

in  createClusterJob
