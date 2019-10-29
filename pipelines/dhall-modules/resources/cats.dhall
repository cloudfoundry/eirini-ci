let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in  Concourse.schemas.Resource::{
    , name = "cats"
    , type = Concourse.Types.ResourceType.InBuilt "git"
    , icon = Some "git"
    , source =
        Some
          ( toMap
              { uri =
                  JSON.string
                    "https://github.com/cloudfoundry/cf-acceptance-tests.git"
              }
          )
    }
