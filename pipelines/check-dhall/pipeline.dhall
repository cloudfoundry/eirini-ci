let Concourse = ../dhall-modules/deps/concourse.dhall

let ciResources = ../dhall-modules/resources/ci-resources.dhall "master"

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
                        Concourse.schemas.TaskRunConfig::{
                        , path = "bash"
                        , args =
                            Some
                              [ "-c"
                              , ''
                                set -euo pipefail

                                find "${ciResources.name}" -name pipeline.dhall -type f | xargs -n 1 -t dhall type --quiet --file
                                echo "✅ Pipeline is fine ✅"
                                ''
                              ]
                        }
                    }
              }
          ]
      }

in  ../dhall-modules/helpers/slack_on_fail.dhall [ job ]
