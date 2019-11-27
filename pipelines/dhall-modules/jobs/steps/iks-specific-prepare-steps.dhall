let schemas = (../../deps/concourse.dhall).schemas

let helpers = (../../deps/concourse.dhall).helpers

let taskFile = ../../helpers/task-file.dhall

let iksSpecificSteps =
        λ(reqs : ../../types/cluster-requirements.dhall)
      → λ(configParams : ../../types/cluster-config-params.dhall)
      → λ(iksCreds : ../../types/iks-creds.dhall)
      → let createClusterConfig =
              helpers.taskStep
                schemas.TaskStep::{
                , task = "create-cluster-config"
                , config = taskFile reqs.ciResources "cluster-config"
                , params = Some (toMap configParams)
                }

        let provisionStorage =
              helpers.taskStep
                schemas.TaskStep::{
                , task = "provision-storage"
                , config = taskFile reqs.ciResources "provision-storage"
                , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
                }

        let getIKSIngressEndpoint =
              ../../tasks/get-iks-ingress-endpoint.dhall
                reqs.ciResources
                reqs.clusterName
                iksCreds

        in  [ getIKSIngressEndpoint, createClusterConfig, provisionStorage ]

in  iksSpecificSteps
