let Concourse = ../dhall-modules/deps/concourse.dhall

let inputs = { githubPrivateKey = "((github-private-key))" }

let gkeCredsInputs =
      { serviceAccountJSON = "((gcp-service-account-json))"
      , dnsServiceAccountJSON = "((gcp-dns-service-account-json))"
      , region = "((gcp-region))"
      , zone = "((gcp-zone))"
      }

let gkeCreds = (../dhall-modules/types/creds.dhall).GKECreds gkeCredsInputs

let cf4k8sDeploymentReqs =
      { clusterName = "cf4k8s4a8e"
      , ciResources = ../dhall-modules/resources/ci-resources.dhall "master"
      , clusterState =
          ../dhall-modules/resources/cluster-state.dhall inputs.githubPrivateKey
      , eiriniRelease = ../dhall-modules/resources/eirini-release.dhall "master"
      , clusterReadyEvent = None Concourse.Types.Resource
      , creds = gkeCreds
      , lockResource = None Concourse.Types.Resource
      , cf4k8s = ../dhall-modules/resources/cf-for-k8s.dhall "master"
      }

in  ../dhall-modules/cf-for-k8s.dhall cf4k8sDeploymentReqs
