let Concourse = ../deps/concourse.dhall

let Step = Concourse.Types.Step

let Prelude = ../deps/prelude.dhall

let Opt = Prelude.Optional

let Map = Prelude.Map

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let ImageReq = ../types/update-version-image-requirements.dhall

let JobReqs =
      { writeableEiriniReleaseRepo : Concourse.Types.Resource
      , ciResources : Concourse.Types.Resource
      , repo : Concourse.Types.Resource
      , componentName : Text
      , image1 : ImageReq
      , image2 : Optional ImageReq
      , image3 : Optional ImageReq
      , upstreamJob : Text
      }

in    λ(reqs : JobReqs)
    → let triggerOnRepo =
            ../helpers/get-trigger-passed.dhall reqs.repo [ reqs.upstreamJob ]
      
      let triggerOnNewImage =
              λ(image : Concourse.Types.Resource)
            → Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = image
                , trigger = Some True
                , passed = Some [ reqs.upstreamJob ]
                , params =
                    Some (toMap { skip_download = Prelude.JSON.bool True })
                }
      
      let optionalTriggerOn =
              λ(optImage : Optional ImageReq)
            → Opt.fold
                ImageReq
                optImage
                (List Step)
                (λ(i : ImageReq) → [ triggerOnNewImage i.docker ])
                ([] : List Step)
      
      let optionalDockerInputMapping =
              λ(optImage : Optional ImageReq)
            → Opt.fold
                ImageReq
                optImage
                (Map.Type Text Text)
                (λ(i : ImageReq) → toMap { image2 = i.docker.name })
                ([] : Map.Type Text Text)
      
      let optionalName =
              λ(optImage : Optional ImageReq)
            → Opt.fold ImageReq optImage Text (λ(i : ImageReq) → i.name) ""
      
      in  Concourse.schemas.Job::{
          , name = "update-${reqs.componentName}-version-files"
          , plan =
              [ in_parallel
                  (   [ ../helpers/get.dhall reqs.writeableEiriniReleaseRepo
                      , ../helpers/get.dhall reqs.ciResources
                      , triggerOnRepo
                      , triggerOnNewImage reqs.image1.docker
                      ]
                    # optionalTriggerOn reqs.image2
                    # optionalTriggerOn reqs.image3
                  )
              , Concourse.helpers.taskStep
                  Concourse.schemas.TaskStep::{
                  , task = "update-version-files"
                  , config = taskFile reqs.ciResources "update-image-digests"
                  , input_mapping =
                      Some
                        (   toMap
                              { image-code-repository = reqs.repo.name
                              , image1 = reqs.image1.docker.name
                              }
                          # optionalDockerInputMapping reqs.image2
                          # optionalDockerInputMapping reqs.image3
                        )
                  , params =
                      Some
                        ( toMap
                            { IMAGE1_NAME = reqs.image1.name
                            , IMAGE2_NAME = optionalName reqs.image2
                            , IMAGE3_NAME = optionalName reqs.image3
                            , COMPONENT_NAME = reqs.componentName
                            }
                        )
                  }
              ]
          }
