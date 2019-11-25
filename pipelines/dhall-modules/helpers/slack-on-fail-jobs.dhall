let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

in  Prelude.List.map
      Concourse.Types.Job
      Concourse.Types.Job
      ./slack-on-fail-job.dhall
