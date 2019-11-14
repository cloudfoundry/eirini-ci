let Types = (../deps/concourse.dhall).Types

let schemas = (../deps/concourse.dhall).schemas

let helpers = (../deps/concourse.dhall).helpers

let `List` = (../deps/prelude.dhall).List

let JSON = (../deps/prelude.dhall).JSON

let `Text` = (../deps/prelude.dhall).Text

let ImageReq = ../types/update-version-image-requirements.dhall

let JobReqs =
      { repo : Types.Resource
      , componentName : Text
      , images : List ImageReq
      , upstreamJob : Text
      }

in    λ(writeableEiriniReleaseRepo : Types.Resource)
    → λ(reqs : JobReqs)
    → let imageInput =
              λ(imageReq : ImageReq)
            → schemas.TaskInput::{ name = imageReq.docker.name }
      
      let imageInputs =
            `List`.map ImageReq Types.TaskInput imageInput reqs.images
      
      let codeRepoInput = schemas.TaskInput::{ name = reqs.repo.name }
      
      let eiriniReleaseInput =
            schemas.TaskInput::{ name = writeableEiriniReleaseRepo.name }
      
      let toUpdateDigestLine =
            λ(i : ImageReq) → "update-digest \"${i.docker.name}\" \"${i.name}\""
      
      let updateDigestLines =
            `List`.map ImageReq Text toUpdateDigestLine reqs.images
      
      in  helpers.taskStep
            schemas.TaskStep::{
            , task = "update-version-files"
            , config =
                Types.TaskSpec.Config
                  schemas.TaskConfig::{
                  , image_resource =
                      Some
                        schemas.ImageResource::{
                        , source =
                            Some
                              (toMap { repository = JSON.string "eirini/ci" })
                        }
                  , inputs =
                      Some ([ codeRepoInput, eiriniReleaseInput ] # imageInputs)
                  , outputs =
                      Some
                        [ schemas.TaskOutput::{
                          , name = "eirini-release-updated"
                          }
                        ]
                  , run =
                      schemas.TaskRunConfig::{
                      , path = "bash"
                      , args =
                          Some
                            [ "-c"
                            , ''
                              set -euo pipefail
                              
                              ${./functions/update-digest.sh as Text}
                              
                              ${`Text`.concatSep "\n" updateDigestLines}
                              
                              commit-changes "${reqs.componentName}"
                              ''
                            ]
                      }
                  }
            }
