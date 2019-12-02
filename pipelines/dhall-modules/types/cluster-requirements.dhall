let Concourse = ../deps/concourse.dhall

let Creds = ./creds.dhall

in  { ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , clusterCreatedEvent : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , clusterName : Text
    , creds : Creds
    , workerCount : Natural
    , clusterPreparation : ./cluster-prep.dhall
    }
