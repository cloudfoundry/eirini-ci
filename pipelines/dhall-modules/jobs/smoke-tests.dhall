let Concourse = ../deps/concourse.dhall

let SmokeTestRequirements = ../deployment-requirements.dhall

let taskFile = ../helpers/task-file.dhall

let runSmokeTests =
        λ(reqs : SmokeTestRequirements)
      →   Concourse.defaults.Job
        ⫽ { name = "run-smoke-tests-${reqs.clusterName}"
          , serial_groups = Some [ reqs.clusterName ]
          , plan =
              [ ../helpers/get.dhall reqs.ciResources
              , ../helpers/get.dhall reqs.clusterState
              , ../helpers/get.dhall reqs.smokeTestsResource
              , Concourse.helpers.taskStep
                  Concourse.schemas.TaskStep::{
                  , task = "run smoke tests"
                  , config = taskFile reqs.smokeTestsResource "run-smoke-tests"
                  , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
                  }
              ]
          }

in  runSmokeTests
