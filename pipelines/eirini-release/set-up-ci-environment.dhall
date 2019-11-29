let Concourse = ../dhall-modules/deps/concourse.dhall

let EnvironmentRequirements = ./environment-reqs.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let ImageLocation = ../dhall-modules/types/image-location.dhall

let setUpEnvironment
    : EnvironmentRequirements → List Concourse.Types.Job
    =   λ(reqs : EnvironmentRequirements)
      → let clusterEventResource =
              ../dhall-modules/resources/cluster-event.dhall

        let clusterState =
              ../dhall-modules/resources/cluster-state.dhall
                reqs.stateGitHubPrivateKey

        let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall

        let uaaReadyEvent =
              clusterEventResource
                reqs.clusterName
                "uaa-ready"
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
              , storageClass = reqs.storageClass
              , creds = reqs.creds
              , clusterPreparation =
                  ClusterPrep.Required
                    { clusterAdminPassword = reqs.clusterAdminPassword
                    , uaaAdminClientSecret = reqs.uaaAdminClientSecret
                    , natsPassword = reqs.natsPassword
                    }
              }

        let useCertManager =
              merge
                { IKSCreds =
                    λ(_ : ../dhall-modules/types/iks-creds.dhall) → "false"
                , GKECreds =
                    λ(_ : ../dhall-modules/types/gke-creds.dhall) → "true"
                }
                reqs.creds

        let lockResource =
              ../dhall-modules/resources/lock.dhall
                reqs.clusterName
                reqs.stateGitHubPrivateKey

        let deploymentReqs =
              { clusterName = reqs.clusterName
              , uaaResources = reqs.uaaResource
              , ciResources = reqs.ciResources
              , eiriniReleaseRepo = reqs.eiriniReleaseRepo
              , smokeTestsResource = smokeTestsResource
              , clusterReadyEvent = Some clusterReadyEvent
              , uaaReadyEvent = uaaReadyEvent
              , clusterState = clusterState
              , creds = reqs.creds
              , useCertManager = useCertManager
              , imageLocation = ImageLocation.InRepo {=}
              , skippedCats = None Text
              , autoTriggerOnEiriniRelease = True
              , lockResource = Some lockResource
              }

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        let deploySCFJobs = ../dhall-modules/deploy-eirini.dhall deploymentReqs

        let runCatsJob =
              [ ../dhall-modules/jobs/run-core-cats.dhall deploymentReqs ]

        let locksUpstream =
                    if reqs.isFreshini

              then  [ "nuke-scf" ]

              else  [ "run-core-cats-${reqs.clusterName}" ]

        let lockJobs =
              ../dhall-modules/locks.dhall
                { upstream = locksUpstream
                , lockResource = lockResource
                , ciResources = reqs.ciResources
                , eiriniReleaseRepo = reqs.eiriniReleaseRepo
                }

        let nukeScfJobs =
                    if reqs.isFreshini

              then  [ ../dhall-modules/jobs/nuke-scf.dhall
                        deploymentReqs.{ ciResources
                                       , eiriniReleaseRepo
                                       , lockResource
                                       , clusterName
                                       , creds
                                       }
                    ]

              else  [] : List Concourse.Types.Job

        let installMonitoring =
              ../dhall-modules/jobs/install-monitoring.dhall
                { ciResources = reqs.ciResources
                , clusterName = reqs.clusterName
                , grafanaAdminPassword = reqs.grafanaAdminPassword
                , creds = reqs.creds
                , upstreamEvent = clusterReadyEvent
                }

        in    kubeClusterJobs
            # deploySCFJobs
            # runCatsJob
            # lockJobs
            # nukeScfJobs
            # [ installMonitoring ]

in  setUpEnvironment
