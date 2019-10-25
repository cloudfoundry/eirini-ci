let Concourse = ./deps/concourse.dhall

in  { eiriniRepo : Concourse.Types.Resource
    , deploymentVersion : Concourse.Types.Resource
    }
