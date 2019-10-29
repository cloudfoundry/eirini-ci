let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let runFluentdUnitTests =
        λ(reqs : ../types/run-test-requirements.dhall)
      → Concourse.schemas.Job::{
        , name = "run-fluentd-unit-tests"
        , plan =
            [ in_parallel
                [ ../helpers/get.dhall reqs.ciResources
                , ../helpers/get-trigger.dhall reqs.fluentdRepo
                ]
            , Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-unit-tests"
                , config = taskFile reqs.ciResources "run-fluentd-tests"
                , input_mapping =
                    Some (toMap { eirini = reqs.fluentdRepo.name })
                }
            ]
        }

in  runFluentdUnitTests
