let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

let gitResource
    : Text → Text → Optional Text → Text → Concourse.Types.Resource
    =   λ(name : Text)
      → λ(uri : Text)
      → λ(key : Optional Text)
      → λ(branch : Text)
      → Concourse.schemas.Resource::{
        , name = name
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , icon = Some "git"
        , source =
            Some
              ( toMap
                  { uri = JSON.string uri
                  , branch = JSON.string branch
                  , private_key =
                      Optional/fold Text key JSON.Type JSON.string JSON.null
                  }
              )
        }

in  gitResource
