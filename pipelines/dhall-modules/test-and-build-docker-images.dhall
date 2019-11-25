  λ(reqs : ./types/run-test-requirements.dhall)
→ let jobs =
        [ ./jobs/run-tests.dhall reqs
        , ./jobs/create-go-docker-images.dhall reqs
        , ./jobs/create-secret-smuggler-docker-image.dhall reqs
        , ./jobs/run-fluentd-test.dhall reqs
        , ./jobs/create-fluentd-docker-image.dhall reqs
        ]

  in  ./helpers/group-jobs.dhall [ "test-and-build" ] jobs
