let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(reqs : ../types/bump-go-requirements.dhall)
    → Concourse.schemas.Job::{
      , name = "merge-bump"
      , plan =
          [ ../helpers/get-trigger-passed.dhall
              reqs.testEiriniBranch
              [ "run-core-cats-${reqs.clusterName}" ]
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = reqs.eiriniMaster
              , params =
                  Some
                    ( toMap
                        { repository = JSON.string reqs.testEiriniBranch.name }
                    )
              }
          ]
      }
