let Concourse = ../deps/concourse.dhall

let script =
      ''
      ${./functions/get-cf-credentials.sh as Text}

      get-cf-credentials
      ''

in    λ(clusterName : Text)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "get-cf-credentials"
        , params = Some (toMap { CLUSTER_NAME = clusterName })
        , config =
            Concourse.Types.TaskSpec.Config
              Concourse.schemas.TaskConfig::{
              , image_resource =
                  ../helpers/image-resource.dhall "eirini/ibmcloud"
              , inputs =
                  Some
                    [ Concourse.schemas.TaskInput::{ name = "kube" }
                    , Concourse.schemas.TaskInput::{ name = "state" }
                    ]
              , outputs =
                  Some [ Concourse.schemas.TaskOutput::{ name = "cf-creds" } ]
              , run = ../helpers/bash-script-task.dhall script
              }
        }
