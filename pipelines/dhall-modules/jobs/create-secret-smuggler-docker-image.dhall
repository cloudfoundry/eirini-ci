let Concourse = ../deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let Prelude = ../deps/prelude.dhall

in    λ ( reqs
        : ../types/run-test-requirements.dhall
        )
    → let gitRepo =
            ../helpers/eirini-or-repo-get-repo.dhall
              reqs.eiriniRepo
              reqs.secretSmugglerRepo
      
      let makeDockerBuildArgs =
            ../tasks/make-docker-build-args.dhall reqs.ciResources gitRepo
      
      in  Concourse.schemas.Job::{
          , name = "create-secret-smuggler-docker-image"
          , plan =
              [ in_parallel
                  [ ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get-trigger.dhall gitRepo
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
                                  "${gitRepo.name}/docker/registry/certs/smuggler"
                            , build_args_file =
                                Prelude.JSON.string
                                  "docker-build-args/args.json"
                            }
                        )
                  }
              ]
          , on_failure = reqs.failureNotification
          }
