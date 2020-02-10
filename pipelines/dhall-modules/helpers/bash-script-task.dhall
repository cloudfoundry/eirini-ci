let Concourse = ../deps/concourse.dhall

in    λ(script : Text)
    → Concourse.schemas.TaskRunConfig::{
      , path = "/usr/bin/env"
      , args = Some [ "bash", "-c", script ]
      }
