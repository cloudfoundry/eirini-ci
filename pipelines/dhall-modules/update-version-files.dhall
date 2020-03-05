  λ(reqs : ./types/update-version-requirements.dhall)
→ let update = ./jobs/update-version-files.dhall reqs.writeableEiriniReleaseRepo

  let jobs =
        [ update
            { repo = reqs.eiriniRepo
            , componentName = "eirini"
            , images =
                [ { docker = reqs.dockerOPI, name = "opi" }
                , { docker = reqs.dockerBitsWaiter, name = "bits-waiter" }
                , { docker = reqs.dockerRootfsPatcher, name = "rootfs-patcher" }
                , { docker = reqs.dockerRouteCollector
                  , name = "route-collector"
                  }
                , { docker = reqs.dockerRoutePodInformer
                  , name = "route-pod-informer"
                  }
                , { docker = reqs.dockerRouteStatefulsetInformer
                  , name = "route-statefulset-informer"
                  }
                , { docker = reqs.dockerMetricsCollector
                  , name = "metrics-collector"
                  }
                , { docker = reqs.dockerEventReporter, name = "event-reporter" }
                , { docker = reqs.dockerStagingReporter, name = "staging-reporter" }
                ]
            , upstreamJob = "create-go-docker-images"
            }
        , update
            { repo = reqs.eiriniStagingRepo
            , componentName = "staging"
            , images =
                [ { docker = reqs.dockerDownloader
                  , name = "staging-downloader"
                  }
                , { docker = reqs.dockerExecutor, name = "staging-executor" }
                , { docker = reqs.dockerUploader, name = "staging-uploader" }
                ]
            , upstreamJob = "create-staging-docker-images"
            }
        , update
            { repo = reqs.fluentdRepo
            , componentName = "fluentd"
            , images = [ { docker = reqs.dockerFluentd, name = "fluentd" } ]
            , upstreamJob = "create-fluentd-docker-image"
            }
        , update
            { repo = reqs.secretSmugglerRepo
            , componentName = "secret-smuggler"
            , images =
                [ { docker = reqs.dockerSecretSmuggler
                  , name = "secret-smuggler"
                  }
                ]
            , upstreamJob = "create-secret-smuggler-docker-image"
            }
        ]

  in  ./helpers/group-jobs.dhall [ "update-version-files" ] jobs
