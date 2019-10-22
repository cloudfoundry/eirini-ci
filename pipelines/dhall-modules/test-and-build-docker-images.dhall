let RunTestRequirements = ./run-test-requirements.dhall

in    λ(reqs : RunTestRequirements)
    → [ ./jobs/run-tests.dhall reqs
      , ./jobs/create-go-docker-images.dhall reqs
      , ./jobs/create-secret-smuggler-docker-image.dhall reqs
      ]
