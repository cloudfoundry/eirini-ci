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
  
  let eiriniSecretSmuggler =
        ../dhall-modules/resources/eirini-secret-smuggler.dhall
          "((eirini-branch))"
  
  let sampleConfigs =
        ../dhall-modules/resources/sample-configs.dhall
          "((ci-resources-branch))"
  
  let iksCreds =
        { account = "((ibmcloud-account))"
        , password = "((ibmcloud-password))"
        , user = "((ibmcloud-user))"
        }
  
  let dockerOPI =
        ../dhall-modules/resources/docker-opi.dhall
          "((dockerhub-user))"
          "((dockerhub-password))"
  
  let dockerBitsWaiter =
        ../dhall-modules/resources/docker-bits-waiter.dhall
          "((dockerhub-user))"
          "((dockerhub-password))"
  
  let dockerRootfsPatcher =
        ../dhall-modules/resources/docker-rootfs-patcher.dhall
          "((dockerhub-user))"
          "((dockerhub-password))"
  
  let dockerSecretSmuggler =
        ../dhall-modules/resources/docker-secret-smuggler.dhall
          "((dockerhub-user))"
          "((dockerhub-password))"
  
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
        , eiriniSecretSmuggler = eiriniSecretSmuggler
        , sampleConfigs = sampleConfigs
        , clusterName = "dhall-test"
        , dockerOPI = dockerOPI
        , dockerBitsWaiter = dockerBitsWaiter
        , dockerRootfsPatcher = dockerRootfsPatcher
        , dockerSecretSmuggler = dockerSecretSmuggler
        , iksCreds = iksCreds
        }
  
  let kubeClusterJobs = ../dhall-modules/kube-cluster.dhall kubeClusterReqs
  
  let runTestJobs =
        ../dhall-modules/test-and-build-docker-images.dhall runTestReqs
  
  in  Prelude.List.concat Concourse.Types.Job [ kubeClusterJobs, runTestJobs ]
