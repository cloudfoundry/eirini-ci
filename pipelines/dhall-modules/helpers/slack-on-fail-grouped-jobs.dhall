let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

in  Prelude.List.map
      Concourse.Types.GroupedJob
      Concourse.Types.GroupedJob
      (λ(gj : Concourse.Types.GroupedJob) → gj ⫽ { job = ./slack-on-fail-job.dhall gj.job })
