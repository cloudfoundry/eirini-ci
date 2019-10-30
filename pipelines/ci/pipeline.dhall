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
      , eiriniBranch = "((eirini-branch))"
      , eiriniReleaseBranch = "((eirini-release-branch))"
      , eiriniReleasePrivateKey = "((eirini-release-repo-key))"
      , iksCreds = iksCreds
      , dockerhubUser = "((dockerhub-user))"
      , dockerhubPassword = "((dockerhub-password))"
      , storageClass = "((storage_class))"
      }

let Prelude = ../dhall-modules/deps/prelude.dhall

let Concourse = ../dhall-modules/deps/concourse.dhall

let clusterState =
      ../dhall-modules/resources/cluster-state.dhall inputs.githubPrivateKey

let ciResources =
      ../dhall-modules/resources/ci-resources.dhall inputs.eiriniCIBranch

let clusterReadyEvent =
      clusterEventResource inputs.worldName "ready" inputs.githubPrivateKey

let clusterCreatedEvent =
      clusterEventResource inputs.worldName "created" inputs.githubPrivateKey

let eiriniRepo = ../dhall-modules/resources/eirini.dhall inputs.eiriniBranch

let writableEiriniReleaseRepo =
      ../dhall-modules/resources/writeable-eirini-release.dhall
        inputs.eiriniReleaseBranch
        inputs.eiriniReleasePrivateKey

let eiriniStagingRepo = ../dhall-modules/resources/eirini-staging.dhall

let fluentdRepo =
      ../dhall-modules/resources/fluend-repo.dhall inputs.eiriniBranch

let secretSmugglerRepo =
      ../dhall-modules/resources/eirini-secret-smuggler.dhall
        inputs.eiriniBranch

let sampleConfigs =
      ../dhall-modules/resources/sample-configs.dhall inputs.eiriniCIBranch

let docker =
      ../dhall-modules/resources/all-dockers.dhall
        inputs.dockerhubUser
        inputs.dockerhubPassword

let EiriniOrRepo = ../dhall-modules/types/eirini-or-repo.dhall

let ClusterPrep = ../dhall-modules/types/cluster-prep.dhall

let kubeClusterReqs =
      { ciResources = ciResources
      , clusterState = clusterState
      , clusterCreatedEvent = clusterCreatedEvent
      , clusterReadyEvent = clusterReadyEvent
      , clusterName = inputs.worldName
      , enableOPIStaging = "true"
      , iksCreds = iksCreds
      , workerCount = 1
      , storageClass = inputs.storageClass
      , clusterPreparation = ClusterPrep.NotRequired
      }

let runTestReqs =
      { ciResources = ciResources
      , eiriniRepo = eiriniRepo
      , secretSmugglerRepo = EiriniOrRepo.UseRepo secretSmugglerRepo
      , fluentdRepo = EiriniOrRepo.UseRepo fluentdRepo
      , sampleConfigs = sampleConfigs
      , clusterName = inputs.worldName
      , dockerOPI = docker.opi
      , dockerBitsWaiter = docker.bitsWaiter
      , dockerRootfsPatcher = docker.rootfsPatcher
      , dockerSecretSmuggler = docker.secretSmuggler
      , dockerFluentd = docker.fluentd
      , iksCreds = iksCreds
      , upstream = { name = "create-cluster", event = clusterCreatedEvent }
      }

let updateVersionReqs =
      { writeableEiriniReleaseRepo = writableEiriniReleaseRepo
      , ciResources = ciResources
      , eiriniRepo = eiriniRepo
      , fluentdRepo = fluentdRepo
      , secretSmugglerRepo = secretSmugglerRepo
      , dockerOPI = docker.opi
      , dockerRootfsPatcher = docker.rootfsPatcher
      , dockerBitsWaiter = docker.bitsWaiter
      }

let runStagingTestReqs =
      { ciResources = ciResources, eiriniStagingRepo = eiriniStagingRepo }

let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs

let runStagingTestJobs =
      ../dhall-modules/test-and-build-staging-images.dhall runStagingTestReqs

let runTestJobs =
      ../dhall-modules/test-and-build-docker-images.dhall runTestReqs

let updateVersionJobs =
      ../dhall-modules/update-version-files.dhall updateVersionReqs

in  Prelude.List.concat
      Concourse.Types.Job
      [ kubeClusterJobs, runTestJobs, updateVersionJobs, runStagingTestJobs ]