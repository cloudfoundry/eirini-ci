let Concourse = ./deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let in_parallel_with_limit = ./helpers/in_parallel_with_limit.dhall 5

let Prelude = ./deps/prelude.dhall

let tagImagesJob =
        λ(reqs : ./types/tag-images-requirements.dhall)
      → let triggerOnEirini =
              ./helpers/get-trigger-passed.dhall
                reqs.eiriniRepo
                [ "create-go-docker-images"
                , "create-secret-smuggler-docker-image"
                , "create-fluentd-docker-image"
                ]

        let getDockerImage =
                λ(resource : Concourse.Types.Resource)
              → λ(passed : Text)
              → Concourse.helpers.getStep
                  Concourse.schemas.GetStep::{
                  , resource = resource
                  , passed = Some [ passed ]
                  , params = Some (toMap { save = Prelude.JSON.bool True })
                  }

        let putDeploymentVersion =
              Concourse.helpers.putStep
                Concourse.schemas.PutStep::{
                , resource = reqs.deploymentVersion
                , params =
                    Some (toMap { pre = Prelude.JSON.string reqs.worldName })
                }

        let putImageWithTag =
                λ(resource : Concourse.Types.Resource)
              → Concourse.helpers.putStep
                  Concourse.schemas.PutStep::{
                  , resource = resource
                  , params =
                      Some
                        ( toMap
                            { additional_tags =
                                Prelude.JSON.string "deployment-version/version"
                            , load = Prelude.JSON.string resource.name
                            }
                        )
                  }

        in  Concourse.schemas.Job::{
            , name = "tag-images"
            , plan =
                [ in_parallel
                    [ triggerOnEirini
                    , getDockerImage reqs.dockerOPI "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerRootfsPatcher
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerBitsWaiter
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerRouteCollector
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerRoutePodInformer
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerRouteStatefulsetInformer
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerMetricsCollector
                        "create-go-docker-images"
                    , getDockerImage
                        reqs.dockerSecretSmuggler
                        "create-secret-smuggler-docker-image"
                    , getDockerImage
                        reqs.dockerFluentd
                        "create-fluentd-docker-image"
                    , putDeploymentVersion
                    ]
                , in_parallel_with_limit
                    [ putImageWithTag reqs.dockerOPI
                    , putImageWithTag reqs.dockerRootfsPatcher
                    , putImageWithTag reqs.dockerBitsWaiter
                    , putImageWithTag reqs.dockerSecretSmuggler
                    , putImageWithTag reqs.dockerFluentd
                    , putImageWithTag reqs.dockerRouteCollector
                    , putImageWithTag reqs.dockerRoutePodInformer
                    , putImageWithTag reqs.dockerRouteStatefulsetInformer
                    , putImageWithTag reqs.dockerMetricsCollector
                    ]
                ]
            }

in    λ(reqs : ./types/tag-images-requirements.dhall)
    → ./helpers/group-jobs.dhall [ "tag-images" ] [ tagImagesJob reqs ]
