let Concourse = ../dhall-modules/deps/concourse.dhall

let ciResources = ../dhall-modules/resources/ci-resources.dhall "master"

let script =
      ''
      set -euo pipefail

      find "${ciResources.name}" -name pipeline.dhall -type f | xargs -n 1 -t dhall type --quiet --file
      echo "✅ Pipeline is fine ✅"
      ''

let job =
      Concourse.schemas.Job::{
      , name = "check-dhall"
      , plan =
          [ ../dhall-modules/helpers/get-trigger.dhall ciResources
          , Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "check-dhall"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../dhall-modules/helpers/image-resource.dhall
                          "eirini/dhall"
                    , inputs =
                        Some
                          [ { name = ciResources.name
                            , path = None Text
                            , optional = None Bool
                            }
                          ]
                    , run =
                        ../dhall-modules/helpers/bash-script-task.dhall script
                    }
              }
          ]
      }

let jobs = [ ../dhall-modules/helpers/slack-on-fail-job.dhall job ]

in  Concourse.render.pipeline jobs
