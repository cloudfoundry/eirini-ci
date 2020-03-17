let Concourse = ../deps/concourse.dhall

let Creds = ./creds.dhall

let ImageLocation = ./image-location.dhall

in  { ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , kubecfRepo : Concourse.Types.Resource
    , eiriniRelease : Concourse.Types.Resource
    , smokeTestsResource : Concourse.Types.Resource
    , imageLocation : ImageLocation
    , clusterReadyEvent : Optional Concourse.Types.Resource
    , clusterName : Text
    , creds : Creds
    , lockResource : Optional Concourse.Types.Resource
    , storageClass : Text
    , cfOperatorChartUrl : Text
    }
