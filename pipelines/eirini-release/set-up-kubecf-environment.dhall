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

        let locksUpstream = [ "deploy-kubecf-${reqs.clusterName}" ]

        let kubecfRepo =
              ../dhall-modules/helpers/git-resource.dhall
                "kubecf"
                "https://github.com/herrjulz/kubecf-eirini"
                (None Text)
                "master"

        let lockJobs =
              ../dhall-modules/locks.dhall
                { upstream = locksUpstream
                , lockResource = lockResource
                , eiriniReleaseRepo = reqs.eiriniReleaseRepo
                , acquireLockGetTriggers =
                    [ ../dhall-modules/helpers/get-trigger-passed.dhall
                        reqs.eiriniReleaseRepo
                        [ "helm-lint" ]
                    , ../dhall-modules/helpers/get-trigger.dhall kubecfRepo
                    ]
                }

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

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        let deploymentReqs =
              { clusterName = reqs.clusterName
              , ciResources = reqs.ciResources
              , clusterState = clusterState
              , eiriniRelease = reqs.eiriniReleaseRepo
              , clusterReadyEvent = Some clusterCreatedEvent
              , creds = reqs.creds
              , lockResource = Some lockResource
              , kubecfRepo = kubecfRepo
              , storageClass = reqs.storageClass
              , cfOperatorChartUrl =
                  "https://s3.amazonaws.com/cf-operators/release/helm-charts/cf-operator-v2.0.0-0.g0142d1e9.tgz"
              }

        let deployKubecfJobs = ../dhall-modules/kubecf.dhall deploymentReqs

        in  kubeClusterJobs # deployKubecfJobs # lockJobs

in  setUpEnvironment
