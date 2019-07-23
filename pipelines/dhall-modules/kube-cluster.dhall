let Concourse = ./deps/dhall-concourse/types.dhall

let Defaults = ./deps/dhall-concourse/defaults.dhall

let Helpers = ./deps/dhall-concourse/helpers.dhall

let Prelude = ./deps/prelude.dhall

let keyText = Prelude.JSON.keyText

let ClusterRequirements =
      { ciResources :
          Concourse.Resource
      , clusterState :
          Concourse.Resource
      , clusterCreatedEvent :
          Concourse.Resource
      , clusterReadyEvent :
          Concourse.Resource
      , clusterName :
          Text
      , enableOPIStaging :
          Text
      }

let createClusterJob
    : ClusterRequirements → Concourse.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getClusterState =
              Helpers.getStep
              (   Defaults.GetStep
                ⫽ { resource =
                      reqs.clusterState
                  , trigger =
                      Some True
                  , passed =
                      Some [ "delete-cluster-${reqs.clusterName}" ]
                  }
              )

        let createCluster =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "create-kubernetes-cluster"
                  , config =
                      Concourse.TaskSpec.File
                      "ci-resources/tasks/create-cluster/task.yml"
                  , params =
                      Some
                      ( toMap
                        { IBMCLOUD_ACCOUNT =
                            "((ibmcloud-account))"
                        , IBMCLOUD_USER =
                            "((ibmcloud-user))"
                        , IBMCLOUD_PASSWORD =
                            "((ibmcloud-password))"
                        , CLUSTER_NAME =
                            reqs.clusterName
                        , WORKER_COUNT =
                            "((worker_count))"
                        }
                      )
                  }
              )

        let putClusterCreatedEvent =
              Helpers.putStep
              (   Defaults.PutStep
                ⫽ { resource =
                      reqs.clusterCreatedEvent
                  , params =
                      Some
                      [ keyText "file" "${reqs.clusterCreatedEvent.name}/number"
                      ]
                  }
              )

        in    Defaults.Job
            ⫽ { name =
                  "create-cluster-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , getClusterState
                  , createCluster
                  , putClusterCreatedEvent
                  ]
              }

let taskFile
    : Concourse.Resource → Text → Concourse.TaskSpec
    =   λ(ciResources : Concourse.Resource)
      → λ(taskName : Text)
      → Concourse.TaskSpec.File "${ciResources.name}/tasks/${taskName}/task.yml"

let deleteClusterJob
    : ClusterRequirements → Concourse.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.ciResources })

        let deleteCluster =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "delete-kubernetes-cluster"
                  , config =
                      taskFile reqs.ciResources "delete-cluster"
                  , params =
                      Some
                      ( toMap
                        { IBMCLOUD_ACCOUNT =
                            "((ibmcloud-account))"
                        , IBMCLOUD_USER =
                            "((ibmcloud-user))"
                        , IBMCLOUD_PASSWORD =
                            "((ibmcloud-password))"
                        , CLUSTER_NAME =
                            reqs.clusterName
                        }
                      )
                  }
              )

        let getClusterState =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.clusterState })

        let deleteValuesFile =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "delete-values-file"
                  , config =
                      taskFile reqs.ciResources "clean-up-cluster-config"
                  , params =
                      Some [ keyText "CLUSTER_NAME" reqs.clusterName ]
                  }
              )

        let putClusterState =
              Helpers.putStep
              (   Defaults.PutStep
                ⫽ { resource =
                      reqs.clusterState
                  , params =
                      Some
                      [ keyText "merge" "true"
                      , keyText "repository" "state-modified"
                      ]
                  }
              )

        in    Defaults.Job
            ⫽ { name =
                  "delete-cluster-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , deleteCluster
                  , getClusterState
                  , deleteValuesFile
                  , putClusterState
                  ]
              }

