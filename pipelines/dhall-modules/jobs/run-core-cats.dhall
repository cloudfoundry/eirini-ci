let Concourse = ../deps/concourse.dhall

let Requirements = ../types/deployment-requirements.dhall

let TaggedImageRequirements = ../types/deploy-tagged-requirements.dhall

let ImageLocation = ../types/image-location.dhall

let Prelude = ../deps/prelude.dhall

let taskFile = ../helpers/task-file.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let runCoreCats =
        λ ( reqs
          : Requirements
          )
      → let stepsForInRepo =
              λ(ignored : {}) → [] : List Concourse.Types.Step
        
        let upstreamJobs = [ "run-smoke-tests-${reqs.clusterName}" ]
        
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
        
        let getSteps =
                getImageLocationDependentSteps reqs.imageLocation
              # [ triggerOnEiriniRelease
                , ../helpers/get.dhall reqs.ciResources
                , ../helpers/get-named.dhall reqs.clusterState "state"
                , ../helpers/get.dhall ../resources/cats.dhall
                ]
        
        let catsParams =
              toMap
                { CLUSTER_NAME =
                    reqs.clusterName
                , INCLUDE_APPS = "true"
                , INCLUDE_BACKEND_COMPATIBILITY = "false"
                , INCLUDE_CAPI_EXPERIMENTAL = "true"
                , INCLUDE_CAPI_NO_BRIDGE = "true"
                , INCLUDE_CONTAINER_NETWORKING = "true"
                , INCLUDE_CREDHUB = "false"
                , INCLUDE_DEPLOYMENTS = "false"
                , INCLUDE_DETECT = "true"
                , INCLUDE_DOCKER = "false"
                , INCLUDE_INTERNET_DEPENDENT = "true"
                , INCLUDE_ISOLATION_SEGMENTS = "false"
                , INCLUDE_PRIVATE_DOCKER_REGISTRY = "false"
                , INCLUDE_ROUTE_SERVICES = "false"
                , INCLUDE_ROUTING = "true"
                , INCLUDE_ROUTING_ISOLATION_SEGMENTS = "false"
                , INCLUDE_SECURITY_GROUPS = "false"
                , INCLUDE_SERVICES = "false"
                , INCLUDE_SERVICE_DISCOVERY = "false"
                , INCLUDE_SERVICE_INSTANCE_SHARING = "false"
                , INCLUDE_SSH = "false"
                , INCLUDE_SSO = "true"
                , INCLUDE_TASKS = "false"
                , INCLUDE_V3 = "false"
                , INCLUDE_ZIPKIN = "true"
                , NO_OF_TEST_NODES = "16"
                , SKIPPED_TESTS =
                    Prelude.Optional.default
                      Text
                      "uses the buildpack cache after first staging|reverse log proxy streams logs"
                      reqs.skippedCats
                , SKIP_SSL_VALIDATION = "true"
                , USE_HTTP = "true"
                , USE_LOG_CACHE = "false"
                }
        
        in  Concourse.schemas.Job::{
            , name = "run-core-cats-${reqs.clusterName}"
            , serial_groups = Some [ reqs.clusterName ]
            , public = Some True
            , plan =
                [ in_parallel getSteps
                , Concourse.helpers.taskStep
                    Concourse.schemas.TaskStep::{
                    , task = "run core cats"
                    , config = taskFile reqs.ciResources "run-cats"
                    , params = Some catsParams
                    }
                ]
            }

in  runCoreCats
