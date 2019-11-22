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

      let baseImage =
            ../helpers/docker-resource-no-creds.dhall
              "fluentd-image"
              "fluent/fluentd-kubernetes-daemonset"
              (Some "v1-debian-elasticsearch")

      let triggerOnBaseImage =
            Concourse.helpers.getStep
              Concourse.schemas.GetStep::{
              , resource = baseImage
              , trigger = Some True
              , params = Some (toMap { skip_download = Prelude.JSON.bool True })
              }

      let putDocker =
            Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = reqs.dockerFluentd
              , params =
                  Some
                    ( toMap
                        { build = Prelude.JSON.string "${gitRepo.name}/fluentd"
                        , build_args_file =
                            Prelude.JSON.string "docker-build-args/args.json"
                        }
                    )
              }

      in  Concourse.schemas.Job::{
          , name = "create-fluentd-docker-image"
          , plan =
              [ in_parallel
                  [ ../helpers/get.dhall reqs.ciResources
                  , triggerOnFluentdRepo
                  , triggerOnBaseImage
                  ]
              , ../tasks/make-docker-build-args.dhall reqs.ciResources gitRepo
              , putDocker
              ]
          }
