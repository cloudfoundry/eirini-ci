let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(eiriniReleaseRepo : Concourse.Types.Resource)
    → λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = lock.name
      , serial = Some True
      , plan =
          [ ../helpers/get-trigger-passed.dhall
              eiriniReleaseRepo
              [ "helm-lint" ]
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { acquire = JSON.bool True })
              }
          ]
      }
