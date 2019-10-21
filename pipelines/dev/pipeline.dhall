  λ(workerCount : Natural)
→ let ciResources = ../dhall-modules/resources/ci-resources.dhall
  
  let clusterEventResource = ../dhall-modules/resources/cluster-event.dhall
  
  let clusterState = ../dhall-modules/resources/cluster-state.dhall
  
  let kubeClusterReqs =
        { ciResources = ciResources "((ci-resources-branch))"
        , clusterState = clusterState "((github-private-key))"
        , clusterCreatedEvent =
            clusterEventResource "dhall-test" "created" "((github-private-key))"
        , clusterReadyEvent =
            clusterEventResource "dhall-test" "ready" "((github-private-key))"
        , clusterName = "dhall-test"
        , enableOPIStaging = "true"
        , iksCreds =
            { account = "((ibmcloud-account))"
            , password = "((ibmcloud-password))"
            , user = "((ibmcloud-user))"
            }
        , workerCount = workerCount
        , storageClass = "((storage_class))"
        , clusterAdminPassword = "((cluster_admin_password))"
        , uaaAdminClientSecret = "((uaa_admin_client_secret))"
        , natsPassword = "((nats_password))"
        , diegoCellCount = "((diego-cell-count))"
        }
  
  let kubeCluster = ../dhall-modules/kube-cluster.dhall kubeClusterReqs
  
  in  kubeCluster
