let Concourse = ../deps/concourse.dhall

let KubeCFDeploymentRequirements = ../types/kubecf-deployment-requirements.dhall

let IKSCreds = ../types/iks-creds.dhall

let GKECreds = ../types/gke-creds.dhall

let Prelude = ../deps/prelude.dhall

let helpers = (../deps/concourse.dhall).helpers

let defaults = (../deps/concourse.dhall).defaults

in    λ(reqs : KubeCFDeploymentRequirements)
    → let generateValuesStep =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "generate-values"
              , config =
                  ../helpers/task-file.dhall
                    reqs.ciResources
                    "kubecf/generate-values"
              , params =
                  Some
                    ( toMap
                        { CLUSTER_NAME = reqs.clusterName
                        , STORAGE_CLASS = reqs.storageClass
                        }
                    )
              }

      let downloadKubeConfig =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let iksSpecificSteps =
            merge
              { IKSCreds =
                    λ(iksCreds : IKSCreds)
                  → let provisionStorage =
                          Concourse.helpers.taskStep
                            Concourse.schemas.TaskStep::{
                            , task = "provision-storage"
                            , config =
                                ../helpers/task-file.dhall
                                  reqs.ciResources
                                  "provision-storage"
                            , params =
                                Some (toMap { CLUSTER_NAME = reqs.clusterName })
                            }

                    let getIKSIngressEndpoint =
                          ../tasks/get-iks-ingress-endpoint.dhall
                            reqs.ciResources
                            reqs.clusterName
                            iksCreds

                    let hardenClusterSecurity =
                          ../tasks/harden-cluster-security.dhall
                            reqs.ciResources

                    in  [ provisionStorage
                        , getIKSIngressEndpoint
                        , hardenClusterSecurity
                        ]
              , GKECreds = λ(_ : GKECreds) → [] : List Concourse.Types.Step
              }
              reqs.creds

      let lockSteps =
            ./steps/lock-steps.dhall
              reqs.lockResource
              [ "lock-${reqs.clusterName}" ]

      let clusterReadyEvent =
            Optional/fold
              Concourse.Types.Resource
              reqs.clusterReadyEvent
              (List Concourse.Types.Step)
              (   λ(resource : Concourse.Types.Resource)
                → [ ../helpers/get-trigger-passed.dhall
                      resource
                      [ "create-cluster-${reqs.clusterName}" ]
                  ]
              )
              ([] : List Concourse.Types.Step)

      let putClusterState =
            helpers.putStep
              (   defaults.PutStep
                ⫽ { resource = reqs.clusterState
                  , params =
                      Some
                        ( toMap
                            { repository = Prelude.JSON.string "state-modified"
                            , merge = Prelude.JSON.bool True
                            }
                        )
                  }
              )

      let generateKubecfJob =
            Concourse.schemas.Job::{
            , name = "generate-kubecf-${reqs.clusterName}"
            , serial_groups = Some [ reqs.clusterName ]
            , public = Some True
            , plan =
                  lockSteps
                # [ ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get.dhall reqs.clusterState
                  , ../helpers/get-trigger-passed.dhall
                      reqs.eiriniRelease
                      [ "lock-${reqs.clusterName}" ]
                  , ../helpers/get-trigger-passed.dhall
                      reqs.kubecfRepo
                      [ "lock-${reqs.clusterName}" ]
                  , downloadKubeConfig
                  , ../tasks/configure-kubernetes.dhall reqs.ciResources
                  ]
                # clusterReadyEvent
                # iksSpecificSteps
                # [ generateValuesStep, putClusterState ]
            }

      in  ../helpers/group-job.dhall
            [ "kubecf-${reqs.clusterName}" ]
            generateKubecfJob
