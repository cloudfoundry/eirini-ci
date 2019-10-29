let Concourse = ../deps/concourse.dhall

let Requirements = ../types/deployment-requirements.dhall

let TaggedImageRequirements = ../types/deploy-tagged-requirements.dhall

let ImageLocation = ../types/image-location.dhall

let taskFile = ../helpers/task-file.dhall

let runSmokeTests =
        λ(reqs : Requirements)
      → let stepsForInRepo = λ(ignored : {}) → [] : List Concourse.Types.Step
        
        let upstreamJobs = [ "deploy-scf-eirini-${reqs.clusterName}" ]
        
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
        
        in  Concourse.schemas.Job::{
            , name = "run-smoke-tests-${reqs.clusterName}"
            , serial_groups = Some [ reqs.clusterName ]
            , plan =
                  getImageLocationDependentSteps reqs.imageLocation
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
