let Concourse = ../deps/concourse.dhall

let iksParams = ../helpers/iks-params.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(clusterName : Text)
    → λ(iksCreds : ../types/iks-creds.dhall)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "get-iks-ingress-endpoint"
        , config = taskFile ciResources "get-iks-ingress-endpoint"
        , params =
            Some (toMap (iksParams iksCreds ⫽ { CLUSTER_NAME = clusterName }))
        }
