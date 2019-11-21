let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(repo : Concourse.Types.Resource)
    → λ(master : Concourse.Types.Resource)
    → λ(upstreamSteps : List Text)
    → Concourse.schemas.Job::{
      , name = "fast-forward-master-relase"
      , plan =
          [ ../helpers/get-trigger-passed.dhall repo upstreamSteps
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = master
              , params =
                  Some (toMap { repository = JSON.string "eirini-release" })
              }
          ]
      }
