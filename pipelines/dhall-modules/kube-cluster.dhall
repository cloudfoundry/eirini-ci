let Concourse = ./deps/concourse.dhall

let Prelude = ./deps/prelude.dhall

let JSON = ./deps/prelude-json.dhall

let keyText = Prelude.JSON.keyText

let keyValue = Prelude.JSON.keyValue

let jsonMap = Prelude.JSON.keyValue JSON

let TextTextPair = { mapKey : Text, mapValue : Text }

let TextJSONPair = { mapKey : Text, mapValue : JSON }

let textPairToJSON
    : TextTextPair → TextJSONPair
    = λ(p : TextTextPair) → p ⫽ { mapValue = Prelude.JSON.string p.mapValue }

let textMapToJSON
    : List TextTextPair → List TextJSONPair
    = Prelude.List.map TextTextPair TextJSONPair textPairToJSON

let ClusterRequirements =
      { ciResources : Concourse.Types.Resource
      , clusterState : Concourse.Types.Resource
      , clusterCreatedEvent : Concourse.Types.Resource
      , clusterReadyEvent : Concourse.Types.Resource
      , clusterName : Text
      , enableOPIStaging : Text
      }

let createClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getClusterState =
              Concourse.helpers.getStep
                (   Concourse.defaults.GetStep
                  ⫽ { resource = reqs.clusterState
                    , trigger = Some True
                    , passed = Some [ "delete-cluster-${reqs.clusterName}" ]
                    }
                )

        let createCluster =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "create-kubernetes-cluster"
                    , config =
                        Concourse.Types.TaskSpec.File
                          "ci-resources/tasks/create-cluster/task.yml"
                    , params =
                        Some
                        ( toMap
                            { IBMCLOUD_ACCOUNT = "((ibmcloud-account))"
                            , IBMCLOUD_USER = "((ibmcloud-user))"
                            , IBMCLOUD_PASSWORD = "((ibmcloud-password))"
                            , CLUSTER_NAME = reqs.clusterName
                            , WORKER_COUNT = "((worker_count))"
                            }
                        )
                    }
                )

        let putClusterCreatedEvent =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterCreatedEvent
                    , params =
                        Some
                        [ keyValue JSON "bump" (Prelude.JSON.string "major") ]
                    }
                )

        in    Concourse.defaults.Job
            ⫽ { name = "create-cluster-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , getClusterState
                  , createCluster
                  , putClusterCreatedEvent
                  ]
              }

let taskFile
    : Concourse.Types.Resource → Text → Concourse.Types.TaskSpec
    =   λ(ciResources : Concourse.Types.Resource)
      → λ(taskName : Text)
      → Concourse.Types.TaskSpec.File
          "${ciResources.name}/tasks/${taskName}/task.yml"

let deleteClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.ciResources })

        let deleteCluster =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "delete-kubernetes-cluster"
                    , config = taskFile reqs.ciResources "delete-cluster"
                    , params =
                        Some
                        ( toMap
                            { IBMCLOUD_ACCOUNT = "((ibmcloud-account))"
                            , IBMCLOUD_USER = "((ibmcloud-user))"
                            , IBMCLOUD_PASSWORD = "((ibmcloud-password))"
                            , CLUSTER_NAME = reqs.clusterName
                            }
                        )
                    }
                )

        let getClusterState =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.clusterState })

        let deleteValuesFile =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "delete-values-file"
                    , config =
                        taskFile reqs.ciResources "clean-up-cluster-config"
                    , params = Some [ keyText "CLUSTER_NAME" reqs.clusterName ]
                    }
                )

        let putClusterState =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterState
                    , params =
                        Some
                        [ jsonMap "merge" (Prelude.JSON.string "true")
                        , jsonMap
                            "repository"
                            (Prelude.JSON.string "state-modified")
                        ]
                    }
                )

        in    Concourse.defaults.Job
            ⫽ { name = "delete-cluster-${reqs.clusterName}"
              , plan =
                  [ getCIResources
                  , deleteCluster
                  , getClusterState
                  , deleteValuesFile
                  , putClusterState
                  ]
              }

let prepareClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getCreatedEvent =
              Concourse.helpers.getStep
                (   Concourse.defaults.GetStep
                  ⫽ { resource = reqs.clusterCreatedEvent
                    , trigger = Some True
                    , passed = Some [ "create-cluster-${reqs.clusterName}" ]
                    }
                )

        let getClusterState =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.clusterState })

        let createClusterConfig =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "create-cluster-config"
                    , config = taskFile reqs.ciResources "cluster-config"
                    , params =
                        Some
                        ( toMap
                            { IBMCLOUD_ACCOUNT = "((ibmcloud-account))"
                            , IBMCLOUD_USER = "((ibmcloud-user))"
                            , IBMCLOUD_PASSWORD = "((ibmcloud-password))"
                            , CLUSTER_NAME = reqs.clusterName
                            , STORAGE_CLASS = "((storage_class))"
                            , CLUSTER_ADMIN_PASSWORD =
                                "((cluster_admin_password))"
                            , UAA_ADMIN_CLIENT_SECRET =
                                "((uaa_admin_client_secret))"
                            , NATS_PASSWORD = "((nats_password))"
                            , ENABLE_OPI_STAGING = reqs.enableOPIStaging
                            , DIEGO_CELL_COUNT = "((diego-cell-count))"
                            }
                        )
                    }
                )

        let putClusterState =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterState
                    , params =
                        Some
                        ( textMapToJSON
                            ( toMap
                                { repository = "state-modified"
                                , merge = "true"
                                }
                            )
                        )
                    }
                )

        let provisionStorage =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "provision-storage"
                    , config = taskFile reqs.ciResources "provision-storage"
                    , params =
                        Some
                        ( toMap
                            { IBMCLOUD_ACCOUNT = "((ibmcloud-account))"
                            , IBMCLOUD_USER = "((ibmcloud-user))"
                            , IBMCLOUD_PASSWORD = "((ibmcloud-password))"
                            , CLUSTER_NAME = reqs.clusterName
                            }
                        )
                    }
                )

        in    Concourse.defaults.Job
            ⫽ { name = "prepare-cluster-${reqs.clusterName}"
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
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getCIResources =
              Concourse.helpers.getStep
                (Concourse.defaults.GetStep ⫽ { resource = reqs.ciResources })

        let getCreatedEvent =
              Concourse.helpers.getStep
                (   Concourse.defaults.GetStep
                  ⫽ { resource = reqs.clusterCreatedEvent
                    , trigger = Some True
                    , passed = Some [ "prepare-cluster-${reqs.clusterName}" ]
                    }
                )

        let getReadyEvent =
              Concourse.helpers.getStep
                (   Concourse.defaults.GetStep
                  ⫽ { resource = reqs.clusterReadyEvent
                    , params = Some (textMapToJSON (toMap { bump = "major" }))
                    }
                )

        let deploySmokeTestApp =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "deploy-smoke-test-app"
                    , config = taskFile reqs.ciResources "deploy-app"
                    , params =
                        Some
                        ( toMap
                            { IBMCLOUD_ACCOUNT = "((ibmcloud-account))"
                            , IBMCLOUD_USER = "((ibmcloud-user))"
                            , IBMCLOUD_PASSWORD = "((ibmcloud-password))"
                            , CLUSTER_NAME = reqs.enableOPIStaging
                            }
                        )
                    }
                )

        let checkAppIsUp =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "check-app-is-up"
                    , config = taskFile reqs.ciResources "curl-app"
                    , attempts = Some 50
                    }
                )

        let putReadyEvent =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterReadyEvent
                    , params =
                        Some
                        ( textMapToJSON
                            ( toMap
                                { file = "${reqs.clusterReadyEvent.name}/number"
                                }
                            )
                        )
                    }
                )

        in    Concourse.defaults.Job
            ⫽ { name = "check-cluster-readiness-${reqs.clusterName}"
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
