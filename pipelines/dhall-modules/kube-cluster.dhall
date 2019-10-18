let Concourse = ./deps/concourse.dhall

let ClusterRequirements = ./cluster-requirements.dhall

let createClusterJob = ./jobs/create-cluster.dhall

let deleteClusterJob = ./jobs/delete-cluster.dhall

let prepareClusterJob = ./jobs/prepare-cluster.dhall

let kubeCluster
    : ClusterRequirements → List Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → [ deleteClusterJob reqs, createClusterJob reqs, prepareClusterJob reqs ]

in  kubeCluster
