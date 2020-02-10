let Concourse = ./deps/concourse.dhall

let ClusterRequirements = ./types/cluster-requirements.dhall

let deployCf4K8sJob = ../dhall-modules/jobs/deploy-cf-for-k8s.dhall

let kubeCluster
    : ClusterRequirements → List Concourse.Types.GroupedJob
    = λ(reqs : ClusterRequirements) → [ deployCf4K8sJob reqs ]

in  kubeCluster
