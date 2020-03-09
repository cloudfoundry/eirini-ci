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
              SMOKE_TEST_USERNAME=admin

              export SMOKE_TEST_APPS_DOMAIN SMOKE_TEST_PASSWORD SMOKE_TEST_USERNAME SMOKE_TEST_API_ENDPOINT
              cd ${cfForK8s.name}/tests/smoke
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
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          , Concourse.schemas.TaskInput::{ name = varsDir }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              }

in  task