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

        let clusterReadyEvent =
              clusterEventResource
                reqs.clusterName
                "ready"
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
              , clusterReadyEvent = clusterReadyEvent
              , clusterName = reqs.clusterName
              , workerCount = 3
              , creds = reqs.creds
              , clusterPreparation =
                  ClusterPrep.Required
                    { clusterAdminPassword = reqs.clusterAdminPassword
                    , uaaAdminClientSecret = reqs.uaaAdminClientSecret
                    , natsPassword = reqs.natsPassword
                    , storageClass = reqs.storageClass
                    }
              }

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        in  kubeClusterJobs

in  setUpEnvironment
