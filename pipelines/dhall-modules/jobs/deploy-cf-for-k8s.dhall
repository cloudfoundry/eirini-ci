let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let CF4K8SDeploymentReqs = ../types/cf4k8s-deployment-requirements.dhall

let deployCf4K8sJob
    : CF4K8SDeploymentReqs → Concourse.Types.GroupedJob
    =   λ(reqs : CF4K8SDeploymentReqs)
      → let downloadKubeConfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let deleteCf4K8s = ../tasks/delete-cf-for-k8s.dhall

        let patchEiriniRelease =
              ../tasks/patch-eirini-release.dhall reqs.cf4k8s reqs.eiriniRelease

        let deployCf4K8sTask =
              ../tasks/deploy-cf-for-k8s.dhall
                reqs.ciResources
                reqs.clusterState
                reqs.clusterName

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

        let deployCf4K8sJob =
              Concourse.schemas.Job::{
              , name = "deploy-cf-for-k8s-${reqs.clusterName}"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                    lockSteps
                  # [ getEiriniRelease
                    , getCf4k8s
                    , ../helpers/get.dhall reqs.ciResources
                    , ../helpers/get.dhall reqs.clusterState
                    , ../helpers/get-trigger-passed.dhall
                        reqs.clusterReadyEvent
                        [ "create-cluster-${reqs.clusterName}" ]
                    , downloadKubeConfig
                    , deleteCf4K8s
                    , patchEiriniRelease
                    , deployCf4K8sTask
                    ]
              }

        in  ../helpers/group-job.dhall
              [ "cf-for-k8s-${reqs.clusterName}" ]
              deployCf4K8sJob

in  deployCf4K8sJob
