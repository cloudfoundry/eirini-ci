  λ(reqs : ./types/deployment-requirements.dhall)
→ let jobs =
        [ ./jobs/deploy-uaa.dhall reqs
        , ./jobs/deploy-scf.dhall reqs
        , ./jobs/smoke-tests.dhall reqs
        ]

  in  ./helpers/group-jobs.dhall [ "deploy-${reqs.clusterName}" ] jobs
