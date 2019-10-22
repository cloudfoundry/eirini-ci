let Concourse = ./deps/concourse.dhall

in  { readyEventResource : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniResource : Concourse.Types.Resource
    , sampleConfigs : Concourse.Types.Resource
    , dockerOPI : Concourse.Types.Resource
    , dockerRootfsPatcher : Concourse.Types.Resource
    , dockerBitsWaiter : Concourse.Types.Resource
    , dockerSecretSmuggler : Concourse.Types.Resource
    , eiriniSecretSmuggler : Concourse.Types.Resource
    , fluentdRepo : Concourse.Types.Resource
    , dockerFluentd : Concourse.Types.Resource
    , clusterName : Text
    , iksCreds : ./iks-creds.dhall
    }
