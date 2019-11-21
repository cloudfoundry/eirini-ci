let eirini-release =
        λ(privateKey : Text)
      → ../helpers/git-resource.dhall
          "eirini-release-master"
          "git@github.com:cloudfoundry-incubator/eirini-release.git"
          (Some privateKey)
          "master"

in  eirini-release
