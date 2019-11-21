let Concourse = ../deps/concourse.dhall

let eirini-release
    : Text → Concourse.Types.Resource
    = ../helpers/git-resource.dhall
        "eirini-release"
        "https://github.com/cloudfoundry-incubator/eirini-release.git"
        (None Text)

in  eirini-release
