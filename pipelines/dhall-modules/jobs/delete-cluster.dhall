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
                    , params = Some
                        (   toMap
                              { CLUSTER_NAME = reqs.clusterName
                              , WORKER_COUNT = Natural/show reqs.workerCount
                              , IS_CF4K8S_DEPLOYMENT =
                                  if reqs.isCf4k8s then "true" else "false"
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
                    , params = Some
                        ( toMap
                            { merge = Prelude.JSON.bool True
                            , repository = Prelude.JSON.string "state-modified"
                            }
                        )
                    }
                )

        let deleteTimer =
                    if reqs.enableDeleteTimer

              then  [ ../helpers/get-trigger.dhall deleteTimer ]

              else  [] : List Concourse.Types.Step

        let downloadKubeConfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        in    Concourse.defaults.Job
            ⫽ { name = "delete-cluster-${reqs.clusterName}"
              , plan =
                    deleteTimer
                  # [ ../helpers/get.dhall reqs.ciResources
                    , downloadKubeConfig
                    , purgeDeploymentsTask
                    , deleteCluster
                    , ../helpers/get.dhall reqs.clusterState
                    , deleteValuesFile
                    , putClusterState
                    ]
              }

in  deleteClusterJob
