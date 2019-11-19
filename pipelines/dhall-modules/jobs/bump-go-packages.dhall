let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

let in_parallel = Concourse.helpers.inParallelStepSimple

let bumpDay = ../resources/go-bump-day.dhall

let taskFile = ../helpers/task-file.dhall

let bumpGoPackages =
        λ(reqs : ../types/bump-go-requirements.dhall)
      → Concourse.schemas.Job::{
        , name = "bump-go-packages"
        , plan =
            [ in_parallel
                [ ../helpers/get-trigger.dhall bumpDay
                , ../helpers/get.dhall reqs.eiriniMaster
                , ../helpers/get.dhall reqs.ciResources
                ]
            , Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "bump-go-packages"
                , config = taskFile reqs.ciResources "bump-go-packages"
                , input_mapping =
                    Some (toMap { repository = reqs.eiriniMaster.name })
                }
            , Concourse.helpers.putStep
                Concourse.schemas.PutStep::{
                , resource = reqs.testEiriniBranch
                , params =
                    Some
                      ( toMap
                          { force = JSON.bool True
                          , repository = JSON.string "repository-updated"
                          }
                      )
                }
            ]
        }

in  bumpGoPackages
