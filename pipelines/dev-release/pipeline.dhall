let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall

let iksCreds =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , eiriniCIBranch = "((ci-resources-branch))"
      , worldName = "((world-name))"
      , eiriniReleaseBranch = "((eirini-release-branch))"
      , gcsJSONKey = "((gcs-json-key))"
      , storageClass = "((storage_class))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      }

let creds = (../dhall-modules/types/creds.dhall).IKSCreds iksCreds

let Prelude = ../dhall-modules/deps/prelude.dhall

let Concourse = ../dhall-modules/deps/concourse.dhall

let clusterState =
      ../dhall-modules/resources/cluster-state.dhall inputs.githubPrivateKey

let ciResources =
      ../dhall-modules/resources/ci-resources.dhall inputs.eiriniCIBranch

let clusterReadyEvent =
      clusterEventResource inputs.worldName "ready" inputs.githubPrivateKey

let uaaReadyEvent =
      clusterEventResource inputs.worldName "uaa-ready" inputs.githubPrivateKey

let eiriniReleaseRepo =
      ../dhall-modules/resources/eirini-release.dhall inputs.eiriniReleaseBranch

let uaaResource =
      ../dhall-modules/resources/uaa.dhall inputs.eiriniReleaseBranch

let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall

let ImageLocation = ../dhall-modules/types/image-location.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let workerCount = 3

let kubeClusterReqs =
      { ciResources = ciResources
      , clusterState = clusterState
      , clusterCreatedEvent =
          clusterEventResource
            inputs.worldName
            "created"
            inputs.githubPrivateKey
      , clusterReadyEvent = clusterReadyEvent
      , clusterName = inputs.worldName
      , creds = creds
      , workerCount = workerCount
      , clusterPreparation =
          ClusterPrep.Required
            { clusterAdminPassword = inputs.clusterAdminPassword
            , uaaAdminClientSecret = inputs.uaaAdminClientSecret
            , natsPassword = inputs.natsPassword
            , storageClass = inputs.storageClass
            }
      , enableDeleteTimer = False
      , isCf4k8s = False
      }

let deploymentReqs =
      { clusterName = inputs.worldName
      , uaaResources = uaaResource
      , ciResources = ciResources
      , eiriniReleaseRepo = eiriniReleaseRepo
      , smokeTestsResource = smokeTestsResource
      , clusterReadyEvent = Some clusterReadyEvent
      , uaaReadyEvent = uaaReadyEvent
      , clusterState = clusterState
      , creds = creds
      , useCertManager = "false"
      , imageLocation = ImageLocation.InRepo {=}
      , skippedCats = None Text
      , autoTriggerOnEiriniRelease = False
      , triggerDeployScfAfterUaa = False
      , triggerDeployUaaWhenChanged = True
      , lockResource = None Concourse.Types.Resource
      }

let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs

let deployEirini = ../dhall-modules/deploy-eirini.dhall deploymentReqs

let catsReqs =
      { clusterName = inputs.worldName
      , eiriniReleaseRepo = eiriniReleaseRepo
      , lockResource = None Concourse.Types.Resource
      , imageLocation = ImageLocation.InRepo {=}
      , clusterState = clusterState
      , smokeTestsResource = smokeTestsResource
      , ciResources = ciResources
      , upstreamJob = "run-smoke-tests-${inputs.worldName}"
      , skippedCats = None Text
      , creds = creds
      }

let runCats = ../dhall-modules/jobs/run-core-cats.dhall catsReqs

let jobs =
      Prelude.List.concat
        Concourse.Types.GroupedJob
        [ kubeClusterJobs, deployEirini, [ runCats ] ]

in  Concourse.render.groupedJobs jobs
