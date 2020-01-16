let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "harden-cluster-security"
        , config = taskFile ciResources "harden-cluster-security"
        }
