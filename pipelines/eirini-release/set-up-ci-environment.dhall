let Concourse = ../dhall-modules/deps/concourse.dhall

let EnvironmentRequirements = ./environment-reqs.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let ImageLocation = ../dhall-modules/types/image-location.dhall

let setUpEnvironment
    : EnvironmentRequirements → List Concourse.Types.Job
    =   λ(reqs : EnvironmentRequirements)
      → let ciResources =
              ../dhall-modules/resources/ci-resources.dhall reqs.eiriniCIBranch
        
        let clusterEventResource =
              ../dhall-modules/resources/cluster-event.dhall
        
        let clusterState =
              ../dhall-modules/resources/cluster-state.dhall
                reqs.stateGitHubPrivateKey
        
        let slackNotification = ../dhall-modules/helpers/slack_on_fail.dhall
        
        let eiriniReleaseRepo =
              ../dhall-modules/resources/eirini-release.dhall
                reqs.eiriniReleaseBranch
        
        let uaaReadyEvent =
              clusterEventResource
                reqs.clusterName
                "uaa-ready"
                reqs.stateGitHubPrivateKey
        
        let uaaResource =
              ../dhall-modules/resources/uaa.dhall reqs.eiriniReleaseBranch
        
        let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall
        
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
              { ciResources = ciResources
              , clusterState = clusterState
              , clusterCreatedEvent = clusterCreatedEvent
              , clusterReadyEvent = clusterReadyEvent
              , clusterName = reqs.clusterName
              , enableOPIStaging = reqs.enableOpiStaging
              , workerCount = env:worker_count ? 1
              , storageClass = reqs.storageClass
              , creds = reqs.creds
              , clusterPreparation =
                  ClusterPrep.Required
                    { clusterAdminPassword = reqs.clusterAdminPassword
                    , uaaAdminClientSecret = reqs.uaaAdminClientSecret
                    , natsPassword = reqs.natsPassword
                    , diegoCellCount = reqs.diegoCellCount
                    }
              , failureNotification = slackNotification
              }
        
        let useCertManager =
              merge
                { IKSCreds =
                    λ(_ : ../dhall-modules/types/iks-creds.dhall) → "false"
                , GKECreds =
                    λ(_ : ../dhall-modules/types/gke-creds.dhall) → "true"
                }
                reqs.creds
        
        let deploymentReqs =
              { clusterName = reqs.clusterName
              , worldName = reqs.worldName
              , uaaResources = uaaResource
              , ciResources = ciResources
              , eiriniReleaseRepo = eiriniReleaseRepo
              , smokeTestsResource = smokeTestsResource
              , clusterReadyEvent = clusterReadyEvent
              , uaaReadyEvent = uaaReadyEvent
              , clusterState = clusterState
              , creds = reqs.creds
              , useCertManager = useCertManager
              , imageLocation = ImageLocation.InRepo {=}
              , skippedCats = None Text
              , autoTriggerOnEiriniRelease = True
              , lockResource =
                  Some
                    ( ../dhall-modules/resources/lock.dhall
                        reqs.clusterName
                        reqs.stateGitHubPrivateKey
                    )
              }
        
        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs
        
        let deploySCFJobs = ../dhall-modules/deploy-eirini.dhall deploymentReqs
        
        in  kubeClusterJobs # deploySCFJobs

in  setUpEnvironment
