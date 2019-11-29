let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(privateKey : Text)
    → Concourse.schemas.Resource::{
      , name = "eirini-release-version"
      , type = Concourse.Types.ResourceType.InBuilt "semver"
      , icon = Some "counter"
      , source =
          Some
            ( toMap
                { driver = JSON.string "git"
                , uri =
                    JSON.string
                      "git@github.com:cloudfoundry/eirini-private-config.git"
                , branch = JSON.string "master"
                , file = JSON.string "release-version"
                , private_key = JSON.string privateKey
                , initial_version = JSON.string "0.1.0"
                }
            )
      }
