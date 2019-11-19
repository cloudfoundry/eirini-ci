let Concourse = ../deps/concourse.dhall

in  { ciResources : Concourse.Types.Resource
    , testEiriniBranch : Concourse.Types.Resource
    , eiriniMaster : Concourse.Types.Resource
    , clusterName : Text
    }
