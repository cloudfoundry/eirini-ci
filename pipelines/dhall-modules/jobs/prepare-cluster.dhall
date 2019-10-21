let ClusterRequirements = ../cluster-requirements.dhall

let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

let prepareClusterJob
    : ClusterRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let getCreatedEvent =
              ../helpers/get-trigger-passed.dhall
                reqs.clusterCreatedEvent
                [ "create-cluster-${reqs.clusterName}" ]
        
        let createClusterParams =
              { CLUSTER_NAME = reqs.clusterName
              , STORAGE_CLASS = reqs.storageClass
              , CLUSTER_ADMIN_PASSWORD = reqs.clusterAdminPassword
              , UAA_ADMIN_CLIENT_SECRET = reqs.uaaAdminClientSecret
              , NATS_PASSWORD = reqs.natsPassword
              , ENABLE_OPI_STAGING = reqs.enableOPIStaging
              , DIEGO_CELL_COUNT = reqs.diegoCellCount
              }
        
        let cloudCreds = iksParams reqs.iksCreds
        
        let createClusterConfig =
              Concourse.helpers.taskStep
                (   Concourse.defaults.TaskStep
                  ⫽ { task = "create-cluster-config"
                    , config = taskFile reqs.ciResources "cluster-config"
                    , params = Some (toMap (cloudCreds ⫽ createClusterParams))
                    }
                )
        
        let putClusterState =
              Concourse.helpers.putStep
                (   Concourse.defaults.PutStep
                  ⫽ { resource = reqs.clusterState
                    , params =
                        Some
                          ( toMap
                              { repository =
                                  Prelude.JSON.string "state-modified"
                              , merge = Prelude.JSON.bool True
                              }
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
                              (cloudCreds ⫽ { CLUSTER_NAME = reqs.clusterName })
                          )
                    }
                )
        
        let putClusterReadyEvent =
              Concourse.helpers.putStep
                Concourse.schemas.PutStep::{
                , resource = reqs.clusterReadyEvent
                , params = Some (toMap { bump = Prelude.JSON.string "major" })
                }
        
        in    Concourse.defaults.Job
            ⫽ { name = "prepare-cluster-${reqs.clusterName}"
              , plan =
                  [ ../helpers/get.dhall reqs.ciResources
                  , getCreatedEvent
                  , ../helpers/get.dhall reqs.clusterState
                  , createClusterConfig
                  , putClusterState
                  , provisionStorage
                  , putClusterReadyEvent
                  ]
              }

in  prepareClusterJob
