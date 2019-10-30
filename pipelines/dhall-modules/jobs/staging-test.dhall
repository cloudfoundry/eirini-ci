let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let do = Concourse.helpers.doStep

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

let RunTestRequirements = ../types/run-test-requirements.dhall

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
        λ(reqs : RunTestRequirements)
      → let triggerOnClusterReady =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.upstream.event
                , trigger = Some True
                , passed = Some [ "${reqs.upstream.name}-${reqs.clusterName}" ]
                }
        
        let triggerOnEirini =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.eiriniRepo
                , trigger = Some True
                }
        
        let triggerOnSampleConfigs =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.sampleConfigs
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
                , task = "run-static-checks"
                , config = taskFile reqs.ciResources "run-static-checks"
                }
        
        let downloadKubeconfig =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "download-kubeconfig"
                , config = taskFile reqs.ciResources "download-kubeconfig"
                , params =
                    Some
                      ( toMap
                          (   iksParams reqs.iksCreds
                            ⫽ { CLUSTER_NAME = reqs.clusterName }
                          )
                      )
                }
        
        let runIntegrationTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-integration-tests"
                , config = taskFile reqs.ciResources "run-integration-tests"
                }
        
        in    Concourse.defaults.Job
            ⫽ { name = "run-tests"
              , plan =
                  [ in_parallel
                      [ triggerOnClusterReady
                      , triggerOnEirini
                      , triggerOnSampleConfigs
                      , triggerOnGolangLint
                      , getCIResources
                      ]
                  , in_parallel
                      [ runUnitTests
                      , runStaticChecks
                      , do [ downloadKubeconfig, runIntegrationTests ]
                      ]
                  ]
              }

in  runTestsJob
