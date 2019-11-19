let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall

let iksCreds =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , eiriniRepoKey = "((eirini-repo-key))"
      , eiriniCIBranch = "((ci-resources-branch))"
      , worldName = "bump-go"
      , eiriniBranch = "((eirini-branch))"
      , eiriniReleaseBranch = "((eirini-release-branch))"
      , dockerhubUser = "((dockerhub-user))"
      , dockerhubPassword = "((dockerhub-password))"
      , gcsJSONKey = "((gcs-json-key))"
      , storageClass = "((storage_class))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      , diegoCellCount = "0"
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

let eiriniMaster =
      ../dhall-modules/resources/writeable-eirini.dhall
        "eirini-master"
        "master"
        inputs.eiriniRepoKey
        False

let eiriniRepo =
      ../dhall-modules/resources/writeable-eirini.dhall
        "eirini"
        inputs.eiriniBranch
        inputs.eiriniRepoKey
        True

let eiriniReleaseRepo =
      ../dhall-modules/resources/eirini-release.dhall inputs.eiriniReleaseBranch

let uaaResource =
      ../dhall-modules/resources/uaa.dhall inputs.eiriniReleaseBranch

let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall

let sampleConfigs =
      ../dhall-modules/resources/sample-configs.dhall inputs.eiriniCIBranch

let docker =
      ../dhall-modules/resources/all-dockers.dhall
        inputs.dockerhubUser
        inputs.dockerhubPassword

let deploymentVersion =
      ../dhall-modules/resources/deployment-version.dhall
        inputs.worldName
        inputs.gcsJSONKey

let ImageLocation = ../dhall-modules/types/image-location.dhall

let EiriniOrRepo = ../dhall-modules/types/eirini-or-repo.dhall

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
      , enableOPIStaging = "true"
      , creds = creds
      , workerCount = workerCount
      , storageClass = inputs.storageClass
      , clusterPreparation =
          ClusterPrep.Required
            { clusterAdminPassword = inputs.clusterAdminPassword
            , uaaAdminClientSecret = inputs.uaaAdminClientSecret
            , natsPassword = inputs.natsPassword
            , diegoCellCount = inputs.diegoCellCount
            }
      , failureNotification = None Concourse.Types.Step
      }

let deploymentReqs =
      { clusterName = inputs.worldName
      , worldName = inputs.worldName
      , uaaResources = uaaResource
      , ciResources = ciResources
      , eiriniReleaseRepo = eiriniReleaseRepo
      , smokeTestsResource = smokeTestsResource
      , clusterReadyEvent = clusterReadyEvent
      , uaaReadyEvent = uaaReadyEvent
      , clusterState = clusterState
      , creds = creds
      , useCertManager = "false"
      , imageLocation =
          ImageLocation.FromTags
            { eiriniRepo = eiriniRepo, deploymentVersion = deploymentVersion }
      , skippedCats = None Text
      , autoTriggerOnEiriniRelease = False
      , lockResource = None Concourse.Types.Resource
      }

let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs

let runTestJobs =
      ../dhall-modules/test-and-build-docker-images.dhall
        { ciResources = ciResources
        , eiriniRepo = eiriniRepo
        , secretSmugglerRepo = EiriniOrRepo.UseEirini
        , fluentdRepo = EiriniOrRepo.UseEirini
        , sampleConfigs = sampleConfigs
        , clusterName = inputs.worldName
        , dockerOPI = docker.opi
        , dockerBitsWaiter = docker.bitsWaiter
        , dockerRootfsPatcher = docker.rootfsPatcher
        , dockerSecretSmuggler = docker.secretSmuggler
        , dockerFluentd = docker.fluentd
        , dockerRouteCollector = docker.routeCollector
        , dockerRoutePodInformer = docker.routePodInformer
        , dockerRouteStatefulsetInformer = docker.routeStatefulsetInformer
        , dockerMetricsCollector = docker.metricsCollector
        , creds = creds
        , upstream = { name = "prepare-cluster", event = clusterReadyEvent }
        , failureNotification = None Concourse.Types.Step
        , eiriniUpstreams = Some [ "bump-go-packages" ]
        , enableNonCodeAutoTriggers = False
        }

let tagImages =
      ../dhall-modules/tag-images.dhall
        { dockerOPI = docker.opi
        , dockerBitsWaiter = docker.bitsWaiter
        , dockerRootfsPatcher = docker.rootfsPatcher
        , dockerSecretSmuggler = docker.secretSmuggler
        , dockerFluentd = docker.fluentd
        , dockerRouteCollector = docker.routeCollector
        , dockerRoutePodInformer = docker.routePodInformer
        , dockerRouteStatefulsetInformer = docker.routeStatefulsetInformer
        , dockerMetricsCollector = docker.metricsCollector
        , worldName = inputs.worldName
        , eiriniRepo = eiriniRepo
        , deploymentVersion = deploymentVersion
        }

let deployEirini = ../dhall-modules/deploy-eirini.dhall deploymentReqs

let bumpGo =
      ../dhall-modules/bump-go.dhall
        { clusterName = "bump-go"
        , eiriniMaster = eiriniMaster
        , testEiriniBranch = eiriniRepo
        , ciResources = ciResources
        }

let jobs
    : List Concourse.Types.Job
    = Prelude.List.concat
        Concourse.Types.Job
        [ kubeClusterJobs, runTestJobs, tagImages, deployEirini, bumpGo ]

in  jobs
