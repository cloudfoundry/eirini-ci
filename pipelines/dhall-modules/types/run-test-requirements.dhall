let Concourse = ../deps/concourse.dhall

in  { readyEventResource : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniRepo : Concourse.Types.Resource
    , secretSmugglerRepo : ./eirini-or-repo.dhall
    , fluentdRepo : ./eirini-or-repo.dhall
    , sampleConfigs : Concourse.Types.Resource
    , dockerOPI : Concourse.Types.Resource
    , dockerRootfsPatcher : Concourse.Types.Resource
    , dockerBitsWaiter : Concourse.Types.Resource
    , dockerSecretSmuggler : Concourse.Types.Resource
    , dockerFluentd : Concourse.Types.Resource
    , clusterName : Text
    , iksCreds : ./iks-creds.dhall
    }
