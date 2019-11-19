let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(reqs : ../types/deployment-requirements.dhall)
    → λ(passed : List Text)
    → λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = "unlock-${reqs.clusterName}"
      , serial = Some True
      , plan =
          [ ../helpers/get-trigger-passed.dhall reqs.eiriniReleaseRepo passed
          , ../helpers/get-trigger-passed.dhall lock passed
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params =
                  Some
                    (toMap { release = JSON.string "lock-${reqs.clusterName}" })
              }
          ]
      }
