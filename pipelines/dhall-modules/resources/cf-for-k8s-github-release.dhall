let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(githubAccessToken : Text)
    → Concourse.schemas.Resource::{
      , name = "cf-for-k8s-github-release"
      , type = Concourse.Types.ResourceType.InBuilt "github-release"
      , icon = Some "rocket"
      , source = Some
          ( toMap
              { owner = JSON.string "cloudfoundry"
              , repository = JSON.string "cf-for-k8s"
              , access_token = JSON.string githubAccessToken
              }
          )
      }
