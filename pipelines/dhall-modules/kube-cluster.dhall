let Concourse = ./deps/concourse.dhall

let ClusterRequirements = ./types/cluster-requirements.dhall

let createClusterJob = ./jobs/create-cluster.dhall

let deleteClusterJob = ./jobs/delete-cluster.dhall

let prepareClusterJobFn = ./jobs/prepare-cluster.dhall

let kubeCluster
    : ClusterRequirements → List Concourse.Types.GroupedJob
    =   λ(reqs : ClusterRequirements)
      → let prepareClusterJob =
              merge
                { NotRequired = [] : List Concourse.Types.Job
                , Required =
                      λ(prepReqs : ./types/cluster-prep-requirements.dhall)
                    → [ prepareClusterJobFn reqs prepReqs ]
                }
                reqs.clusterPreparation

        let jobs =
                [ deleteClusterJob reqs, createClusterJob reqs ]
              # prepareClusterJob

        in  ./helpers/group-jobs.dhall [ "cluster-${reqs.clusterName}" ] jobs

in  kubeCluster
