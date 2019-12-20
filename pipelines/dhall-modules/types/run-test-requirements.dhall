let Concourse = ../deps/concourse.dhall

in  { ciResources : Concourse.Types.Resource
    , eiriniRepo : Concourse.Types.Resource
    , secretSmugglerRepo : ./eirini-or-repo.dhall
    , fluentdRepo : ./eirini-or-repo.dhall
    , sampleConfigs : Concourse.Types.Resource
    , dockerOPI : Concourse.Types.Resource
    , dockerRootfsPatcher : Concourse.Types.Resource
    , dockerBitsWaiter : Concourse.Types.Resource
    , dockerSecretSmuggler : Concourse.Types.Resource
    , dockerFluentd : Concourse.Types.Resource
    , dockerRouteCollector : Concourse.Types.Resource
    , dockerRoutePodInformer : Concourse.Types.Resource
    , dockerRouteStatefulsetInformer : Concourse.Types.Resource
    , dockerMetricsCollector : Concourse.Types.Resource
    , dockerEventReporter : Concourse.Types.Resource
    , clusterName : Text
    , creds : ./creds.dhall
    , upstream : { event : Concourse.Types.Resource, name : Text }
    , eiriniUpstreams : Optional (List Text)
    , enableNonCodeAutoTriggers : Bool
    }
