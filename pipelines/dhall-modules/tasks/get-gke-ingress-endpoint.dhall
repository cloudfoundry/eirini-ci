let Concourse = ../deps/concourse.dhall

in    λ(clusterName : Text)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "get-gke-ingress-endpoint"
        , config =
            Concourse.Types.TaskSpec.Config
              Concourse.schemas.TaskConfig::{
              , image_resource = ../helpers/image-resource.dhall "bash"
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
