let Concourse = ../deps/concourse.dhall

let CF4K8SDeploymentReqs = ../types/cf4k8s-deployment-requirements.dhall

let deployCf4K8sJob
    : CF4K8SDeploymentReqs → Concourse.Types.GroupedJob
    =   λ(reqs : CF4K8SDeploymentReqs)
      → let cf4k8sRepo = ../resources/cf-for-k8s.dhall "master"

        let runCf4K8sSmokeTestsTask =
              ../tasks/run-cf-for-k8s-smoke-tests.dhall
                cf4k8sRepo
                reqs.clusterState

        let upstreamJobs = [ "deploy-cf-for-k8s-${reqs.clusterName}" ]

        let lockSteps =
              ../jobs/steps/lock-steps.dhall reqs.lockResource upstreamJobs

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
                    , ../helpers/get.dhall reqs.eiriniRelease
                    , runCf4K8sSmokeTestsTask
                    ]
                  # lockSteps
              }

        in  ../helpers/group-job.dhall
              [ "cf-for-k8s-${reqs.clusterName}" ]
              runCf4K8sSmokeTestsJob

in  deployCf4K8sJob
