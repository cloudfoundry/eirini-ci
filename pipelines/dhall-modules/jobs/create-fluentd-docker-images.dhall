let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

in    λ(reqs : ../run-test-requirements.dhall)
    → let triggerOnFluentdRepo =
            ../helpers/get-trigger-passed.dhall
              reqs.fluentdRepo
              [ "run-fluentd-unit-tests" ]
      
      let baseImage =
            Concourse.schemas.Resource::{
            , name = "fluentd-image"
            , type = Concourse.Types.ResourceType.InBuilt "docker-image"
            , icon = Some "docker"
            , source =
                Some
                  ( toMap
                      { repository =
                          Prelude.JSON.string
                            "fluent/fluentd-kubernetes-daemonset"
                      , tag = Prelude.JSON.string "v1-debian-elasticsearch"
                      }
                  )
            }
      
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
                        { build = Prelude.JSON.string "eirini-fluentd"
                        , build_args_file =
                            Prelude.JSON.string "docker-build-args/args.json"
                        }
                    )
              }
      
      in  Concourse.schemas.Job::{
          , name = "create-fluentd-docker-images"
          , plan =
              [ in_parallel
                  [ ../helpers/get.dhall reqs.ciResources
                  , triggerOnFluentdRepo
                  , triggerOnBaseImage
                  ]
              , ../tasks/make-docker-build-args.dhall
                  reqs.ciResources
                  reqs.fluentdRepo
              , putDocker
              ]
          }
