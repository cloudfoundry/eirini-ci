let Concourse = ./deps/concourse.dhall

in    λ(reqs : ./types/deployment-requirements.dhall)
    → let lockJobs =
            Optional/fold
              Concourse.Types.Resource
              reqs.lockResource
              (List Concourse.Types.Job)
              (   λ(r : Concourse.Types.Resource)
                → [ ./jobs/acquire-lock.dhall reqs r
                  , ./jobs/unlock.dhall
                      reqs
                      [ "run-core-cats-${reqs.clusterName}" ]
                      r
                  , ./jobs/release-lock.dhall reqs r
                  ]
              )
              ([] : List Concourse.Types.Job)
      
      in    lockJobs
          # [ ./jobs/deploy-uaa.dhall reqs
            , ./jobs/deploy-scf.dhall reqs
            , ./jobs/smoke-tests.dhall reqs
            , ./jobs/run-core-cats.dhall reqs
            ]
