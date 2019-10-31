let dockerResource = ../helpers/docker-resource.dhall

in    λ(username : Text)
    → λ(password : Text)
    → { opi = dockerResource "docker-opi" "eirini/opi" username password
      , bitsWaiter =
          dockerResource
            "docker-bits-waiter"
            "eirini/bits-waiter"
            username
            password
      , rootfsPatcher =
          dockerResource
            "docker-rootfs-patcher"
            "eirini/rootfs-patcher"
            username
            password
      , secretSmuggler =
          dockerResource
            "docker-secret-smuggler"
            "eirini/secret-smuggler"
            username
            password
      , fluentd =
          dockerResource
            "docker-fluentd"
            "eirini/loggregator-fluentd"
            username
            password
      , stagingDownloader =
          dockerResource
            "docker-staging-downloader"
            "eirini/recipe-downloader"
            username
            password
      , stagingExecutor =
          dockerResource
            "docker-staging-executor"
            "eirini/recipe-executor"
            username
            password
      , stagingUploader =
          dockerResource
            "docker-staging-uploader"
            "eirini/recipe-uploader"
            username
            password
      }
