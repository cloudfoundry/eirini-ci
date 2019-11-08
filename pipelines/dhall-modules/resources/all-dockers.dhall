let dockerResource = ../helpers/docker-resource.dhall

in    λ(username : Text)
    → λ(password : Text)
    → { opi = dockerResource "docker-opi" "eirini/opi" (None Text) username password
      , bitsWaiter =
          dockerResource
            "docker-bits-waiter"
            "eirini/bits-waiter"
            (None Text)
            username
            password
      , rootfsPatcher =
          dockerResource
            "docker-rootfs-patcher"
            "eirini/rootfs-patcher"
            (None Text)
            username
            password
      , secretSmuggler =
          dockerResource
            "docker-secret-smuggler"
            "eirini/secret-smuggler"
            (None Text)
            username
            password
      , fluentd =
          dockerResource
            "docker-fluentd"
            "eirini/loggregator-fluentd"
            (None Text)
            username
            password
      , stagingDownloader =
          dockerResource
            "docker-staging-downloader"
            "eirini/recipe-downloader"
            (None Text)
            username
            password
      , stagingExecutor =
          dockerResource
            "docker-staging-executor"
            "eirini/recipe-executor"
            (None Text)
            username
            password
      , stagingUploader =
          dockerResource
            "docker-staging-uploader"
            "eirini/recipe-uploader"
            (None Text)
            username
            password
      }
