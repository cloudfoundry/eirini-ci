let Concourse = ../deps/concourse.dhall

let Requirements = ../types/tests-requirements.dhall

let TaggedImageRequirements = ../types/deploy-tagged-requirements.dhall

let ImageLocation = ../types/image-location.dhall

let taskFile = ../helpers/task-file.dhall

let runSmokeTests =
        λ(reqs : Requirements)
      → let stepsForInRepo = λ(ignored : {}) → [] : List Concourse.Types.Step

        let upstreamJobs = [ reqs.upstreamJob ]

        let stepsForTaggedImages =
                λ(tagReqs : TaggedImageRequirements)
              → [ ../helpers/get-trigger-passed.dhall
                    tagReqs.eiriniRepo
                    upstreamJobs
                ]

        let getImageLocationDependentSteps =
                λ(imageLocation : ImageLocation)
              → merge
                  { InRepo = stepsForInRepo, FromTags = stepsForTaggedImages }
                  imageLocation

        let triggerOnEiriniRelease =
              ../helpers/get-trigger-passed.dhall
                reqs.eiriniReleaseRepo
                upstreamJobs

        let lockSteps = ./steps/lock-steps.dhall reqs.lockResource upstreamJobs

        in  Concourse.schemas.Job::{
            , name = "run-smoke-tests-${reqs.clusterName}"
            , serial_groups = Some [ reqs.clusterName ]
            , public = Some True
            , plan =
                  getImageLocationDependentSteps reqs.imageLocation
                # lockSteps
                # [ triggerOnEiriniRelease
                  , ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get-named.dhall reqs.clusterState "state"
                  , ../helpers/get.dhall reqs.smokeTestsResource
                  , Concourse.helpers.taskStep
                      Concourse.schemas.TaskStep::{
                      , task = "run smoke tests"
                      , config = taskFile reqs.ciResources "run-smoke-tests"
                      , params =
                          Some (toMap { CLUSTER_NAME = reqs.clusterName })
                      }
                  ]
            }

in  runSmokeTests
