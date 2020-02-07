let Concourse = ../deps/concourse.dhall

let ClusterRequirements = ../types/cluster-requirements.dhall

let deployCf4K8sJob
    : ClusterRequirements → Concourse.Types.GroupedJob
    =   λ(reqs : ClusterRequirements)
      → let cf4k8sRepo = ../resources/cf-for-k8s.dhall "master"

        let getCf4K8s =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = cf4k8sRepo
                , trigger = Some True
                }

        let downloadKubeConfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let deployCf4K8sJob =
              Concourse.schemas.Job::{
              , name = "deploy-cf-for-k8s"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                  [ getCf4K8s
                  , ../helpers/get-trigger-passed.dhall
                      reqs.clusterReadyEvent
                      [ "prepare-cluster-${reqs.clusterName}" ]
                  , downloadKubeConfig
                  ]
              }

        in  ../helpers/group-job.dhall
              [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
              deployCf4K8sJob

in  deployCf4K8sJob
