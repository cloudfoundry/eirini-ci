let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

in    λ(resource : Concourse.Types.Resource)
    → Concourse.helpers.putStep
        Concourse.schemas.PutStep::{
        , resource = resource
        , params = Some (toMap { bump = Prelude.JSON.string "major" })
        }
