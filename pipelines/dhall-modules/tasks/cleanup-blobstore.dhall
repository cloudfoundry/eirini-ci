let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "cleanup-blobstore"
        , config = taskFile ciResources "cleanup-blobstore"
        }
