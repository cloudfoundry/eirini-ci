let Concourse = ../../deps/concourse.dhall

let JSON = (../../deps/prelude.dhall).JSON

let checkoutSha =
        λ(ciResources : Concourse.Types.Resource)
      → λ(repo : Concourse.Types.Resource)
      → λ(versionFile : Text)
      → λ(imageName : Text)
      → Concourse.helpers.taskStep
          Concourse.schemas.TaskStep::{
          , task = "checkout-${repo.name}-sha"
          , privileged = Some True
          , config =
              ../../helpers/task-file.dhall ciResources "checkout-sha-by-image"
          , params =
              Some
                ( toMap
                    { VERSION_FILE = versionFile
                    , IMAGE_NAME = "docker.io/eirini/${imageName}"
                    }
                )
          , input_mapping = Some (toMap { repository = repo.name })
          , output_mapping =
              Some (toMap { repository-modified = "${repo.name}-modified" })
          }

let putRepo =
        λ(repo : Concourse.Types.Resource)
      → λ(versionResource : Concourse.Types.Resource)
      → Concourse.helpers.putStep
          Concourse.schemas.PutStep::{
          , resource = repo
          , params =
              Some
                ( toMap
                    { repository = JSON.string "${repo.name}-modified"
                    , only_tag = JSON.bool True
                    , tag = JSON.string "${versionResource.name}/version"
                    }
                )
          }

in    λ(ciResources : Concourse.Types.Resource)
    → λ(versionResource : Concourse.Types.Resource)
    → λ(repo : Concourse.Types.Resource)
    → λ(versionFile : Text)
    → λ(imageName : Text)
    → [ ../../helpers/get.dhall repo
      , checkoutSha ciResources repo versionFile imageName
      , putRepo repo versionResource
      ]
