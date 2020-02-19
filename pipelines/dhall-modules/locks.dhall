let Concourse = ./deps/concourse.dhall

let Requirements =
      { upstream : List Text
      , lockResource : Concourse.Types.Resource
      , eiriniReleaseRepo : Concourse.Types.Resource
      , acquireLockGetTriggers : List Concourse.Types.Step
      }

in    λ(reqs : Requirements)
    → let jobs =
            [ ./jobs/acquire-lock.dhall
                reqs.eiriniReleaseRepo
                reqs.lockResource
                reqs.acquireLockGetTriggers
            , ./jobs/unlock.dhall
                reqs.eiriniReleaseRepo
                reqs.upstream
                reqs.lockResource
            , ./jobs/release-lock.dhall reqs.lockResource
            ]

      in  ./helpers/group-jobs.dhall [ reqs.lockResource.name ] jobs
