let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(name : Text)
    → λ(privateKey : Text)
    → Concourse.schemas.Resource::{
      , name = "lock-${name}"
      , type = Concourse.Types.ResourceType.InBuilt "pool"
      , icon = Some "lock"
      , source =
          Some
            ( toMap
                { uri =
                    JSON.string
                      "git@github.com:cloudfoundry/eirini-private-config.git"
                , branch = JSON.string "ci-locks"
                , pool = JSON.string name
                , private_key = JSON.string privateKey
                }
            )
      }
