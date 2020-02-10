let Concourse = ../dhall-modules/deps/concourse.dhall

let EnvironmentRequirements = ./environment-reqs.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let setUpEnvironment
    : EnvironmentRequirements → List Concourse.Types.GroupedJob
    =   λ(reqs : EnvironmentRequirements)
      → let clusterEventResource =
              ../dhall-modules/resources/cluster-event.dhall

        let clusterState =
              ../dhall-modules/resources/cluster-state.dhall
                reqs.stateGitHubPrivateKey

        let clusterCreatedEvent =
              clusterEventResource
                reqs.clusterName
                "created"
                reqs.stateGitHubPrivateKey

        let clusterReqs =
              { ciResources = reqs.ciResources
              , clusterState = clusterState
              , clusterCreatedEvent = clusterCreatedEvent
              , clusterReadyEvent = clusterCreatedEvent
              , clusterName = reqs.clusterName
              , workerCount = 3
              , creds = reqs.creds
              , clusterPreparation = ClusterPrep.NotRequired
              }

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        let cf4K8sJobs = ../dhall-modules/cf-for-k8s.dhall clusterReqs

        in  kubeClusterJobs # cf4K8sJobs

in  setUpEnvironment
