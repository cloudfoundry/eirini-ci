  λ(workerCount : Natural)
→ let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall
  
  let Prelude = ../dhall-modules/deps/prelude.dhall
  
  let Concourse = ../dhall-modules/deps/concourse.dhall
  
  let clusterState = ../dhall-modules/resources/cluster-state.dhall
  
  let ciResources =
        ../dhall-modules/resources/ci-resources.dhall "((ci-resources-branch))"
  
  let clusterReadyEvent =
        clusterEventResource "dhall-test" "ready" "((github-private-key))"
  
  let eiriniResource =
        ../dhall-modules/resources/eirini.dhall "((eirini-branch))"
  
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
  
  let kubeClusterReqs =
        { ciResources = ciResources
        , clusterState = clusterState "((github-private-key))"
        , clusterCreatedEvent =
            clusterEventResource "dhall-test" "created" "((github-private-key))"
        , clusterReadyEvent = clusterReadyEvent
        , clusterName = "dhall-test"
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
        , eiriniResource = eiriniResource
        , eiriniSecretSmuggler = eiriniResource
        , fluentdRepo = eiriniResource
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
        , eiriniResource = eiriniResource
        , deploymentVersion = deploymentVersion
        }
  
  let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs
  
  let runTestJobs =
        ../dhall-modules/test-and-build-docker-images.dhall runTestReqs
  
  let tagImages = ../dhall-modules/tag-images.dhall tagImagesReqs
  
  in  Prelude.List.concat
        Concourse.Types.Job
        [ kubeClusterJobs, runTestJobs, tagImages ]
