let Concourse = ../deps/concourse.dhall

let CF4K8SDeploymentReqs = ../types/cf4k8s-deployment-requirements.dhall

let deployCf4K8sJob
    : CF4K8SDeploymentReqs → Concourse.Types.GroupedJob
    =   λ(reqs : CF4K8SDeploymentReqs)
      → let varsDir = "smoke-tests-env-vars"

        let prepareSmokeTestsTask =
              ../tasks/prepare-cf-for-k8s-smoke-tests.dhall
                reqs.clusterState
                varsDir

        let runCf4K8sSmokeTestsTask =
              ../tasks/run-cf-for-k8s-smoke-tests.dhall reqs.cf4k8s varsDir

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
                        reqs.cf4k8s
                        [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
                    , ../helpers/get.dhall reqs.clusterState
                    , ../helpers/get-trigger-passed.dhall
                        reqs.eiriniRelease
                        [ "deploy-cf-for-k8s-${reqs.clusterName}" ]
                    , prepareSmokeTestsTask
                    , runCf4K8sSmokeTestsTask
                    ]
                  # lockSteps
              }

        in  ../helpers/group-job.dhall
              [ "cf-for-k8s-${reqs.clusterName}" ]
              runCf4K8sSmokeTestsJob

in  deployCf4K8sJob
