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

        let lockResource =
              ../dhall-modules/resources/lock.dhall
                reqs.clusterName
                reqs.stateGitHubPrivateKey

        let cf4k8sRepo = ../dhall-modules/resources/cf-for-k8s.dhall "master"

        let clusterReqs =
              { ciResources = reqs.ciResources
              , clusterState = clusterState
              , clusterCreatedEvent = clusterCreatedEvent
              , clusterReadyEvent = clusterCreatedEvent
              , clusterName = reqs.clusterName
              , workerCount = 3
              , creds = reqs.creds
              , clusterPreparation = ClusterPrep.NotRequired
              , enableDeleteTimer = True
              }

        let deploymentReqs =
              { clusterName = reqs.clusterName
              , ciResources = reqs.ciResources
              , clusterState = clusterState
              , eiriniRelease = reqs.eiriniReleaseRepo
              , clusterReadyEvent = Some clusterCreatedEvent
              , creds = reqs.creds
              , lockResource = Some lockResource
              , cf4k8s = cf4k8sRepo
              }

        let locksUpstream = [ "smoke-tests-${reqs.clusterName}" ]

        let lockJobs =
              ../dhall-modules/locks.dhall
                { upstream = locksUpstream
                , lockResource = lockResource
                , eiriniReleaseRepo = reqs.eiriniReleaseRepo
                , acquireLockGetTriggers =
                    [ ../dhall-modules/helpers/get-trigger-passed.dhall
                        reqs.eiriniReleaseRepo
                        [ "helm-lint" ]
                    , ../dhall-modules/helpers/get-trigger.dhall cf4k8sRepo
                    ]
                }

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        let cf4K8sJobs = ../dhall-modules/cf-for-k8s.dhall deploymentReqs

        in  kubeClusterJobs # cf4K8sJobs # lockJobs

in  setUpEnvironment
