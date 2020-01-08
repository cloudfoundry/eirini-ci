let Concourse = ../dhall-modules/deps/concourse.dhall

let EnvironmentRequirements = ../eirini-release/environment-reqs.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let ImageLocation = ../dhall-modules/types/image-location.dhall

let setUpEnvironment
    : EnvironmentRequirements → List Concourse.Types.GroupedJob
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
              , creds = reqs.creds
              , clusterPreparation =
                  ClusterPrep.Required
                    { clusterAdminPassword = reqs.clusterAdminPassword
                    , uaaAdminClientSecret = reqs.uaaAdminClientSecret
                    , natsPassword = reqs.natsPassword
                    , storageClass = reqs.storageClass
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
              , autoTriggerOnEiriniRelease = False
              , triggerDeployScfAfterUaa = True
              , lockResource = None Concourse.Types.Resource
              }

        let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall clusterReqs

        let deploySCFJobs = ../dhall-modules/deploy-eirini.dhall deploymentReqs

        in  kubeClusterJobs # deploySCFJobs

in  setUpEnvironment
