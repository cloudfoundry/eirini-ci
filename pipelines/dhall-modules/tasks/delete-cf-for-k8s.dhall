let Concourse = ../deps/concourse.dhall

let task =
      let script =
            ''
            set -euo pipefail
            export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
            export KUBECONFIG="$PWD/kube/config"

            kapp delete -a cf --yes
            ''

      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "delete-cf"
            , config =
                Concourse.Types.TaskSpec.Config
                  Concourse.schemas.TaskConfig::{
                  , image_resource =
                      ../helpers/image-resource.dhall
                        "relintdockerhubpushbot/cf-for-k8s-ci"
                  , inputs =
                      Some [ Concourse.schemas.TaskInput::{ name = "kube" } ]
                  , run = ../helpers/bash-script-task.dhall script
                  }
            }

in  task
