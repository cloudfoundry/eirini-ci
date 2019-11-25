  λ(reqs : ./types/run-staging-test-requirements.dhall)
→ let jobs =
        [ ./jobs/run-staging-tests.dhall reqs
        , ./jobs/create-staging-docker-images.dhall reqs
        ]

  in  ./helpers/group-jobs.dhall [ "test-and-build" ] jobs
