let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let StagingTestRequirements = ../types/run-staging-test-requirements.dhall

let golangLintResource =
      Concourse.schemas.Resource::{
      , name = "golang-lint"
      , type = Concourse.Types.ResourceType.InBuilt "docker-image"
      , icon = Some "docker"
      , source =
          Some
            ( toMap
                { repository = Prelude.JSON.string "golangci/golangci-lint"
                , tag = Prelude.JSON.string "latest"
                }
            )
      }

let runTestsJob =
        λ(reqs : StagingTestRequirements)
      → let triggerOnEiriniStaging =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.eiriniStaging
                , trigger = Some True
                }
        
        let triggerOnGolangLint =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = golangLintResource
                , trigger = Some True
                , params =
                    Some (toMap { skip_download = Prelude.JSON.bool True })
                }
        
        let getCIResources =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{ resource = reqs.ciResources }
        
        let runUnitTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-unit-tests"
                , config = taskFile reqs.ciResources "run-unit-tests"
                }
        
        let runStaticChecks =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "lint"
                , config = taskFile reqs.ciResources "run-static-checks"
                }
        
        let runIntegrationTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-integration-test"
                , config = taskFile reqs.ciResources "run-integration-tests"
                }
        
        in    Concourse.defaults.Job
            ⫽ { name = "staging-test"
              , plan =
                  [ in_parallel
                      [ triggerOnEiriniStaging
                      , triggerOnGolangLint
                      , getCIResources
                      ]
                  , in_parallel
                      [ runUnitTests, runStaticChecks, runIntegrationTests ]
                  ]
              }

in  runTestsJob
