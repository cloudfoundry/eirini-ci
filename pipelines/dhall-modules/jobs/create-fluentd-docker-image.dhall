let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

in    λ(reqs : ../types/run-test-requirements.dhall)
    → let gitRepo =
            ../helpers/eirini-or-repo-get-repo.dhall
              reqs.eiriniRepo
              reqs.fluentdRepo

      let triggerOnFluentdRepo =
            ../helpers/get-trigger-passed.dhall
              gitRepo
              [ "run-fluentd-unit-tests" ]

      let putDocker =
            Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = reqs.dockerFluentd
              , params = Some
                  ( toMap
                      { build = Prelude.JSON.string "${gitRepo.name}"
                      , dockerfile =
                          Prelude.JSON.string
                            "${gitRepo.name}/docker/loggregator-fluentd/Dockerfile"
                      , build_args_file =
                          Prelude.JSON.string "docker-build-args/args.json"
                      }
                  )
              }

      in  Concourse.schemas.Job::{
          , name = "create-fluentd-docker-image"
          , plan =
            [ in_parallel
                [ ../helpers/get.dhall reqs.ciResources, triggerOnFluentdRepo ]
            , ../tasks/make-docker-build-args.dhall reqs.ciResources gitRepo
            , putDocker
            ]
          }
