let Concourse = ../deps/concourse.dhall

let IKSCreds = ./iks-creds.dhall

in  { ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , clusterCreatedEvent : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , clusterName : Text
    , enableOPIStaging : Text
    , iksCreds : IKSCreds
    , workerCount : Natural
    , storageClass : Text
    , clusterAdminPassword : Text
    , uaaAdminClientSecret : Text
    , natsPassword : Text
    , diegoCellCount : Text
    }
