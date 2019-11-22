let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(reqs : ../types/deployment-requirements.dhall)
    → λ(lock : Concourse.Types.Resource)
    → Concourse.schemas.Job::{
      , name = "lock-${reqs.clusterName}"
      , serial = Some True
      , plan =
          [ ../helpers/get-trigger-passed.dhall
              reqs.eiriniReleaseRepo
              [ "helm-lint" ]
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { acquire = JSON.bool True })
              }
          ]
      }
