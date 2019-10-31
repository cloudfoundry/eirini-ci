let ImageReq = ./types/update-version-image-requirements.dhall

in    λ(reqs : ./types/update-version-requirements.dhall)
    → [ ./jobs/update-version-files.dhall
          (   reqs.{ writeableEiriniReleaseRepo, ciResources }
            ⫽ { repo = reqs.eiriniRepo
              , componentName = "eirini"
              , image1 = { docker = reqs.dockerOPI, name = "opi" }
              , image2 =
                  Some { docker = reqs.dockerBitsWaiter, name = "bits-waiter" }
              , image3 =
                  Some
                    { docker = reqs.dockerRootfsPatcher
                    , name = "rootfs-patcher"
                    }
              , upstreamJob = "create-go-docker-images"
              }
          )
      , ./jobs/update-version-files.dhall
          (   reqs.{ writeableEiriniReleaseRepo, ciResources }
            ⫽ { repo = reqs.eiriniStagingRepo
              , componentName = "staging"
              , image1 =
                  { docker = reqs.dockerDownloader
                  , name = "staging-downloader"
                  }
              , image2 =
                  Some
                    { docker = reqs.dockerExecutor, name = "staging-executor" }
              , image3 =
                  Some
                    { docker = reqs.dockerUploader, name = "staging-uploader" }
              , upstreamJob = "create-staging-docker-images"
              }
          )
      , ./jobs/update-version-files.dhall
          (   reqs.{ writeableEiriniReleaseRepo, ciResources }
            ⫽ { repo = reqs.fluentdRepo
              , componentName = "fluentd"
              , image1 = { docker = reqs.dockerFluentd, name = "fluentd" }
              , image2 = None ImageReq
              , image3 = None ImageReq
              , upstreamJob = "create-fluentd-docker-image"
              }
          )
      , ./jobs/update-version-files.dhall
          (   reqs.{ writeableEiriniReleaseRepo, ciResources }
            ⫽ { repo = reqs.secretSmugglerRepo
              , componentName = "secret-smuggler"
              , image1 =
                  { docker = reqs.dockerSecretSmuggler
                  , name = "secret-smuggler"
                  }
              , image2 = None ImageReq
              , image3 = None ImageReq
              , upstreamJob = "create-secret-smuggler-docker-image"
              }
          )
      ]
