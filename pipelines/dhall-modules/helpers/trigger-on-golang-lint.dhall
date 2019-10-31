let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let golangLintResource =
      Concourse.schemas.Resource::{
      , name = "golang-lint"
      , type = Concourse.Types.ResourceType.InBuilt "docker-image"
      , icon = Some "docker"
      , source =
          Some
            ( toMap
                { repository = Prelude.JSON.string "golangci/golangci-lint"
                , tag = Prelude.JSON.string "latest"
                }
            )
      }

in  Concourse.helpers.getStep
      Concourse.schemas.GetStep::{
      , resource = golangLintResource
      , trigger = Some True
      , params = Some (toMap { skip_download = Prelude.JSON.bool True })
      }
