let Concourse = ./deps/concourse.dhall

let ClusterRequirements = ./types/cluster-requirements.dhall

let createClusterJob = ./jobs/create-cluster.dhall

let deleteClusterJob = ./jobs/delete-cluster.dhall

let prepareClusterJobFn = ./jobs/prepare-cluster.dhall

let kubeCluster
    : ClusterRequirements → List Concourse.Types.Job
    =   λ(reqs : ClusterRequirements)
      → let prepareClusterJob =
              merge
                { NotRequired = [] : List Concourse.Types.Job
                , Required =
                      λ(prepReqs : ./types/cluster-prep-requirements.dhall)
                    → [ prepareClusterJobFn reqs prepReqs ]
                }
                reqs.clusterPreparation

        in  [ deleteClusterJob reqs, createClusterJob reqs ] # prepareClusterJob

in  kubeCluster
