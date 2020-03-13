let Concourse = ../dhall-modules/deps/concourse.dhall

let gkeCredsInputs =
      { serviceAccountJSON = "((gcp-service-account-json))"
      , dnsServiceAccountJSON = "((gcp-dns-service-account-json))"
      , region = "((gcp-region))"
      , zone = "((gcp-zone))"
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
      , grafanaAdminPassword = "((grafana-admin-password))"
      }

let gkeCreds = (../dhall-modules/types/creds.dhall).GKECreds gkeCredsInputs

let eiriniReleaseRepo =
      ../dhall-modules/resources/eirini-release.dhall "develop"

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
      , grafanaAdminPassword = inputs.grafanaAdminPassword
      }

let gkeDeploymentReqs =
        commonDeploymentReqs
      ⫽ { clusterName = "((world-name))", creds = gkeCreds, isFreshini = False }

let jobs = ./set-up-ci-environment.dhall gkeDeploymentReqs

let pipeline = ../dhall-modules/helpers/slack-on-fail-grouped-jobs.dhall jobs

in  Concourse.render.groupedJobs pipeline
