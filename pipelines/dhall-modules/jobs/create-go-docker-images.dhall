let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let Prelude = ../deps/prelude.dhall

let RunTestRequirements = ../types/run-test-requirements.dhall

let getTriggerPassed = ../helpers/get-trigger-passed.dhall

let get = ../helpers/get.dhall

let putDocker =
        λ(resource : Concourse.Types.Resource)
      → λ(dockerfile : Text)
      → Concourse.helpers.putStep
          Concourse.schemas.PutStep::{
          , resource = resource
          , params =
              Some
                ( toMap
                    { build = Prelude.JSON.string "eirini"
                    , dockerfile =
                        Prelude.JSON.string
                          "eirini/docker/${dockerfile}/Dockerfile"
                    , build_args_file =
                        Prelude.JSON.string "docker-build-args/args.json"
                    }
                )
          }

let createGoDockerImages =
        λ(reqs : RunTestRequirements)
      → let makeDockerBuildArgs =
              ../tasks/make-docker-build-args.dhall
                reqs.ciResources
                reqs.eiriniResource
        
        in  Concourse.schemas.Job::{
            , name = "create-go-docker-images"
            , plan =
                [ in_parallel
                    [ getTriggerPassed reqs.eiriniResource [ "run-tests" ]
                    , get reqs.ciResources
                    ]
                , makeDockerBuildArgs
                , in_parallel
                    [ putDocker reqs.dockerOPI "opi"
                    , putDocker reqs.dockerBitsWaiter "bits-waiter"
                    , putDocker reqs.dockerRootfsPatcher "rootfs-patcher"
                    ]
                ]
            }

in  createGoDockerImages
