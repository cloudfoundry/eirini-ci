let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let Prelude = ../deps/prelude.dhall

in    λ ( reqs
        : ../types/run-test-requirements.dhall
        )
    → let makeDockerBuildArgs =
            ../tasks/make-docker-build-args.dhall
              reqs.ciResources
              reqs.eiriniSecretSmuggler
      
      in  Concourse.schemas.Job::{
          , name = "create-secret-smuggler-docker-image"
          , plan =
              [ in_parallel
                  [ ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get-trigger.dhall reqs.eiriniSecretSmuggler
                  ]
              , makeDockerBuildArgs
              , Concourse.helpers.putStep
                  Concourse.schemas.PutStep::{
                  , resource = reqs.dockerSecretSmuggler
                  , params =
                      Some
                        ( toMap
                            { build =
                                Prelude.JSON.string
                                  "${reqs.eiriniSecretSmuggler.name}/docker/registry/certs/smuggler"
                            , build_args_file =
                                Prelude.JSON.string
                                  "docker-build-args/args.json"
                            }
                        )
                  }
              ]
          }
