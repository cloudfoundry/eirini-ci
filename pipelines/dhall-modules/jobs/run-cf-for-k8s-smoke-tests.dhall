let Concourse = ../deps/concourse.dhall

let ClusterRequirements = ../types/cluster-requirements.dhall

let deployCf4K8sJob
    : ClusterRequirements → Concourse.Types.GroupedJob
    =   λ(reqs : ClusterRequirements)
      → let cf4k8sRepo = ../resources/cf-for-k8s.dhall "master"

        let runCf4K8sSmokeTestsTask =
              ../tasks/run-cf-for-k8s-smoke-tests.dhall
                cf4k8sRepo
                reqs.clusterState

        let runCf4K8sSmokeTestsJob =
              Concourse.schemas.Job::{
              , name = "smoke-tests-${reqs.clusterName}"
              , serial_groups = Some [ reqs.clusterName ]
              , public = Some True
              , plan =
                  [ ../helpers/get-trigger-passed.dhall
                      cf4k8sRepo
                      [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
                  , ../helpers/get.dhall reqs.clusterState
                  , runCf4K8sSmokeTestsTask
                  ]
              }

        in  ../helpers/group-job.dhall
              [ "cf-for-k8s-${reqs.clusterName}" ]
              runCf4K8sSmokeTestsJob

in  deployCf4K8sJob
