let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let Prelude = ../deps/prelude.dhall

let RunStagingTestRequirements = ../types/run-staging-test-requirements.dhall

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
                    { build = Prelude.JSON.string "eirini-staging"
                    , dockerfile =
                        Prelude.JSON.string
                          "eirini-staging/image/${dockerfile}/Dockerfile"
                    , build_args_file =
                        Prelude.JSON.string "docker-build-args/args.json"
                    }
                )
          }

let createGoDockerImages =
        λ(reqs : RunStagingTestRequirements)
      → let makeDockerBuildArgs =
              ../tasks/make-docker-build-args.dhall
                reqs.ciResources
                reqs.eiriniStagingRepo
        
        in  Concourse.schemas.Job::{
            , name = "create-staging-docker-images"
            , plan =
                [ in_parallel
                    [ getTriggerPassed reqs.eiriniStagingRepo [ "staging-test" ]
                    , get reqs.ciResources
                    ]
                , makeDockerBuildArgs
                , in_parallel
                    [ putDocker reqs.stagingDownloader "downloader"
                    , putDocker reqs.stagingExecutor "executor"
                    , putDocker reqs.stagingUploader "uploader"
                    ]
                ]
            }

in  createGoDockerImages