let prepareClusterJob
    : ClusterRequirements → Concourse.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getCreatedEvent =
              Helpers.getStep
              (   Defaults.GetStep
                ⫽ { resource =
                      reqs.clusterCreatedEvent
                  , trigger =
                      Some True
                  , passed =
                      Some [ "create-cluster-${reqs.clusterName}" ]
                  }
              )

        let getClusterState =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.clusterState })

        let createClusterConfig =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "create-cluster-config"
                  , config =
                      taskFile reqs.ciResources "cluster-config"
                  , params =
                      Some
                      ( toMap
                        { IBMCLOUD_ACCOUNT =
                            "((ibmcloud-account))"
                        , IBMCLOUD_USER =
                            "((ibmcloud-user))"
                        , IBMCLOUD_PASSWORD =
                            "((ibmcloud-password))"
                        , CLUSTER_NAME =
                            reqs.clusterName
                        , STORAGE_CLASS =
                            "((storage_class))"
                        , CLUSTER_ADMIN_PASSWORD =
                            "((cluster_admin_password))"
                        , UAA_ADMIN_CLIENT_SECRET =
                            "((uaa_admin_client_secret))"
                        , NATS_PASSWORD =
                            "((nats_password))"
                        , ENABLE_OPI_STAGING =
                            reqs.enableOPIStaging
                        , DIEGO_CELL_COUNT =
                            "((diego-cell-count))"
                        }
                      )
                  }
              )

        let putClusterState =
              Helpers.putStep
              (   Defaults.PutStep
                ⫽ { resource =
                      reqs.clusterState
                  , params =
                      Some
                      (toMap { repository = "state-modified", merge = "true" })
                  }
              )

        let provisionStorage =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "provision-storage"
                  , config =
                      taskFile reqs.ciResources "provision-storage"
                  , params =
                      Some
                      ( toMap
                        { IBMCLOUD_ACCOUNT =
                            "((ibmcloud-account))"
                        , IBMCLOUD_USER =
                            "((ibmcloud-user))"
                        , IBMCLOUD_PASSWORD =
                            "((ibmcloud-password))"
                        , CLUSTER_NAME =
                            reqs.clusterName
                        }
                      )
                  }
              )

        in    Defaults.Job
            ⫽ { name =
                  "prepare-cluster-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , getCreatedEvent
                  , getClusterState
                  , createClusterConfig
                  , putClusterState
                  , provisionStorage
                  ]
              }

let checkClusterReadinessJob
    : ClusterRequirements → Concourse.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Helpers.getStep
              (Defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getCreatedEvent =
              Helpers.getStep
              (   Defaults.GetStep
                ⫽ { resource =
                      reqs.clusterCreatedEvent
                  , trigger =
                      Some True
                  , passed =
                      Some [ "prepare-cluster-${reqs.clusterName}" ]
                  }
              )

        let getReadyEvent =
              Helpers.getStep
              (   Defaults.GetStep
                ⫽ { resource =
                      reqs.clusterReadyEvent
                  , params =
                      Some (toMap { bump = "major" })
                  }
              )

        let deploySmokeTestApp =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "deploy-smoke-test-app"
                  , config =
                      taskFile reqs.ciResources "deploy-app"
                  , params =
                      Some
                      ( toMap
                        { IBMCLOUD_ACCOUNT =
                            "((ibmcloud-account))"
                        , IBMCLOUD_USER =
                            "((ibmcloud-user))"
                        , IBMCLOUD_PASSWORD =
                            "((ibmcloud-password))"
                        , CLUSTER_NAME =
                            reqs.enableOPIStaging
                        }
                      )
                  }
              )

        let checkAppIsUp =
              Helpers.taskStep
              (   Defaults.TaskStep
                ⫽ { task =
                      "check-app-is-up"
                  , config =
                      taskFile reqs.ciResources "curl-app"
                  , attempts =
                      Some 50
                  }
              )

        let putReadyEvent =
              Helpers.putStep
              (   Defaults.PutStep
                ⫽ { resource =
                      reqs.clusterReadyEvent
                  , params =
                      Some
                      (toMap { file = "${reqs.clusterReadyEvent.name}/number" })
                  }
              )

        in    Defaults.Job
            ⫽ { name =
                  "check-cluster-readiness-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , getCreatedEvent
                  , getReadyEvent
                  , deploySmokeTestApp
                  , checkAppIsUp
                  , putReadyEvent
                  ]
              }

in    λ(reqs : ClusterRequirements)
    → [ deleteClusterJob reqs
      , createClusterJob reqs
      , prepareClusterJob reqs
      , checkClusterReadinessJob reqs
      ]
