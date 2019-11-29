let Concourse = ../deps/concourse.dhall

in  { clusterName : Text
    , ciResources : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , githubAccessToken : Text
    , githubPrivateKey : Text
    , writeableEiriniRepo : Concourse.Types.Resource
    , writeableStagingRepo : Concourse.Types.Resource
    , eiriniReleaseRepo : Concourse.Types.Resource
    , ghPagesRepo : Concourse.Types.Resource
    , versionResource : Concourse.Types.Resource
    }
