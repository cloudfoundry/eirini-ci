let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(eiriniReleaseRepo : Concourse.Types.Resource)
    → λ(passed : List Text)
    → λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = "un${lock.name}"
      , serial = Some True
      , plan =
          [ ../helpers/get-trigger-passed.dhall eiriniReleaseRepo passed
          , ../helpers/get-trigger-passed.dhall lock passed
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { release = JSON.string lock.name })
              }
          ]
      }
