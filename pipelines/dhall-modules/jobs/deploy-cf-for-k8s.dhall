let Concourse = ../deps/concourse.dhall

let ClusterRequirements = ../types/cluster-requirements.dhall

let deployCf4K8sJob
    : ClusterRequirements → Concourse.Types.GroupedJob
    =   λ(reqs : ClusterRequirements)
      → let cf4k8sRepo = ../resources/cf-for-k8s.dhall "master"

        let downloadKubeConfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let deployCf4K8sTask =
              ../tasks/deploy-cf-for-k8s.dhall cf4k8sRepo reqs.clusterState

        let deployCf4K8sJob =
              Concourse.schemas.Job::{
              , name = "deploy-cf-for-k8s"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                  [ ../helpers/get-trigger.dhall cf4k8sRepo
                  , ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get.dhall reqs.clusterState
                  , ../helpers/get-trigger-passed.dhall
                      reqs.clusterReadyEvent
                      [ "create-cluster-${reqs.clusterName}" ]
                  , downloadKubeConfig
                  , deployCf4K8sTask
                  ]
              }

        in  ../helpers/group-job.dhall
              [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
              deployCf4K8sJob

in  deployCf4K8sJob
