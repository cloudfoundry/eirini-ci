let Concourse = ../deps/concourse.dhall

in    λ(ciResources : Concourse.Types.Resource)
    → λ(eiriniRelease : Concourse.Types.Resource)
    → let job =
            Concourse.schemas.Job::{
            , name = "helm-lint"
            , plan =
                [ ../helpers/get.dhall ciResources
                , ../helpers/get-trigger.dhall eiriniRelease
                , Concourse.helpers.taskStep
                    Concourse.schemas.TaskStep::{
                    , task = "helm-lint"
                    , config =
                        ../helpers/task-file.dhall ciResources "helm-lint"
                    }
                ]
            }

      in  ../helpers/group-job.dhall [ "helm-lint" ] job
