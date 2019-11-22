let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = "release-${lock.name}"
      , plan =
          [ ../helpers/get.dhall lock
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { release = JSON.string lock.name })
              }
          ]
      }
