let Concourse = ../deps/concourse.dhall

let cf-for-k8s
    : Text → Concourse.Types.Resource
    = ../helpers/git-resource.dhall
        "cf-for-k8s"
        "https://github.com/cloudfoundry/cf-for-k8s.git"
        (None Text)

in  cf-for-k8s
