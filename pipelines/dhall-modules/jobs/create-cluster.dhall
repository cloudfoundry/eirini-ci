let Concourse = ../deps/concourse.dhall

let ClusterRequirements = ../types/cluster-requirements.dhall

let taskFile = ../helpers/task-file.dhall

let createClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getClusterState =
              ../helpers/get-trigger-passed.dhall
                reqs.clusterState
                [ "delete-cluster-${reqs.clusterName}" ]
        
        let taskName =
              merge
                { IKSCreds = λ(_ : ../types/iks-creds.dhall) → "create-cluster"
                , GKECreds =
                    λ(_ : ../types/gke-creds.dhall) → "gcp-create-cluster"
                }
                reqs.creds
        
        let createCluster =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "create-kubernetes-cluster"
                    , config = taskFile reqs.ciResources taskName
                    , params =
                        Some
                          (   toMap
                                { CLUSTER_NAME = reqs.clusterName
                                , WORKER_COUNT = Natural/show reqs.workerCount
                                }
                            # ../helpers/get-creds.dhall reqs.creds
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
