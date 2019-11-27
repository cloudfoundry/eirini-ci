let Concourse = ../deps/concourse.dhall

let Creds = ../types/creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(timeTrigger : Concourse.Types.Resource)
    → λ(iksCreds : IKSCreds)
    → λ(clusterName : Text)
    → [ Concourse.schemas.Job::{
        , name = "cleanup-blobstore"
        , serial = None Bool
        , plan =
            [ ../helpers/get.dhall ciResources
            , ../helpers/get-trigger.dhall timeTrigger
            , ../tasks/download-kubeconfig.dhall
                ciResources
                clusterName
                (Creds.IKSCreds iksCreds)
            , Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "cleanup-blobstore"
                , config = taskFile ciResources "cleanup-blobstore"
                , params =
                    Some
                      ( toMap
                          { CLUSTER_NAME = clusterName
                          , IBMCLOUD_USER = iksCreds.user
                          , IBMCLOUD_PASSWORD = iksCreds.password
                          , IBMCLOUD_ACCOUNT = iksCreds.account
                          }
                      )
                }
            ]
        }
      ]
