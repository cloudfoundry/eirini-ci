let schemas = (../../deps/concourse.dhall).schemas

let helpers = (../../deps/concourse.dhall).helpers

let taskFile = ../../helpers/task-file.dhall

let gkeSpecificSteps =
        λ(reqs : ../../types/cluster-requirements.dhall)
      → λ(configParams : ../../types/cluster-config-params.dhall)
      → λ(gkeCreds : ../../types/gke-creds.dhall)
      → let createClusterConfig =
              helpers.taskStep
                schemas.TaskStep::{
                , task = "create-cluster-config"
                , config = taskFile reqs.ciResources "gcp-cluster-config"
                , params = Some (toMap configParams)
                }
        
        let installHelmDeps =
              helpers.taskStep
                schemas.TaskStep::{
                , task = "install-helm-dependencies"
                , config = taskFile reqs.ciResources "install-helm-dependencies"
                , params =
                    Some
                      ( toMap
                          { GOOGLE_APPLICATION_CREDENTIALS =
                              "kube/service-account.json"
                          , GCP_SERVICE_ACCOUNT_JSON =
                              gkeCreds.serviceAccountJSON
                          , DNS_SERVICE_ACCOUNT = gkeCreds.dnsServiceAccountJSON
                          , CLUSTER_NAME = reqs.clusterName
                          }
                      )
                }
        
        in  [ createClusterConfig, installHelmDeps ]

in  gkeSpecificSteps
