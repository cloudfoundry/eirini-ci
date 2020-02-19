let Concourse = ./deps/concourse.dhall

let CF4K8SDeploymentReqs = ./types/cf4k8s-deployment-requirements.dhall

let deployCf4K8sJob = ../dhall-modules/jobs/deploy-cf-for-k8s.dhall

let runSmokeTests = ../dhall-modules/jobs/run-cf-for-k8s-smoke-tests.dhall

let kubeCluster
    : CF4K8SDeploymentReqs → List Concourse.Types.GroupedJob
    =   λ(reqs : CF4K8SDeploymentReqs)
      → [ deployCf4K8sJob reqs, runSmokeTests reqs ]

in  kubeCluster
