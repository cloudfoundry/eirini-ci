let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let ciResources
    : Text → Concourse.Types.Resource
    =   λ(branch : Text)
      →   Concourse.defaults.Resource
        ⫽ { name = "ci-resources"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , source =
              Some
              ( toMap
                  { uri =
                      Prelude.JSON.string
                        "https://github.com/cloudfoundry-incubator/eirini-ci"
                  , branch = Prelude.JSON.string branch
                  }
              )
          }

in  ciResources
