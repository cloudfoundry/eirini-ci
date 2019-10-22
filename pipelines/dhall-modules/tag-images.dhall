let Concourse = ./deps/concourse.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let Prelude = ./deps/prelude.dhall

let tagImagesJob =
        λ(reqs : ./tag-images-requirements.dhall)
      → let triggerOnEirini =
              ./helpers/get-trigger-passed.dhall
                reqs.eiriniResource
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
        
        let updateImage =
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
                        reqs.dockerSecretSmuggler
                        "create-secret-smuggler-docker-image"
                    , getDockerImage
                        reqs.dockerFluentd
                        "create-fluentd-docker-image"
                    , putDeploymentVersion
                    ]
                , in_parallel
                    [ updateImage reqs.dockerOPI
                    , updateImage reqs.dockerRootfsPatcher
                    , updateImage reqs.dockerBitsWaiter
                    , updateImage reqs.dockerSecretSmuggler
                    , updateImage reqs.dockerFluentd
                    ]
                ]
            }

in  λ(reqs : ./tag-images-requirements.dhall) → [ tagImagesJob reqs ]
