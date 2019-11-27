let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(clusterName : Text)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "get-gke-ingress-endpoint"
        , config =
            Concourse.Types.TaskSpec.Config
              Concourse.schemas.TaskConfig::{
              , image_resource =
                  Some
                    Concourse.schemas.ImageResource::{
                    , type = "docker-image"
                    , source = Some (toMap { repository = JSON.string "bash" })
                    }
              , outputs =
                  Some [ Concourse.schemas.TaskOutput::{ name = "ingress" } ]
              , run =
                  Concourse.schemas.TaskRunConfig::{
                  , path = "bash"
                  , args =
                      Some
                        [ "-c"
                        , "echo ${clusterName}.ci-envs.eirini.cf-app.com > ingress/endpoint"
                        ]
                  }
              }
        }
