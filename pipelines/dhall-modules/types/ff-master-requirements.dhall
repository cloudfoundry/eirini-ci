let Concourse = ../deps/concourse.dhall

in  { eiriniReleaseRepo : Concourse.Types.Resource
    , writeableReleaseRepoMaster : Concourse.Types.Resource
    , clusterNames : List Text
    }
