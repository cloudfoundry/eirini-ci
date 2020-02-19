let Concourse = ../deps/concourse.dhall

let task =
        λ(cf4k8s : Concourse.Types.Resource)
      → λ(eiriniRelease : Concourse.Types.Resource)
      → let script =
              ''
              set -euo pipefail

              rm -rf ${cf4k8s.name}/build/eirini/_vendir/eirini
              cp -r ${eiriniRelease.name}/helm/eirini  ${cf4k8s.name}/build/eirini/_vendir/

              ./${cf4k8s.name}/build/eirini/build.sh

              cp -r ${cf4k8s.name}/* patched-cf-for-k8s/
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "patch-eirini-release"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-for-k8s-ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{ name = cf4k8s.name }
                          , Concourse.schemas.TaskInput::{
                            , name = eiriniRelease.name
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "patched-cf-for-k8s"
                            }
                          ]
                    }
              }

in  task
