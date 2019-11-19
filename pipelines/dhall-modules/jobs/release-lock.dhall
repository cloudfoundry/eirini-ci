let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(reqs : ../types/deployment-requirements.dhall)
    → λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = "release-lock-${reqs.clusterName}"
      , plan =
          [ ../helpers/get.dhall lock
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params =
                  Some
                    (toMap { release = JSON.string "lock-${reqs.clusterName}" })
              }
          ]
      }
