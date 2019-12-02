let Job = (../deps/concourse.dhall).Types.Job

let GroupedJob = (../deps/concourse.dhall).Types.GroupedJob

let Prelude = ../deps/prelude.dhall

in    λ(groups : List Text)
    → Prelude.List.map Job GroupedJob (./group-job.dhall groups)
