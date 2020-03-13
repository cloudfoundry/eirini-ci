let Concourse = ../dhall-modules/deps/concourse.dhall

let Creds = ../dhall-modules/types/creds.dhall

in  { clusterName : Text
    , enableOpiStaging : Text
    , storageClass : Text
    , creds : Creds
    , stateGitHubPrivateKey : Text
    , clusterAdminPassword : Text
    , uaaAdminClientSecret : Text
    , natsPassword : Text
    , isFreshini : Bool
    , ciResources : Concourse.Types.Resource
    , eiriniReleaseRepo : Concourse.Types.Resource
    , uaaResource : Concourse.Types.Resource
    , grafanaAdminPassword : Text
    }
