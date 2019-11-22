let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let runFluentdUnitTests =
        λ(reqs : ../types/run-test-requirements.dhall)
      → let gitResource =
              ../helpers/eirini-or-repo-get-repo.dhall
                reqs.eiriniRepo
                reqs.fluentdRepo

        let inputMapping =
              merge
                { UseEirini = None (Prelude.Map.Type Text Text)
                , UseRepo =
                      λ(r : Concourse.Types.Resource)
                    → Some (toMap { eirini = r.name })
                }
                reqs.fluentdRepo

        in  Concourse.schemas.Job::{
            , name = "run-fluentd-unit-tests"
            , plan =
                [ in_parallel
                    [ ../helpers/get.dhall reqs.ciResources
                    , ../helpers/get-trigger.dhall gitResource
                    ]
                , Concourse.helpers.taskStep
                    Concourse.schemas.TaskStep::{
                    , task = "run-unit-tests"
                    , config = taskFile reqs.ciResources "run-fluentd-tests"
                    , input_mapping = inputMapping
                    }
                ]
            }

in  runFluentdUnitTests
