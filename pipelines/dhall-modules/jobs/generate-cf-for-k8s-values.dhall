let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let CF4K8SDeploymentReqs = ../types/cf4k8s-deployment-requirements.dhall

let generateValues
    : CF4K8SDeploymentReqs → Concourse.Types.GroupedJob
    =   λ(reqs : CF4K8SDeploymentReqs)
      → let generateDefaultValues =
              ../tasks/generate-default-cf-for-k8s-values.dhall
                reqs.cf4k8s
                reqs.clusterName

        let generateLoadBalancerValues =
              ../tasks/generate-cf-for-k8s-loadbalancer-values.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let aggregateValuesFiles =
              ../tasks/aggregate-cf-for-k8s-values.dhall
                reqs.clusterState
                reqs.clusterName

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

        let getEiriniRelease =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.eiriniRelease
                , trigger = Some True
                , passed =
                    Prelude.Optional.map
                      Concourse.Types.Resource
                      (List Text)
                      (   λ(r : Concourse.Types.Resource)
                        → [ "lock-${reqs.clusterName}" ]
                      )
                      reqs.lockResource
                }

        let getCf4k8s =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.cf4k8s
                , trigger = Some True
                , passed =
                    Prelude.Optional.map
                      Concourse.Types.Resource
                      (List Text)
                      (   λ(r : Concourse.Types.Resource)
                        → [ "lock-${reqs.clusterName}" ]
                      )
                      reqs.lockResource
                }

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

        let generateValuesJob =
              Concourse.schemas.Job::{
              , name = "generate-cf-for-k8s-values"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                    lockSteps
                  # [ getCf4k8s
                    , getEiriniRelease
                    , ../helpers/get.dhall reqs.clusterState
                    , ../helpers/get.dhall reqs.ciResources
                    ]
                  # clusterReadyEvent
                  # [ generateDefaultValues
                    , generateLoadBalancerValues
                    , aggregateValuesFiles
                    , putClusterState
                    ]
              }

        in  ../helpers/group-job.dhall
              [ "cf-for-k8s-${reqs.clusterName}" ]
              generateValuesJob

in  generateValues
