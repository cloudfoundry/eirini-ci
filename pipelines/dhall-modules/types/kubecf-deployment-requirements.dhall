let Concourse = ../deps/concourse.dhall

let Creds = ./creds.dhall

in  { ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , kubecfRepo : Concourse.Types.Resource
    , eiriniRelease : Concourse.Types.Resource
    , clusterReadyEvent : Optional Concourse.Types.Resource
    , clusterName : Text
    , creds : Creds
    , lockResource : Optional Concourse.Types.Resource
    , storageClass : Text
    , cfOperatorChartUrl : Text
    }
