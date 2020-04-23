let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(eiriniRelease : Concourse.Types.Resource)
      → let script =
              ''
              set -euo pipefail

              tar xzvf ${cfForK8s.name}/source.tar.gz -C .
              sha="$(<${cfForK8s.name}/commit_sha)"
              src_folder="cloudfoundry-cf-for-k8s-''${sha:0:7}"
              rm -rf $src_folder/build/eirini/_vendir/eirini
              cp -r ${eiriniRelease.name}/helm/eirini  $src_folder/build/eirini/_vendir/

              ./$src_folder/build/eirini/build.sh

              cp -r $src_folder/* patched-cf-for-k8s/
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
                    , inputs = Some
                      [ Concourse.schemas.TaskInput::{ name = cfForK8s.name }
                      , Concourse.schemas.TaskInput::{
                        , name = eiriniRelease.name
                        }
                      ]
                    , run = ../helpers/bash-script-task.dhall script
                    , outputs = Some
                      [ Concourse.schemas.TaskOutput::{
                        , name = "patched-cf-for-k8s"
                        }
                      ]
                    }
              }

in  task
