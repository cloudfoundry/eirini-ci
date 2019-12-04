let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let StagingTestRequirements = ../types/run-staging-test-requirements.dhall

let triggerOnGolangLint = ../helpers/trigger-on-golang-lint.dhall

let runTestsJob =
        λ(reqs : StagingTestRequirements)
      → let triggerOnEiriniStaging =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.eiriniStagingRepo
                , trigger = Some True
                }

        let getCIResources =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{ resource = reqs.ciResources }

        let unitTestInput =
              { name = "eirini-staging"
              , optional = None Bool
              , path = None Text
              }

        let unitTestsConfig =
              Concourse.Types.TaskSpec.Config
                Concourse.schemas.TaskConfig::{
                , run =
                    Concourse.schemas.TaskRunConfig::{
                    , path = "scripts/test.sh"
                    , dir = Some "eirini-staging"
                    }
                , image_resource = ../helpers/image-resource.dhall "eirini/ci"
                , inputs = Some [ unitTestInput ]
                }

        let runUnitTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-unit-tests"
                , config = unitTestsConfig
                }

        let runStaticChecks =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "lint"
                , config = taskFile reqs.ciResources "run-static-checks"
                , input_mapping = Some (toMap { eirini = "eirini-staging" })
                }

        let integrationTestRun =
              Concourse.schemas.TaskRunConfig::{
              , path = "ginkgo"
              , dir = Some "eirini-staging"
              , args = Some [ "-mod=vendor", "-r", "integration" ]
              }

        let runIntegrationTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-integration-test"
                , config =
                    Concourse.Types.TaskSpec.Config
                      Concourse.schemas.TaskConfig::{
                      , run = integrationTestRun
                      , image_resource =
                          ../helpers/image-resource.dhall
                            "eirinistaging/eirini-na-ci-test"
                      , inputs =
                          Some
                            [ { name = "eirini-staging"
                              , optional = None Bool
                              , path = None Text
                              }
                            ]
                      }
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
