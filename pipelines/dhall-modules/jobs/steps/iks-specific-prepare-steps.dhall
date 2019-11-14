let schemas = (../../deps/concourse.dhall).schemas

let defaults = (../../deps/concourse.dhall).defaults

let helpers = (../../deps/concourse.dhall).helpers

let taskFile = ../../helpers/task-file.dhall

let iksParams = ../../helpers/iks-params.dhall

let iksSpecificSteps =
        λ(reqs : ../../types/cluster-requirements.dhall)
      → λ(configParams : ../../types/cluster-config-params.dhall)
      → λ(iksCreds : ../../types/iks-creds.dhall)
      → let createClusterConfig =
              helpers.taskStep
                (   defaults.TaskStep
                  ⫽ { task = "create-cluster-config"
                    , config = taskFile reqs.ciResources "cluster-config"
                    , params = Some (toMap configParams)
                    }
                )
        
        let provisionStorage =
              helpers.taskStep
                (   defaults.TaskStep
                  ⫽ { task = "provision-storage"
                    , config = taskFile reqs.ciResources "provision-storage"
                    , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
                    }
                )
        
        let getIKSIngressEndpoint =
              helpers.taskStep
                schemas.TaskStep::{
                , task = "get-iks-ingress-endpoint"
                , config = taskFile reqs.ciResources "get-iks-ingress-endpoint"
                , params =
                    Some
                      ( toMap
                          (   iksParams iksCreds
                            ⫽ { CLUSTER_NAME = reqs.clusterName }
                          )
                      )
                }
        
        in  [ getIKSIngressEndpoint, createClusterConfig, provisionStorage ]

in  iksSpecificSteps
