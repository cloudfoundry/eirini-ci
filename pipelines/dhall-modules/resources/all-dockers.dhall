  λ(username : Text)
→ λ(password : Text)
→ let dockerResource = ../helpers/docker-resource.dhall
  
  let eiriniDockerResource =
          λ(name : Text)
        → dockerResource
            "docker-${name}"
            "eirini/${name}"
            (None Text)
            username
            password
  
  let stagingDockerResource =
          λ(name : Text)
        → dockerResource
            "docker-staging-${name}"
            "eirini/recipe-${name}"
            (None Text)
            username
            password
  
  in  { opi = eiriniDockerResource "opi"
      , bitsWaiter = eiriniDockerResource "bits-waiter"
      , rootfsPatcher = eiriniDockerResource "rootfs-patcher"
      , secretSmuggler = eiriniDockerResource "secret-smuggler"
      , routeCollector = eiriniDockerResource "route-collector"
      , routePodInformer = eiriniDockerResource "route-pod-informer"
      , routeStatefulsetInformer =
          eiriniDockerResource "route-statefulset-informer"
      , stagingDownloader = stagingDockerResource "downloader"
      , stagingExecutor = stagingDockerResource "executor"
      , stagingUploader = stagingDockerResource "uploader"
      , fluentd =
          dockerResource
            "docker-fluentd"
            "eirini/loggregator-fluentd"
            (None Text)
            username
            password
      }
