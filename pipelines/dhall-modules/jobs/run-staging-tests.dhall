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
                , resource = reqs.eiriniStagingRepo
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
        
        let unitTestImage =
              Concourse.schemas.ImageResource::{
              , type = "docker-image"
              , source =
                  Some (toMap { repository = Prelude.JSON.string "eirini/ci" })
              }
        
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
                , image_resource = Some unitTestImage
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
        
        let integrationTestImage =
              Concourse.schemas.ImageResource::{
              , type = "docker-image"
              , source =
                  Some
                    ( toMap
                        { repository =
                            Prelude.JSON.string
                              "eirinistaging/eirini-na-ci-test"
                        }
                    )
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
                      , image_resource = Some integrationTestImage
                      , inputs = Some [ { name = "eirini-staging", optional = None Bool, path = None Text }]
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
