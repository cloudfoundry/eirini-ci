let Concourse = ../deps/concourse.dhall

let Creds = ./creds.dhall

in  { ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , cf4k8s : Concourse.Types.Resource
    , eiriniRelease : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , clusterName : Text
    , creds : Creds
    , lockResource : Optional Concourse.Types.Resource
    }
