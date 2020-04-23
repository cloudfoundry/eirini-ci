let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let iksCredsInputs =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , githubAccessToken = "((github-access-token))"
      , storageClass = "((storage_class))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      }

let iksCreds = (../dhall-modules/types/creds.dhall).IKSCreds iksCredsInputs

let eiriniReleaseRepo = ../dhall-modules/resources/eirini-release.dhall "master"

let uaaResource = ../dhall-modules/resources/uaa.dhall "master"

let ciResources = ../dhall-modules/resources/ci-resources.dhall "master"

let commonDeploymentReqs =
      { enableOpiStaging = "true"
      , storageClass = inputs.storageClass
      , ciResources = ciResources
      , eiriniReleaseRepo = eiriniReleaseRepo
      , stateGitHubPrivateKey = inputs.githubPrivateKey
      , githubAccessToken = inputs.githubAccessToken
      , clusterAdminPassword = inputs.clusterAdminPassword
      , uaaAdminClientSecret = inputs.uaaAdminClientSecret
      , natsPassword = inputs.natsPassword
      , uaaResource = uaaResource
      , isFreshini = False
      , grafanaAdminPassword = ""
      , creds = iksCreds
      }

let kyotoReqs = commonDeploymentReqs ⫽ { clusterName = "kyoto" }

let lisbonReqs = commonDeploymentReqs ⫽ { clusterName = "lisbon" }

let tarnovoReqs = commonDeploymentReqs ⫽ { clusterName = "veliko-tarnovo" }

let barcelonaReqs = commonDeploymentReqs ⫽ { clusterName = "barcelona" }

let kyotoEnv = ./set-up-dev-env.dhall kyotoReqs

let lisbonEnv = ./set-up-dev-env.dhall lisbonReqs

let tarnovoEnv = ./set-up-dev-env.dhall tarnovoReqs

let barcelonaEnv = ./set-up-dev-env.dhall barcelonaReqs

let jobs =
      Prelude.List.concat
        Concourse.Types.GroupedJob
        [ kyotoEnv, lisbonEnv, tarnovoEnv, barcelonaEnv ]

in  Concourse.render.groupedJobs jobs
