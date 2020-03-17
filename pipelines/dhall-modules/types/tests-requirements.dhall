let Concourse = ../deps/concourse.dhall

let ImageLocation = ./image-location.dhall

in  { clusterName : Text
    , eiriniReleaseRepo : Concourse.Types.Resource
    , lockResource : Optional Concourse.Types.Resource
    , imageLocation : ImageLocation
    , clusterState : Concourse.Types.Resource
    , smokeTestsResource : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , upstreamJob : Text
    , skippedCats : Optional Text
    }
