let Concourse = ../deps/concourse.dhall

let task =
        λ(clusterState : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → let script =
              ''
               set -euo pipefail
               ${./functions/aggregate-cf-for-k8s-values.sh as Text}

               readonly CLUSTER_DIR="environments/kube-clusters/${clusterName}"

               aggregate-files "$CLUSTER_DIR"
               update-cluster-state-repo "$CLUSTER_DIR"
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "aggregate cf4k8s values"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = clusterState.name
                            }
                          , Concourse.schemas.TaskInput::{
                            , name = "default-values-file"
                            }
                          , Concourse.schemas.TaskInput::{
                            , name = "loadbalancer-values-file"
                            }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "state-modified"
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
