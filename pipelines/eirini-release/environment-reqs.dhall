let Creds = ../dhall-modules/types/creds.dhall

in  { clusterName : Text
    , worldName : Text
    , enableOpiStaging : Text
    , storageClass : Text
    , eiriniCIBranch : Text
    , eiriniReleaseBranch : Text
    , creds : Creds
    , stateGitHubPrivateKey : Text
    , clusterAdminPassword : Text
    , uaaAdminClientSecret : Text
    , natsPassword : Text
    , diegoCellCount : Text
    , isFreshini : Bool
    }
