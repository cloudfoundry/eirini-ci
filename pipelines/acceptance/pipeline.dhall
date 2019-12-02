let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

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
      , eiriniStagingPrivateKey = "((eirini-staging-repo-key))"
      , githubAccessToken = "((github-access-token))"
      , eiriniPrivateKey = "((eirini-repo-key))"
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

let cleanupTimer =
        Concourse.defaults.Resource
      ⫽ { name = "sunday-morning"
        , type = Concourse.Types.ResourceType.InBuilt "time"
        , icon = Some "timer"
        , source =
            Some
              ( toMap
                  { start = Prelude.JSON.string "10:00 AM"
                  , stop = Prelude.JSON.string "11:00 AM"
                  , days = Prelude.JSON.array [ Prelude.JSON.string "Sunday" ]
                  }
              )
        }

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

let cleanupBlobstoreJob =
      ../dhall-modules/jobs/cleanup-blobstore.dhall
        ciResources
        cleanupTimer
        iksCredsInputs
        clusterName

let JSON = Prelude.JSON

let ghPagesRepo =
      Concourse.schemas.Resource::{
      , name = "gh-pages-pr"
      , type = Concourse.Types.ResourceType.InBuilt "git"
      , icon = Some "git"
      , source =
          Some
            ( toMap
                { uri =
                    JSON.string
                      "git@github.com:cloudfoundry-incubator/eirini-release.git"
                , branch = JSON.string "gh-pages-pr"
                , private_key = JSON.string inputs.eiriniReleasePrivateKey
                }
            )
      }

let writeableEiriniRepo =
      ../dhall-modules/resources/writeable-eirini.dhall
        "eirini"
        "master"
        inputs.eiriniPrivateKey
        False

let writeableStagingRepo =
      ../dhall-modules/resources/writeable-staging.dhall
        inputs.eiriniStagingPrivateKey

let githubRelease =
      ../dhall-modules/resources/eirini-release-github-release.dhall
        inputs.githubAccessToken

let publishReleaseJobs =
      ../dhall-modules/publish-release.dhall
        { clusterName = clusterName
        , ciResources = ciResources
        , clusterState = clusterState
        , githubAccessToken = inputs.githubAccessToken
        , eiriniReleaseRepo = eiriniReleaseRepo
        , ghPagesRepo = ghPagesRepo
        , githubRelease = githubRelease
        , writeableEiriniRepo = writeableEiriniRepo
        , writeableStagingRepo = writeableStagingRepo
        , versionResource =
            ../dhall-modules/resources/version.dhall inputs.githubPrivateKey
        }

let jobs = deploySCFJobs # cleanupBlobstoreJob # publishReleaseJobs

in  ../dhall-modules/helpers/slack-on-fail-grouped-jobs.dhall jobs
