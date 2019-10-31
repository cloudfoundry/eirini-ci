  λ(reqs : ./types/update-version-requirements.dhall)
→ [ ./jobs/update-version-files.dhall
      (   reqs.{ writeableEiriniReleaseRepo, ciResources }
        ⫽ { repo = reqs.eiriniRepo
          , componentName = "Eirini"
          , image1 = { docker = reqs.dockerOPI, name = "opi" }
          , image2 =
              Some { docker = reqs.dockerBitsWaiter, name = "bits-waiter" }
          , image3 =
              Some
                { docker = reqs.dockerRootfsPatcher, name = "rootfs-patcher" }
          , upstreamJob = "create-go-docker-images"
          }
      )
  , ./jobs/update-version-files.dhall
      (   reqs.{ writeableEiriniReleaseRepo, ciResources }
        ⫽ { repo = reqs.eiriniStagingRepo
          , componentName = "Eirini Staging"
          , image1 =
              { docker = reqs.dockerDownloader, name = "staging-downloader" }
          , image2 =
              Some { docker = reqs.dockerExecutor, name = "staging-executor" }
          , image3 =
              Some { docker = reqs.dockerUploader, name = "staging-uploader" }
          , upstreamJob = "create-staging-docker-images"
          }
      )
  ]
