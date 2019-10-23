let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

in  Concourse.schemas.Resource::{
    , name = "smoke-tests"
    , type = Concourse.Types.ResourceType.InBuilt "git"
    , icon = Some "git"
    , source =
        Some
          ( toMap
              { uri =
                  Prelude.JSON.string
                    "https://github.com/cloudfoundry/cf-smoke-tests.git"
              , branch = Prelude.JSON.string "master"
              }
          )
    }
