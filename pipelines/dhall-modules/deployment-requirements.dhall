let Concourse = ./deps/concourse.dhall

in  { clusterName : Text
    , worldName : Text
    , uaaResources : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniReleaseResources : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , uaaReadyEvent : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , downloadKubeconfigTask : Concourse.Types.Step
    , useCertManager : Text
    }
