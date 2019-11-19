let eirini-release =
        λ(branch : Text)
      → λ(privateKey : Text)
      → ./writable-git-repo.dhall
          { name = "eirini-release"
          , uri = "git@github.com:cloudfoundry-incubator/eirini-release.git"
          , branch = branch
          , privateKey = privateKey
          }

in  eirini-release
