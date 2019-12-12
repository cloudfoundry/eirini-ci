let ClusterRequirements = ../types/cluster-requirements.dhall

let Prelude = ../deps/prelude.dhall

let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

let deleteTimer = ../resources/delete-timer.dhall

let deleteClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let taskName =
              merge
                { IKSCreds = λ(_ : ../types/iks-creds.dhall) → "delete-cluster"
                , GKECreds =
                    λ(_ : ../types/gke-creds.dhall) → "gcp-delete-cluster"
                }
                reqs.creds

        let purgeDeploymentsTask =
              ../tasks/purge-deployments.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let deleteCluster =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "delete-kubernetes-cluster"
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

        let deleteValuesFile =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "delete-values-file"
                    , config =
                        taskFile reqs.ciResources "clean-up-cluster-config"
                    , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
                    }
                )

        let putClusterState =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterState
                    , params =
                        Some
                          ( toMap
                              { merge = Prelude.JSON.bool True
                              , repository =
                                  Prelude.JSON.string "state-modified"
                              }
                          )
                    }
                )

        in    Concourse.defaults.Job
            ⫽ { name = "delete-cluster-${reqs.clusterName}"
              , plan =
                  [ ../helpers/get-trigger.dhall deleteTimer
                  , ../helpers/get.dhall reqs.ciResources
                  , purgeDeploymentsTask
                  , deleteCluster
                  , ../helpers/get.dhall reqs.clusterState
                  , deleteValuesFile
                  , putClusterState
                  ]
              }

in  deleteClusterJob
