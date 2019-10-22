let Concourse = ../deps/concourse.dhall

let IKSCreds = ../iks-creds.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

in    λ(creds : IKSCreds)
    → λ(ciResources : Concourse.Types.Resource)
    → λ(clusterName : Text)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "download-kubeconfig"
        , config = taskFile ciResources "download-kubeconfig"
        , params =
            Some (toMap (iksParams creds ⫽ { CLUSTER_NAME = clusterName }))
        }
