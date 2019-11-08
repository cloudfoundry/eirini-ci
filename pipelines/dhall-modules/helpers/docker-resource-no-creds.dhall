let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

let TextJSONMap = Prelude.Map.Type Text Prelude.JSON.Type

let tagKeyPair = λ(t : Text) → toMap { tag = JSON.string t }

let dockerResource =
        λ(name : Text)
      → λ(repository : Text)
      → λ(optionalTag : Optional Text)
      → let tag =
              Prelude.Optional.fold
                Text
                optionalTag
                TextJSONMap
                tagKeyPair
                ([] : TextJSONMap)
        
        in  Concourse.schemas.Resource::{
            , name = name
            , type = Concourse.Types.ResourceType.InBuilt "docker-image"
            , icon = Some "docker"
            , source =
                Some (toMap { repository = JSON.string repository } # tag)
            }

in  dockerResource
