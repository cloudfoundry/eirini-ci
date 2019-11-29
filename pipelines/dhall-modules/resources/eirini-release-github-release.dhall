let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(githubAccessToken : Text)
    → Concourse.schemas.Resource::{
      , name = "eirini-scf-release"
      , type = Concourse.Types.ResourceType.InBuilt "github-release"
      , icon = Some "rocket"
      , source =
          Some
            ( toMap
                { owner = JSON.string "cloudfoundry-incubator"
                , repository = JSON.string "eirini-release"
                , access_token = JSON.string githubAccessToken
                , drafts = JSON.bool True
                }
            )
      }
