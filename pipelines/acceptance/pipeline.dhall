let Concourse = ../dhall-modules/deps/concourse.dhall

let ImageLocation = ../dhall-modules/types/image-location.dhall

let clusterName = "acceptance"

let iksCredsInputs =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , eiriniReleasePrivateKey = "((eirini-release-repo-key))"
      , dockerhubUser = "((dockerhub-user))"
      , dockerhubPassword = "((dockerhub-password))"
      , storageClass = "((storage_class))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      }

let iksCreds = (../dhall-modules/types/creds.dhall).IKSCreds iksCredsInputs

let eiriniReleaseRepo = ../dhall-modules/resources/eirini-release.dhall "master"

let uaaResource = ../dhall-modules/resources/uaa.dhall "master"

let ciResources = ../dhall-modules/resources/ci-resources.dhall "master"

let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall

let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall

let uaaReadyEvent =
      clusterEventResource clusterName "uaa-ready" inputs.githubPrivateKey

let clusterState =
      ../dhall-modules/resources/cluster-state.dhall inputs.githubPrivateKey

let deploymentReqs =
      { clusterName = clusterName
      , uaaResources = uaaResource
      , ciResources = ciResources
      , eiriniReleaseRepo = eiriniReleaseRepo
      , smokeTestsResource = smokeTestsResource
      , uaaReadyEvent = uaaReadyEvent
      , clusterReadyEvent = None Concourse.Types.Resource
      , clusterState = clusterState
      , creds = iksCreds
      , useCertManager = "false"
      , imageLocation = ImageLocation.InRepo {=}
      , skippedCats = None Text
      , autoTriggerOnEiriniRelease = True
      , lockResource = None Concourse.Types.Resource
      }

let deploySCFJobs = ../dhall-modules/deploy-eirini.dhall deploymentReqs

in  deploySCFJobs
