let RunTestRequirements = ./run-test-requirements.dhall

in    λ(reqs : RunTestRequirements)
    → [ ./jobs/run-tests.dhall reqs
      , ./jobs/create-go-docker-images.dhall reqs
      , ./jobs/create-secret-smuggler-docker-image.dhall reqs
      , ./jobs/run-fluentd-test.dhall reqs
      , ./jobs/create-fluentd-docker-image.dhall reqs
      ]
