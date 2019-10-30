let Concourse = ../deps/concourse.dhall

in  { ciResources : Concourse.Types.Resource
    , eiriniStagingRepo : Concourse.Types.Resource
    , dockerOPI : Concourse.Types.Resource
    , dockerRootfsPatcher : Concourse.Types.Resource
    , dockerBitsWaiter : Concourse.Types.Resource
    , dockerSecretSmuggler : Concourse.Types.Resource
    , dockerFluentd : Concourse.Types.Resource
    }
