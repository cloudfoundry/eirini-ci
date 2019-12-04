let Concourse = ../deps/concourse.dhall

in  Concourse.helpers.taskStep
      Concourse.schemas.TaskStep::{
      , task = "set-up-gke-grafana-secret"
      , config =
          Concourse.Types.TaskSpec.Config
            Concourse.schemas.TaskConfig::{
            , image_resource = ../helpers/image-resource.dhall "bash"
            , outputs =
                Some [ Concourse.schemas.TaskOutput::{ name = "secret" } ]
            , run =
                Concourse.schemas.TaskRunConfig::{
                , path = "bash"
                , args = Some [ "-c", "echo grafana-certs > secret/name" ]
                }
            }
      }
