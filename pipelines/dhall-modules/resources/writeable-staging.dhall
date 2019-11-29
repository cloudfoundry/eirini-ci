  λ(privateKey : Text)
→ ./writable-git-repo.dhall
    { name = "staging"
    , uri = "git@github.com:cloudfoundry-incubator/eirini-staging.git"
    , branch = "master"
    , privateKey = privateKey
    }
