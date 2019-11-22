let ClusterRequirements = ../types/cluster-requirements.dhall

let PrepRequirements = ../types/cluster-prep-requirements.dhall

let defaults = (../deps/concourse.dhall).defaults

let Types = (../deps/concourse.dhall).Types

let helpers = (../deps/concourse.dhall).helpers

let Prelude = ../deps/prelude.dhall

let prepareClusterJob
    : ClusterRequirements → PrepRequirements → Types.Job
    =   λ(reqs : ClusterRequirements)
      → λ(prepReqs : PrepRequirements)
      → let getCreatedEvent =
              ../helpers/get-trigger-passed.dhall
                reqs.clusterCreatedEvent
                [ "create-cluster-${reqs.clusterName}" ]

        let configParams =
              { CLUSTER_NAME = reqs.clusterName
              , STORAGE_CLASS = reqs.storageClass
              , CLUSTER_ADMIN_PASSWORD = prepReqs.clusterAdminPassword
              , UAA_ADMIN_CLIENT_SECRET = prepReqs.uaaAdminClientSecret
              , NATS_PASSWORD = prepReqs.natsPassword
              , ENABLE_OPI_STAGING = reqs.enableOPIStaging
              }

        let putClusterState =
              helpers.putStep
                (   defaults.PutStep
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

        let cloudSpecificSteps =
              merge
                { IKSCreds =
                    ./steps/iks-specific-prepare-steps.dhall reqs configParams
                , GKECreds =
                    ./steps/gke-specific-prepare-steps.dhall reqs configParams
                }
                reqs.creds

        let downloadKubeConfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        in    defaults.Job
            ⫽ { name = "prepare-cluster-${reqs.clusterName}"
              , plan =
                    [ ../helpers/get.dhall reqs.ciResources
                    , getCreatedEvent
                    , ../helpers/get.dhall reqs.clusterState
                    , downloadKubeConfig
                    ]
                  # cloudSpecificSteps
                  # [ ../helpers/emit-event.dhall reqs.clusterReadyEvent
                    , putClusterState
                    ]
              }

in  prepareClusterJob
