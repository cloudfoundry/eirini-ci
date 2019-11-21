let Concourse = ../deps/concourse.dhall

let ImageLocation = ./image-location.dhall

in  { clusterName : Text
    , worldName : Text
    , uaaResources : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniReleaseRepo : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , uaaReadyEvent : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , smokeTestsResource : Concourse.Types.Resource
    , useCertManager : Text
    , creds : ./creds.dhall
    , imageLocation : ImageLocation
    , skippedCats : Optional Text
    , autoTriggerOnEiriniRelease : Bool
    , lockResource : Optional Concourse.Types.Resource
    , isFreshini : Bool
    }
