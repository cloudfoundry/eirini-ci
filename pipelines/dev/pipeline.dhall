  λ(workerCount : Natural)
→ let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall
  
  let Prelude = ../dhall-modules/deps/prelude.dhall
  
  let Concourse = ../dhall-modules/deps/concourse.dhall
  
  let clusterState =
        ../dhall-modules/resources/cluster-state.dhall "((github-private-key))"
  
  let ciResources =
        ../dhall-modules/resources/ci-resources.dhall "((ci-resources-branch))"
  
  let clusterReadyEvent =
        clusterEventResource "((world-name))" "ready" "((github-private-key))"
  
  let uaaReadyEvent =
        clusterEventResource
          "((world-name))"
          "uaa-ready"
          "((github-private-key))"
  
  let eiriniRepo =
        ../dhall-modules/resources/eirini.dhall "((eirini-branch))"
  
  let eiriniReleaseRepo =
        ../dhall-modules/resources/eirini-release.dhall
          "((eirini-release-branch))"
  
  let uaaResource =
        ../dhall-modules/resources/uaa.dhall "((eirini-release-branch))"
  
  let smokeTestsResource = ../dhall-modules/resources/smoke-tests.dhall
  
  let sampleConfigs =
        ../dhall-modules/resources/sample-configs.dhall
          "((ci-resources-branch))"
  
  let iksCreds =
        { account = "((ibmcloud-account))"
        , password = "((ibmcloud-password))"
        , user = "((ibmcloud-user))"
        }
  
  let docker =
        ../dhall-modules/resources/all-dockers.dhall
          "((dockerhub-user))"
          "((dockerhub-password))"
  
  let deploymentVersion =
        ../dhall-modules/resources/deployment-version.dhall
          "((world-name))"
          "((gcs-json-key))"
  
  let downloadKubeconfigTask =
        ../dhall-modules/tasks/download-kubeconfig-iks.dhall
          iksCreds
          ciResources
          "((world-name))"
  
  let ImageLocation = ../dhall-modules/types/image-location.dhall
  
  let EiriniOrRepo = ../dhall-modules/types/eirini-or-repo.dhall
  
  let kubeClusterReqs =
        { ciResources = ciResources
        , clusterState = clusterState
        , clusterCreatedEvent =
            clusterEventResource
              "((world-name))"
              "created"
              "((github-private-key))"
        , clusterReadyEvent = clusterReadyEvent
        , clusterName = "((world-name))"
        , enableOPIStaging = "true"
        , iksCreds = iksCreds
        , workerCount = workerCount
        , storageClass = "((storage_class))"
        , clusterAdminPassword = "((cluster_admin_password))"
        , uaaAdminClientSecret = "((uaa_admin_client_secret))"
        , natsPassword = "((nats_password))"
        , diegoCellCount = "((diego-cell-count))"
        }
  
  let runTestReqs =
        { readyEventResource = clusterReadyEvent
        , ciResources = ciResources
        , eiriniRepo = eiriniRepo
        , secretSmugglerRepo = EiriniOrRepo.UseEirini
        , fluentdRepo = EiriniOrRepo.UseEirini
        , sampleConfigs = sampleConfigs
        , clusterName = "((world-name))"
        , dockerOPI = docker.opi
        , dockerBitsWaiter = docker.bitsWaiter
        , dockerRootfsPatcher = docker.rootfsPatcher
        , dockerSecretSmuggler = docker.secretSmuggler
        , dockerFluentd = docker.fluentd
        , iksCreds = iksCreds
        }
  
  let tagImagesReqs =
        { dockerOPI = docker.opi
        , dockerBitsWaiter = docker.bitsWaiter
        , dockerRootfsPatcher = docker.rootfsPatcher
        , dockerSecretSmuggler = docker.secretSmuggler
        , dockerFluentd = docker.fluentd
        , worldName = "((world-name))"
        , eiriniRepo = eiriniRepo
        , deploymentVersion = deploymentVersion
        }
  
  let deploymentReqs =
        { clusterName = "((world-name))"
        , worldName = "((world-name))"
        , uaaResources = uaaResource
        , ciResources = ciResources
        , eiriniReleaseRepo = eiriniReleaseRepo
        , smokeTestsResource = smokeTestsResource
        , clusterReadyEvent = clusterReadyEvent
        , uaaReadyEvent = uaaReadyEvent
        , clusterState = clusterState
        , downloadKubeconfigTask = downloadKubeconfigTask
        , useCertManager = "false"
        , iksCreds = iksCreds
        , imageLocation =
            ImageLocation.FromTags
              { eiriniRepo = eiriniRepo
              , deploymentVersion = deploymentVersion
              }
        , skippedCats = None Text
        }
  
  let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs
  
  let runTestJobs =
        ../dhall-modules/test-and-build-docker-images.dhall runTestReqs
  
  let tagImages = ../dhall-modules/tag-images.dhall tagImagesReqs
  
  let deployEirini = ../dhall-modules/deploy-eirini.dhall deploymentReqs
  
  in  Prelude.List.concat
        Concourse.Types.Job
        [ kubeClusterJobs, runTestJobs, tagImages, deployEirini ]
