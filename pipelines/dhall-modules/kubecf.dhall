let Concourse = ./deps/concourse.dhall

let KubeCFDeploymentRequirements = ./types/kubecf-deployment-requirements.dhall

let kubeCluster
    : KubeCFDeploymentRequirements → List Concourse.Types.GroupedJob
    =   λ(reqs : KubeCFDeploymentRequirements)
      → [ ./jobs/generate-kubecf-values.dhall reqs
        , ./jobs/deploy-kubecf.dhall reqs
        ]

in  kubeCluster
