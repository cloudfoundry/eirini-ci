let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(varsDir : Text)
      → let script =
              ''
              set -euo pipefail

              SMOKE_TEST_API_ENDPOINT=api.$(cat ${varsDir}/smoke-test-api-endpoint)
              SMOKE_TEST_PASSWORD=$(cat ${varsDir}/smoke-test-password)
              SMOKE_TEST_APPS_DOMAIN=$(cat ${varsDir}/smoke-test-apps-domain)

              export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_API_ENDPOINT

              tar xzvf ${cfForK8s.name}/source.tar.gz -C .
              sha="$(<${cfForK8s.name}/commit_sha)"
              src_folder="cloudfoundry-cf-for-k8s-''${sha:0:7}"
              cd $src_folder/tests/smoke
              ginkgo -v -r
              ''

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "run smoke tests"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-test-runner"
                    , inputs = Some
                      [ Concourse.schemas.TaskInput::{ name = cfForK8s.name }
                      , Concourse.schemas.TaskInput::{ name = varsDir }
                      ]
                    , run = ../helpers/bash-script-task.dhall script
                    , params = Some
                      [ { mapKey = "SMOKE_TEST_USERNAME"
                        , mapValue = Some "admin"
                        }
                      , { mapKey = "SMOKE_TEST_SKIP_SSL"
                        , mapValue = Some "true"
                        }
                      ]
                    }
              }

in  task
