let Concourse = ./deps/concourse.dhall

in    λ(reqs : ./types/deployment-requirements.dhall)
    → let locksUpstream =
                  if reqs.isFreshini

            then  [ "nuke-scf" ]

            else  [ "run-core-cats-${reqs.clusterName}" ]

      let lockJobs =
            Optional/fold
              Concourse.Types.Resource
              reqs.lockResource
              (List Concourse.Types.Job)
              (   λ(r : Concourse.Types.Resource)
                → [ ./jobs/acquire-lock.dhall reqs r
                  , ./jobs/unlock.dhall reqs locksUpstream r
                  , ./jobs/release-lock.dhall reqs r
                  ]
              )
              ([] : List Concourse.Types.Job)

      let nukeScfJobs =
                  if reqs.isFreshini

            then  [ ./jobs/nuke-scf.dhall reqs ]

            else  [] : List Concourse.Types.Job

      in    lockJobs
          # [ ./jobs/deploy-uaa.dhall reqs
            , ./jobs/deploy-scf.dhall reqs
            , ./jobs/smoke-tests.dhall reqs
            , ./jobs/run-core-cats.dhall reqs
            ]
          # nukeScfJobs
