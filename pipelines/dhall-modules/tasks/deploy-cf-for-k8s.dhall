let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(clusterConfig : Concourse.Types.Resource)
      → let script =
              ''
              set -euo pipefail

              export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
              export KUBECONFIG="$PWD/kube/config"
              ${cfForK8s.name}/bin/install-cf.sh ./${clusterConfig.name}/environments/kube-clusters/cf4k8s/scf-config-values.yaml
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy CF for K8s"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-for-k8s-ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          , Concourse.schemas.TaskInput::{
                            , name = clusterConfig.name
                            }
                          , Concourse.schemas.TaskInput::{ name = "kube" }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task
