let Concourse = ../deps/concourse.dhall

let Step = Concourse.Types.Step

let Prelude = ../deps/prelude.dhall

let in_parallel = Concourse.helpers.inParallelStepSimple

let ImageReq = ../types/update-version-image-requirements.dhall

let JobReqs =
      { repo : Concourse.Types.Resource
      , componentName : Text
      , images : List ImageReq
      , upstreamJob : Text
      }

in    λ(writeableEiriniReleaseRepo : Concourse.Types.Resource)
    → λ(failureNotification : Optional Concourse.Types.Step)
    → λ(reqs : JobReqs)
    → let triggerOnRepo =
            ../helpers/get-trigger-passed.dhall reqs.repo [ reqs.upstreamJob ]
      
      let triggerOnNewImage =
              λ(imageReq : ImageReq)
            → Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = imageReq.docker
                , trigger = Some True
                , passed = Some [ reqs.upstreamJob ]
                , params =
                    Some (toMap { skip_download = Prelude.JSON.bool True })
                }
      
      let triggerOnNewImages =
            Prelude.List.map ImageReq Step triggerOnNewImage reqs.images
      
      in  Concourse.schemas.Job::{
          , name = "update-${reqs.componentName}-version-files"
          , on_failure = failureNotification
          , plan =
              [ in_parallel
                  (   [ ../helpers/get.dhall writeableEiriniReleaseRepo
                      , triggerOnRepo
                      ]
                    # triggerOnNewImages
                  )
              , ../tasks/update-image-digest.dhall
                  writeableEiriniReleaseRepo
                  reqs
              , Concourse.helpers.putStep
                  Concourse.schemas.PutStep::{
                  , resource = writeableEiriniReleaseRepo
                  , params =
                      Some
                        ( toMap
                            { repository =
                                Prelude.JSON.string "eirini-release-updated"
                            }
                        )
                  }
              ]
          }
