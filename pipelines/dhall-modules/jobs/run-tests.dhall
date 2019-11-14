let Concourse = ../deps/concourse.dhall

let do = Concourse.helpers.doStep

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let RunTestRequirements = ../types/run-test-requirements.dhall

let triggerOnGolangLint = ../helpers/trigger-on-golang-lint.dhall

let getTrigger = ../helpers/get-trigger.dhall

let getTriggerPassed = ../helpers/get-trigger-passed.dhall

let runTestsJob =
        λ(reqs : RunTestRequirements)
      → let triggerOnClusterReady =
              getTriggerPassed
                reqs.upstream.event
                [ "${reqs.upstream.name}-${reqs.clusterName}" ]
        
        let triggerOnEirini = getTrigger reqs.eiriniRepo
        
        let triggerOnSampleConfigs = getTrigger reqs.sampleConfigs
        
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
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds
        
        let runIntegrationTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-integration-tests"
                , config = taskFile reqs.ciResources "run-integration-tests"
                }
        
        in    Concourse.defaults.Job
            ⫽ { name = "run-tests"
              , public = Some True
              , on_failure = reqs.failureNotification
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
