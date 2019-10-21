let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let jsonString = Prelude.JSON.string

let dockerResource =
        λ(name : Text)
      → λ(repository : Text)
      → λ(dockerHubUser : Text)
      → λ(dockerHubPassword : Text)
      → Concourse.schemas.Resource::{
        , name = name
        , type = Concourse.Types.ResourceType.InBuilt "docker-image"
        , icon = Some "docker"
        , source =
            Some
              ( toMap
                  { repository = jsonString repository
                  , tag = jsonString "pipeline"
                  , username = jsonString dockerHubUser
                  , password = jsonString dockerHubPassword
                  }
              )
        }

in  dockerResource
