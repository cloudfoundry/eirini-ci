let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let ciResources
    : Text → Concourse.Types.Resource
    =   λ(branch : Text)
      →   Concourse.defaults.Resource
        ⫽ { name = "sample-configs"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "git"
          , source =
              Some
                ( toMap
                    { uri =
                        Prelude.JSON.string
                          "https://github.com/cloudfoundry-incubator/eirini-ci"
                    , branch = Prelude.JSON.string branch
                    , paths =
                        Prelude.JSON.array
                          [ Prelude.JSON.string "sample-configs" ]
                    }
                )
          }

in  ciResources
