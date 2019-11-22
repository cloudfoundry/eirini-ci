let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let iksCredsInputs =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let gkeCredsInputs =
      { serviceAccountJSON = "((gcp-service-account-json))"
      , dnsServiceAccountJSON = "((gcp-dns-service-account-json))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , eiriniReleasePrivateKey = "((eirini-release-repo-key))"
      , dockerhubUser = "((dockerhub-user))"
      , dockerhubPassword = "((dockerhub-password))"
      , storageClass = "((storage_class))"
      , gcsJSONKey = "((gcs-json-key))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      }

let iksCreds = (../dhall-modules/types/creds.dhall).IKSCreds iksCredsInputs

let gkeCreds = (../dhall-modules/types/creds.dhall).GKECreds gkeCredsInputs

let eiriniReleaseRepo =
      ../dhall-modules/resources/eirini-release.dhall "develop"

let writeableReleaseRepoMaster =
      ../dhall-modules/resources/eirini-release-master.dhall
        inputs.eiriniReleasePrivateKey

let uaaResource = ../dhall-modules/resources/uaa.dhall "develop"

let ciResources = ../dhall-modules/resources/ci-resources.dhall "master"

let commonDeploymentReqs =
      { enableOpiStaging = "true"
      , storageClass = inputs.storageClass
      , ciResources = ciResources
      , eiriniReleaseRepo = eiriniReleaseRepo
      , stateGitHubPrivateKey = inputs.githubPrivateKey
      , clusterAdminPassword = inputs.clusterAdminPassword
      , uaaAdminClientSecret = inputs.uaaAdminClientSecret
      , natsPassword = inputs.natsPassword
      , uaaResource = uaaResource
      }

let withOpiDeploymentReqs =
        commonDeploymentReqs
      ⫽ { clusterName = "with-opi", creds = iksCreds, isFreshini = False }

let freshiniDeploymentReqs =
        commonDeploymentReqs
      ⫽ { clusterName = "freshini", creds = iksCreds, isFreshini = True }

let gkeDeploymentReqs =
        commonDeploymentReqs
      ⫽ { clusterName = "gkerini", creds = gkeCreds, isFreshini = False }

let clusterNames =
      [ gkeDeploymentReqs.clusterName
      , freshiniDeploymentReqs.clusterName
      , withOpiDeploymentReqs.clusterName
      ]

let withOpiEnvironment = ./set-up-ci-environment.dhall withOpiDeploymentReqs

let freshiniEnvironment = ./set-up-ci-environment.dhall freshiniDeploymentReqs

let gkeEnvironment = ./set-up-ci-environment.dhall gkeDeploymentReqs

let ffMasterModule =
      ../dhall-modules/ff-master.dhall
        { eiriniReleaseRepo = eiriniReleaseRepo
        , writeableReleaseRepoMaster = writeableReleaseRepoMaster
        , clusterNames = clusterNames
        }

let helmLint =
      ../dhall-modules/jobs/helm-lint.dhall ciResources eiriniReleaseRepo

let jobs =
      Prelude.List.concat
        Concourse.Types.Job
        [ withOpiEnvironment
        , gkeEnvironment
        , freshiniEnvironment
        , ffMasterModule
        , [ helmLint ]
        ]

in  ../dhall-modules/helpers/slack_on_fail.dhall jobs
