let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

in    λ(versionResource : Concourse.Types.Resource)
    → λ(versionType : Text)
    → λ(autoBump : ../types/auto-bump-version.dhall)
    → let getAndBump =
            Concourse.helpers.getStep
              Concourse.schemas.GetStep::{
              , resource = versionResource
              , params = Some (toMap { bump = JSON.string versionType })
              , passed =
                  merge
                    { NoAutoBump = None (List Text)
                    , AutoBumpOn = λ(upstream : Text) → Some [ upstream ]
                    }
                    autoBump
              , trigger =
                  merge
                    { NoAutoBump = Some False
                    , AutoBumpOn = λ(_ : Text) → Some True
                    }
                    autoBump
              }

      let put =
            Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = versionResource
              , params =
                  Some
                    ( toMap
                        { file = JSON.string "${versionResource.name}/version" }
                    )
              }

      in  Concourse.schemas.Job::{
          , name = "bump-${versionType}-version"
          , plan = [ getAndBump, put ]
          }
