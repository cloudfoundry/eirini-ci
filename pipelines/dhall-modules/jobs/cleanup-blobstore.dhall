let Concourse = ../deps/concourse.dhall

let Creds = ../types/creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let cleanupBlobstore = ../tasks/cleanup-blobstore.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(timeTrigger : Concourse.Types.Resource)
    → λ(iksCreds : IKSCreds)
    → λ(clusterName : Text)
    → let jobs =
            [ Concourse.schemas.Job::{
              , name = "cleanup-blobstore"
              , serial = None Bool
              , plan =
                  [ ../helpers/get.dhall ciResources
                  , ../helpers/get-trigger.dhall timeTrigger
                  , ../tasks/download-kubeconfig.dhall
                      ciResources
                      clusterName
                      (Creds.IKSCreds iksCreds)
                  , cleanupBlobstore ciResources
                  ]
              }
            ]

      in  ../helpers/group-jobs.dhall [ "cleanup-blobstore" ] jobs
