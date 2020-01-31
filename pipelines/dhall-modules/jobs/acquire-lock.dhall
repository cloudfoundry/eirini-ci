let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(eiriniReleaseRepo : Concourse.Types.Resource)
    → λ(lock : Concourse.Types.Resource)
    → λ(getTrigger : Concourse.Types.Step)
    → Concourse.schemas.Job::{
      , name = lock.name
      , serial = Some True
      , plan =
          [ getTrigger
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { acquire = JSON.bool True })
              }
          ]
      }
