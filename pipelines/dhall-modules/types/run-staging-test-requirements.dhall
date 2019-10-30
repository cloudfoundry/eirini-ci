let Concourse = ../deps/concourse.dhall

in  { ciResources : Concourse.Types.Resource
    , eiriniStagingRepo : Concourse.Types.Resource
    }
