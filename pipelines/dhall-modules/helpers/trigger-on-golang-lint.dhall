let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let trigger = ./get-trigger.dhall

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

in  trigger golangLintResource
