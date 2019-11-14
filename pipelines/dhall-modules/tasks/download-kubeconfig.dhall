let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(clusterName : Text)
    → λ(creds : ../types/creds.dhall)
    → let cloudParams = ../helpers/get-creds.dhall creds
      
      let taskName =
            merge
              { IKSCreds =
                  λ(_ : ../types/iks-creds.dhall) → "download-kubeconfig"
              , GKECreds =
                  λ(_ : ../types/gke-creds.dhall) → "gcp-download-kubeconfig"
              }
              creds
      
      in  Concourse.helpers.taskStep
            Concourse.schemas.TaskStep::{
            , task = "download-kubeconfig"
            , config = taskFile ciResources taskName
            , params = Some (toMap { CLUSTER_NAME = clusterName } # cloudParams)
            }
