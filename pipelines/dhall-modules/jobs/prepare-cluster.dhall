let ClusterRequirements = ../types/cluster-requirements.dhall

let PrepRequirements = ../types/cluster-prep-requirements.dhall

let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

let prepareClusterJob
    : ClusterRequirements → PrepRequirements → Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → λ(prepReqs : PrepRequirements)
      → let getCreatedEvent =
              ../helpers/get-trigger-passed.dhall
                reqs.clusterCreatedEvent
                [ "create-cluster-${reqs.clusterName}" ]
        
        let createClusterParams =
              { CLUSTER_NAME = reqs.clusterName
              , STORAGE_CLASS = reqs.storageClass
              , CLUSTER_ADMIN_PASSWORD = prepReqs.clusterAdminPassword
              , UAA_ADMIN_CLIENT_SECRET = prepReqs.uaaAdminClientSecret
              , NATS_PASSWORD = prepReqs.natsPassword
              , ENABLE_OPI_STAGING = reqs.enableOPIStaging
              , DIEGO_CELL_COUNT = prepReqs.diegoCellCount
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
        
        let downloadKubeConfig =
              ../tasks/download-kubeconfig-iks.dhall
                reqs.iksCreds
                reqs.ciResources
                reqs.clusterName
        
        let getIKSIngressEndpoint =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "get-iks-ingress-endpoint"
                , config = taskFile reqs.ciResources "get-iks-ingress-endpoint"
                , params =
                    Some
                      (toMap (cloudCreds ⫽ { CLUSTER_NAME = reqs.clusterName }))
                }
        
        in    Concourse.defaults.Job
            ⫽ { name = "prepare-cluster-${reqs.clusterName}"
              , plan =
                  [ ../helpers/get.dhall reqs.ciResources
                  , getCreatedEvent
                  , ../helpers/get.dhall reqs.clusterState
                  , downloadKubeConfig
                  , getIKSIngressEndpoint
                  , createClusterConfig
                  , putClusterState
                  , provisionStorage
                  , ../helpers/emit-event.dhall reqs.clusterReadyEvent
                  ]
              }

in  prepareClusterJob
