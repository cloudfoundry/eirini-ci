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

        let generateValuesTask = ../tasks/generate-cf-for-k8s-values.dhall

        let deployCf4K8sTask = downloadKubeConfig

        let runCf4K8sSmokeTestsTasks = downloadKubeConfig

        let deleteCf4K8sTask = downloadKubeConfig

        let deployCf4K8sJob =
              Concourse.schemas.Job::{
              , name = "deploy-cf-for-k8s"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                  [ ../helpers/get-trigger.dhall cf4k8sRepo
                  , ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get-trigger-passed.dhall
                      reqs.clusterReadyEvent
                      [ "prepare-cluster-${reqs.clusterName}" ]
                  , downloadKubeConfig
                  , generateValuesTask cf4k8sRepo reqs.clusterName
                  , deployCf4K8sTask
                  , runCf4K8sSmokeTestsTasks
                  , deleteCf4K8sTask
                  ]
              }

        in  ../helpers/group-job.dhall
              [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
              deployCf4K8sJob

in  deployCf4K8sJob
